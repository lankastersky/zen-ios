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
    var challengesProvider = ChallengesProvider()

    func application(
        _ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
