//
//  FirstViewController.swift
//  zen
//
//  Created by Anton Popov on 6/27/18.
//  Copyright © 2018 Anton Popov. All rights reserved.
//

import UIKit

/// Shows current challenge
class ChallengeViewController: UIViewController {

    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var quote: UILabel!
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var url: UILabel!

    private var challenges: [String: Challenge] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: localize
        self.navigationItem.title = "Current Challenge"

        ChallengesProvider.shared.signIn(callback: { _, error in
            if let error = error {
                print("Failed to authenticate in Firebase: \(error)")
            } else {
                ChallengesProvider.shared.loadChallenges(callback: { challenges, error in
                    if let error = error {
                        print("Failed to download challenges:\(error)")
                    } else if let challenges = challenges {

                        self.challenges = challenges
                        self.showCurrentChallenge()
                    }
                })
            }
        })
    }

    private func showCurrentChallenge() {
        let challenges = ChallengesProvider.shared.challenges
        let challengeIndex = 0
        let challenge = Array(challenges.values)[challengeIndex]
        content.text = challenge.content
    }
}
