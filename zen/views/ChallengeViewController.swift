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

    @IBOutlet weak private var challengeButton: UIButton!

    private var challenges: [Challenge] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "current_challenge_screen_title".localized
        loadChallenges()
    }

    private func loadChallenges() {
        let firebaseService = FirebaseService()
        firebaseService.signIn(callback: { [weak self] _, error in
            if let error = error {
                print("Failed to authenticate in Firebase: \(error)")
            } else {
                firebaseService.loadChallenges(callback: { challenges, error in
                    if let error = error {
                        print("Failed to download challenges:\(error)")
                    } else if let challenges = challenges {
                        self?.challengesService.storeChallenges(challenges)
                        self?.showCurrentChallenge()
                        self?.updateChallengeButton()
                    }
                })
            }
        })
    }

    private func showCurrentChallenge() {
        guard let challenge = challengesService.currentChallenge else {
            assertionFailure("Failed to get current challenge")
            return
        }
        contentLabel.text = challenge.content
        detailsLabel.text = challenge.details
        quoteLabel.text = challenge.quote
        typeLabel.text = "\("Type".localized): \(challenge.type)"
        levelLabel.text =
        "\("current_challenge_screen_difficulty".localized): \(challenge.level.description)"

        challengesService.markChallengeShown(challenge.challengeId)
    }

    @IBAction private func onChallengeButton(sender: UIButton!) {
        guard let challenge = challengesService.currentChallenge else {
            assertionFailure("Failed to get current challenge")
            return
        }
        switch challenge.status {
        case .shown?:
            challengesService.markChallengeAccepted(challenge.challengeId)
        case .accepted?:
            challengesService.markChallengeFinished(challenge.challengeId)
        default:
            assertionFailure("Bad challenge status when clicking on challenge button")
        }

        updateChallengeButton()
    }

    private func updateChallengeButton() {
        guard let challenge = challengesService.currentChallenge else {
            assertionFailure("Failed to get current challenge")
            return
        }
        switch challenge.status {
        case .shown?:
            if challengesService.isTimeToAcceptChallenge {
                challengeButton.isEnabled = true
                challengeButton.setTitle(
                    "current_challenge_screen_button_accept".localized,
                    for: .normal)
            } else {
                challengeButton.isEnabled = false
                challengeButton.setTitle(
                    "You can accept the task before 6pm".localized,
                    for: .normal)
            }
        case .accepted?:
            if challengesService.isTimeToAcceptChallenge {
                challengeButton.isEnabled = true
                challengeButton.setTitle(
                    "current_challenge_screen_button_finish".localized,
                    for: .normal)
            } else {
                challengeButton.isEnabled = false
                challengeButton.setTitle(
                    "current_challenge_screen_button_return_after_6pm".localized,
                    for: .normal)
            }
        case .finished?, .declined?:
            challengeButton.setTitle(
                "current_challenge_screen_button_finished".localized,
                for: .normal)
            challengeButton.isEnabled = false
        default:
            assertionFailure("Bad challenge status when refreshing challenge button")
        }
    }
}
