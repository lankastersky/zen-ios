import UIKit

/// Shows current challenge
final class ChallengeViewController: UIViewController {

    @IBOutlet weak private var contentLabel: UILabel!
    @IBOutlet weak private var detailsLabel: UILabel!
    @IBOutlet weak private var quoteLabel: UILabel!
    @IBOutlet weak private var sourceLabel: UILabel!
    @IBOutlet weak private var urlLabel: UILabel!
    @IBOutlet weak private var typeLabel: UILabel!
    @IBOutlet weak private var levelLabel: UILabel!

    private var challenges: [Challenge] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: localize
        navigationItem.title = "Current Challenge"
        loadChallenges()
    }

    private func loadChallenges() {
        let firebaseService = FirebaseService()
        firebaseService.signIn(callback: {[weak self] _, error in
            if let error = error {
                print("Failed to authenticate in Firebase: \(error)")
            } else {
                firebaseService.loadChallenges(callback: { challenges, error in
                    if let error = error {
                        print("Failed to download challenges:\(error)")
                    } else if let challenges = challenges {
                        self?.challengesService?.storeChallenges(challenges)
                        self?.showCurrentChallenge()
                    }
                })
            }
        })
    }

    private func showCurrentChallenge() {
        if let challenge = challengesService?.currentChallenge {
            contentLabel.text = challenge.content
            detailsLabel.text = challenge.details
            quoteLabel.text = challenge.quote
            // TODO: localize
            typeLabel.text = "Type: \(challenge.type)"
            levelLabel.text = "Level: \(challenge.level.description)"
        }
    }
}
