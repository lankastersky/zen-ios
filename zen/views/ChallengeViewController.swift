import UIKit

/// Shows current challenge
final class ChallengeViewController: UIViewController {

    @IBOutlet weak private var contentLabel: UILabel!
    @IBOutlet weak private var detailsLabel: UILabel!
    @IBOutlet weak private var quoteLabel: UILabel!
    @IBOutlet weak private var sourceLabel: UILabel!
    @IBOutlet weak private var typeLabel: UILabel!
    @IBOutlet weak private var urlLabel: UILabel!

    private var challenges: [Challenge] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: localize
        navigationItem.title = "Current Challenge"
        loadChallenges()
    }

    private func loadChallenges() {
        let challengesProvider = ChallengesProvider()
        challengesProvider.signIn(callback: {[weak self] _, error in
            if let error = error {
                print("Failed to authenticate in Firebase: \(error)")
            } else {
                challengesProvider.loadChallenges(callback: { challenges, error in
                    if let error = error {
                        print("Failed to download challenges:\(error)")
                    } else if let challenges = challenges {
                        self?.challengesManager?.storeChallenges(challenges)
                        self?.showCurrentChallenge()
                    }
                })
            }
        })
    }

    private func showCurrentChallenge() {
        // TODO: choose proper index
        let challengeIndex = 0
        if let challenge = challengesManager?.sortedChallenges[challengeIndex] {
            contentLabel.text = challenge.content
        }
    }
}
