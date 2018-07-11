import UIKit

/// Shows current challenge
final class ChallengeViewController: UIViewController {

    @IBOutlet weak private var contentLabel: UILabel!
    @IBOutlet weak private var detailsLabel: UILabel!
    @IBOutlet weak private var quoteLabel: UILabel!
    @IBOutlet weak private var sourceLabel: UILabel!
    @IBOutlet weak private var typeLabel: UILabel!
    @IBOutlet weak private var urlLabel: UILabel!

    private var challenges: [String: Challenge] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: localize
        navigationItem.title = "Current Challenge"

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
        // TODO: choose proper index
        let challengeIndex = 0
        let challenge = Array(challenges.values)[challengeIndex]
        contentLabel.text = challenge.content
    }
}
