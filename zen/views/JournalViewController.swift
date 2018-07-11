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
    
    private static let JOURNAL_VIEW_CELL_REUSE_IDENTIFIER = "JournalViewCell"
    
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

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return challenges.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: JournalCollectionViewCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: JournalViewController.JOURNAL_VIEW_CELL_REUSE_IDENTIFIER,
            for: indexPath) as! JournalCollectionViewCell
    
        // Configure the cell
        let challenge: Challenge = Array(challenges.values)[indexPath.item]
        cell.content.text = challenge.content
        cell.backgroundColor = self.randomColor()
        return cell
    }

    // custom function to generate a random UIColor
    func randomColor() -> UIColor{
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
}
