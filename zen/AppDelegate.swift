//
//  AppDelegate.swift
//  zen
//
//  Created by Anton Popov on 6/27/18.
//  Copyright © 2018 Anton Popov. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        ChallengesProvider.shared.signIn(callback: { _, error in
            if let error = error {
                print("Failed to authenticate in Firebase: \(error)")
            } else {
                ChallengesProvider.shared.loadChallenges(callback: { challenges, error in
                    if let error = error {
                        print("Failed to download challenges:\(error)")
                    } else {
                        self.updateChallengeViewController(challenges!)
                    }
                })
            }
        })
        return true
    }

    private func updateChallengeViewController(_ challenges: [String: Challenge]) {
        let tabBarController = self.window!.rootViewController as! UITabBarController
        let challengeNavigationController: UINavigationController =
            tabBarController.viewControllers![0] as! UINavigationController
        let challengeViewController: ChallengeViewController =
            challengeNavigationController.viewControllers[0] as! ChallengeViewController
        challengeViewController.challenges = challenges
    }
}

