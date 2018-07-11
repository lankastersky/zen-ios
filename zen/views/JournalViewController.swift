//
//  JournalViewController.swift
//  zen
//
//  Created by Anton Popov on 7/10/18.
//  Copyright © 2018 Anton Popov. All rights reserved.
//

import UIKit

/// Shows the Journal of finished challenges
class JournalViewController: UICollectionViewController {

    private static let journalViewCellReuseIdentifier = "JournalViewCell"

    private var challenges: [String: Challenge] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: localize
        self.navigationItem.title = "Finished Challenges"

        challenges = ChallengesProvider.shared.challenges
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {

        return challenges.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell: JournalCollectionViewCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: JournalViewController.journalViewCellReuseIdentifier,
            for: indexPath) as? JournalCollectionViewCell else {
                print("Failed to instantiate journal cell")
                return UICollectionViewCell()
        }

        // Configure the cell
        let challenge: Challenge = Array(challenges.values)[indexPath.item]
        cell.content.text = challenge.content
        cell.backgroundColor = self.randomColor()
        return cell
    }

    // custom function to generate a random UIColor
    // TODO: remove after implementing real cells
    func randomColor() -> UIColor {
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
