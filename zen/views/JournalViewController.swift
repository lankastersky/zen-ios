import UIKit

/// Shows the Journal of finished challenges
final class JournalViewController: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!

    private var challenges: [Challenge] = []
    private var selectedItem: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "journal_screen_title".localized

        collectionView?.register(
            UINib(nibName: "JournalCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: JournalCollectionViewCell.journalViewCellReuseIdentifier
        )
        // See https://goo.gl/yAUR1R
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        challenges = challengesService.finishedChallengesSortedByTimeDesc()
        if !challenges.isEmpty {
            hideNoChallengesMessage()
            collectionView.reloadData()
        } else {
            showNoChallengesMessage("journal_screen_no_challenges".localized)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let selectedItem = selectedItem {
            collectionView.scrollToItem(at: IndexPath(row: selectedItem, section: 0),
                                        at: .top,
                                        animated: false)
            self.selectedItem = nil
        }
    }

    private func showNoChallengesMessage(_ message: String) {
        let messageLabel = UILabel(frame: collectionView.bounds)
        messageLabel.text = message
        messageLabel.textColor = UIColor.disabledSkinColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        messageLabel.sizeToFit()

        collectionView.backgroundView = messageLabel
    }

    private func hideNoChallengesMessage() {
        collectionView.backgroundView = nil
    }
}

extension JournalViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        return challenges.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: JournalCollectionViewCell.journalViewCellReuseIdentifier,
            for: indexPath
        ) as? JournalCollectionViewCell else {
            print("Failed to instantiate journal cell")
            return UICollectionViewCell()
        }

        assert(indexPath.item < challenges.count,
               "Bad challenge index when creating collection view")

        let challenge: Challenge = challenges[indexPath.item]
        cell.finishedTimeLabel.text =
            Date(timeIntervalSince1970: challenge.finishedTime).toStringWithMediumFormat()
        cell.contentLabel.text = challenge.content
        cell.detailsLabel.text = challenge.details
        cell.levelLabel.text =
            "\("challenge_screen_difficulty".localized): \(challenge.level.description)"
        cell.cosmosView.rating = challenge.rating ?? 0
        return cell
    }
}

extension JournalViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        assert(indexPath.item < challenges.count,
               "Bad challenge index when creating collection view")
        selectedItem = indexPath.item
        let challenge: Challenge = challenges[indexPath.item]
        openChallengeView(challenge)
    }

    private func openChallengeView(_ challenge: Challenge) {
        guard let challengeViewController =
            storyboard?.instantiateViewController(
                withIdentifier: ChallengeViewController.challengeViewControllerStoryboardId)
                as? ChallengeViewController else {
                    assertionFailure("Failed to instantiate challenge view controller ")
                    return
        }
        challengeViewController.challenge = challenge
        navigationController?.pushViewController(challengeViewController, animated: true)

        replaceBackButton()
    }

    private func replaceBackButton() {
        let backItem = UIBarButtonItem()
        backItem.title = "challenge_screen_back".localized
        backItem.tintColor = UIColor.white
        navigationItem.backBarButtonItem = backItem
    }
}
