//  FeedViewController.swift
//  Parstagram
//
//  Created by Favian Flores on 3/5/21.

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController,
	UITableViewDelegate,
	UITableViewDataSource,
	MessageInputBarDelegate {
	@IBOutlet weak var tableView: UITableView!


	var results: [PFObject] = []
	var numPostsToSkip = 20
	var noMorePosts = false
	let commentBar = MessageInputBar()
	var showsCommentBar = false
	var selectedPost: PFObject!

	override var inputAccessoryView: UIView? {
		return commentBar
	}

	override var canBecomeFirstResponder: Bool {
		return showsCommentBar
	}

	@IBAction func onLogoutButton(_ sender: Any) {
		PFUser.logOut()
		dismiss(animated: true, completion: nil)
		UserDefaults.standard.setValue(false, forKey: "loggedIn")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.refreshControl = UIRefreshControl()
		tableView.refreshControl?.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
		let center = NotificationCenter.default
		center.addObserver(
			self,
			selector: #selector(keyboardWillHide(note:)),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
		commentBar.delegate = self
		commentBar.inputTextView.placeholder = "Add a comment..."
		commentBar.sendButton.title = "Post"
		commentBar.backgroundView.backgroundColor = UIColor(named: "MainColor")
		commentBar.sendButton.setTitleColor(UIColor(named: "AccentColor"), for: UIControl.State.normal)
	}

	func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
		let comment = PFObject(className: "Comments")

		comment["text"] = text
		comment["post"] = selectedPost
		comment["author"] = PFUser.current()!

		selectedPost.add(comment, forKey: "comments")

		selectedPost.saveInBackground { success, error in
			if success {
				print("Successfully saved comment!")
			} else {
				print("Couldn't save comment: \(error!.localizedDescription)")
			}
		}

		tableView.reloadData()

		showsCommentBar = false
		becomeFirstResponder()
		commentBar.inputTextView.resignFirstResponder()
	}

	@objc func keyboardWillHide(note: Notification) {
		commentBar.inputTextView.text = nil
		showsCommentBar = false
		becomeFirstResponder()
		commentBar.inputTextView.resignFirstResponder()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		loadPosts()
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return results.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let post = results[section]
		let comments = (post["comments"] as? [PFObject]) ?? []

		return comments.count + 2
	}

	func tableView(
		_ tableView: UITableView,
		willDisplay cell: UITableViewCell,
		forRowAt indexPath: IndexPath
	) {
		if indexPath.row + 1 == results.count {
			loadMorePosts()
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let post = results[indexPath.section]
		let comments = (post["comments"] as? [PFObject]) ?? []

		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostTableViewCell

			let user = post["author"] as! PFUser
			cell.nameLabel.text = user.username!
			cell.descriptionLabel.text = (post["caption"] as! String)
			let date = post["dateCreated"] as? Date
			if date != nil {
				let dateArray = date!.description.split(separator: " ")
				cell.dateLabel.text = String(dateArray[0])
			} else {
				cell.dateLabel.text = "Date Not Found!"
			}
			let imageFile = post["image"] as! PFFileObject
			let imageURLString = imageFile.url!
			let imageURL = URL(string: imageURLString)!
			cell.postImage.af.setImage(withURL: imageURL)

			let profileImageFile = user["profileImage"] as? PFFileObject
			if profileImageFile != nil {
				let profileImageURLString = profileImageFile!.url!
				let profileImageURL = URL(string: profileImageURLString)!
				cell.profileImage.af.setImage(withURL: profileImageURL)
			}

			return cell
		} else if indexPath.row > comments.count {
			let cell = tableView.dequeueReusableCell(withIdentifier: "addACommentCell")!
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(
				withIdentifier: "commentCell"
			) as! CommentTableViewCell

			let comment = comments[indexPath.row - 1]
			cell.commentLabel.text = comment["text"] as? String

			let user = comment["author"] as! PFUser
			cell.nameLabel.text = user.username

			let profileImageFile = user["profileImage"] as? PFFileObject
			if profileImageFile != nil {
				let profileImageURLString = profileImageFile!.url!
				let profileImageURL = URL(string: profileImageURLString)!
				cell.profileImage.af.setImage(withURL: profileImageURL)
			}

			return cell
		}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let post = results[indexPath.section]
		selectedPost = post
		let comments = post["comments"] as? [PFObject] ?? []

		if indexPath.row == comments.count + 1 {
			showsCommentBar = true
			becomeFirstResponder()
			commentBar.inputTextView.becomeFirstResponder()
		}
	}

	@objc func loadPosts() {
		noMorePosts = false
		let query = PFQuery(className: "Posts")
		query.includeKeys(["author", "comments", "comments.author"])
		query.limit = 20
		query.order(byDescending: "dateCreated")
		query.findObjectsInBackground { results, error in
			if results != nil {
				self.results = results!
				self.tableView.reloadData()
				self.tableView.refreshControl?.endRefreshing()
				if results!.count < 20 {
					self.noMorePosts = true
				}
			} else if error != nil {
				print("Error downloading posts: \(error!)" )
				self.tableView.refreshControl?.endRefreshing()
			}
		}
	}

	func loadMorePosts() {
		let query = PFQuery(className: "Posts")
		query.includeKeys(["author", "comments", "comments.author"])
		query.limit = 20
		query.order(byDescending: "dateCreated")
		query.skip = numPostsToSkip
		query.findObjectsInBackground { results, error in
			if results != nil && !self.noMorePosts {
				self.results.append(contentsOf: results!)
				self.numPostsToSkip += results!.count
				self.tableView.reloadData()
				self.tableView.refreshControl?.endRefreshing()
				if results!.isEmpty {
					self.noMorePosts.toggle()
				}
			} else if error != nil {
				print("Error downloading posts: \(error!)" )
				self.tableView.refreshControl?.endRefreshing()
			}
		}
	}
}
