//  NewPostViewController.swift
//  Parstagram
//
//  Created by Favian Flores on 3/5/21.

import UIKit
import Parse
import AlamofireImage

class NewPostViewController: UIViewController,
	UIImagePickerControllerDelegate,
	UINavigationControllerDelegate,
	UITextFieldDelegate {
	@IBOutlet weak var postImage: UIImageView!
	@IBOutlet weak var descriptionTextField: UITextField!
	@IBOutlet weak var postImageTopConstraint: NSLayoutConstraint!

	var keyboardVisible = false

	override func viewDidLoad() {
		super.viewDidLoad()
		descriptionTextField.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillShow),
			name: UIResponder.keyboardWillShowNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillHide),
			name: UIResponder.keyboardWillHideNotification,
			object: nil)
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
	}

	@objc func keyboardWillShow() {
		if !keyboardVisible {
			UIView.animate(withDuration: 1) { () -> Void in
				self.postImageTopConstraint.constant -= 100
				self.view.layoutIfNeeded()
				self.keyboardVisible.toggle()
			}
		}
	}

	@objc func keyboardWillHide() {
		if keyboardVisible {
			UIView.animate(withDuration: 1) { () -> Void in
				self.postImageTopConstraint.constant += 100
				self.view.layoutIfNeeded()
				self.keyboardVisible.toggle()
			}
		}
	}

	@IBAction func onPostImage(_ sender: Any) {
		let picker = UIImagePickerController()
		picker.delegate = self
		picker.allowsEditing = true

		let sourceAlert = UIAlertController(
			title: "Choose a photo source",
			message: nil,
			preferredStyle: .actionSheet
		)
		sourceAlert.addAction(UIAlertAction(
			title: "Camera",
			style: .default
		) { (_: UIAlertAction) in
			if UIImagePickerController.isSourceTypeAvailable(.camera) {
				picker.sourceType = .camera
				self.present(picker, animated: true, completion: nil)
			}
		})
		sourceAlert.addAction(UIAlertAction(
			title: "Photo Library",
			style: .default
		) { (_: UIAlertAction) in
			picker.sourceType = .photoLibrary
			self.present(picker, animated: true, completion: nil)
		})
		sourceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(sourceAlert, animated: true, completion: nil)
	}

	func imagePickerController(
		_ picker: UIImagePickerController,
		didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
	) {
		let image = info[.editedImage] as! UIImage
		let size = CGSize(width: 300, height: 300)
		let scaledImage = image.af.imageAspectScaled(toFit: size)

		postImage.image = scaledImage
		dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}

	@IBAction func onSubmitButton(_ sender: Any) {
		let post = PFObject(className: "Posts")
		post["author"] = PFUser.current()!
		post["caption"] = descriptionTextField.text ?? ""

		let imageData = postImage.image?.pngData()
		let imageObject = PFFileObject(data: imageData!)

		post["image"] = imageObject
		post["dateCreated"] = Date()

		post.saveInBackground { success, error in
			if success {
				self.dismiss(animated: true, completion: nil)
			} else {
				print("error saving post: \(error!.localizedDescription)")
			}
		}
	}
}
