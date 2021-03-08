//  FeedViewController.swift
//  Parstagram
//
//  Created by Favian Flores on 3/5/21.

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet weak var tableView: UITableView!

	var results: [PFObject] = []
	var numPostsToSkip = 20
	var noMorePosts = false

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
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		loadPosts()
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return results.count
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
		let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostTableViewCell
		let post = results[indexPath.row]

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

		return cell
	}

	@objc func loadPosts() {
		noMorePosts = false
		let query = PFQuery(className: "Posts")
		query.includeKey("author")
		query.limit = 20
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
		query.includeKey("author")
		query.limit = 20
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
