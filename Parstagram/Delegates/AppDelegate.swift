//  AppDelegate.swift
//  Parstagram
//
//  Created by Favian Flores on 3/5/21.

import UIKit
import Parse

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		let parseConfig = ParseClientConfiguration {
			$0.applicationId = "w1UEiovqR5OxBOR5DUOOBgyFFD1L2xqvv9xpG7Pq"
			$0.clientKey = "Wu3oRZtrs770PzvCFcRVgyoc50xwFozTyDXuGwWk"
			$0.server = "https://parseapi.back4app.com/"
		}
		Parse.initialize(with: parseConfig)
		do {
			sleep(1)
		}
		return true
	}

	func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions
	) -> UISceneConfiguration {
		return UISceneConfiguration(
			name: "Default Configuration",
			sessionRole: connectingSceneSession.role
		)
	}

	func application(
		_ application: UIApplication,
		didDiscardSceneSessions sceneSessions: Set<UISceneSession>
	) { }
}
