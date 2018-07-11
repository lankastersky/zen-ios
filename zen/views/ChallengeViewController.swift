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
    
    private var _challenges: [String: Challenge] = [:]
    
    var challenges: [String: Challenge] {
        get {
            return _challenges
        }
        set {
            self._challenges = newValue
            showCurrentChallenge()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: localize
        self.navigationItem.title = "Current Challenge"
    }
    
    private func showCurrentChallenge() {
        let challenges = ChallengesProvider.shared.challenges
        let challengeIndex = 0
        let challenge = Array(challenges.values)[challengeIndex]
        content.text = challenge.content
    }
}

