//  LoginViewController.swift
//  Parstagram
//
//  Created by Favian Flores on 3/5/21.

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!

	let defaults = UserDefaults.standard

	override func viewDidLoad() {
		super.viewDidLoad()
		passwordTextField.delegate = self
		usernameTextField.delegate = self
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if defaults.bool(forKey: "loggedIn") {
			performSegue(withIdentifier: "loginToFeedSegue", sender: nil)
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
	}

	@IBAction func onSignUpButton(_ sender: Any) {
		let user = PFUser()
		user.username = usernameTextField.text
		user.password = passwordTextField.text

		user.signUpInBackground { success, error in
			if success {
				self.performSegue(withIdentifier: "loginToFeedSegue", sender: nil)
				self.defaults.setValue(true, forKey: "loggedIn")
			} else {
				print("Error signing up: \(error!.localizedDescription)")
			}
		}
	}

	@IBAction func onSignInButton(_ sender: Any) {
		let username = usernameTextField.text
		let password = passwordTextField.text

		PFUser.logInWithUsername(inBackground: username!, password: password!) { user, error in
			if user != nil {
				self.performSegue(withIdentifier: "loginToFeedSegue", sender: nil)
				self.defaults.setValue(true, forKey: "loggedIn")
			} else {
				print("Error signing in: \(error!.localizedDescription)")
			}
		}
	}
}
