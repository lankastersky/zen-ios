import UIKit

/// Shows current challenge
final class ChallengeViewController: UIViewController {

    static let challengeViewControllerStoryboardId = "ChallengeViewController"

    private var activeFooterView: ChallengeFooterView?

    @IBOutlet weak private var contentLabel: UILabel!
    @IBOutlet weak private var detailsLabel: UILabel!
    @IBOutlet weak private var quoteLabel: UILabel!
    @IBOutlet weak private var sourceLabel: UILabel!
    @IBOutlet weak private var urlLabel: UILabel!
    @IBOutlet weak private var typeLabel: UILabel!
    @IBOutlet weak private var levelLabel: UILabel!
    @IBOutlet weak private var footerHolderView: UIView!

    var challenge: Challenge?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "challenge_screen_title".localized
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let challenge = self.challenge {
            //challengeButton.isHidden = true
            showChallengeFromJournal(challenge)
        } else {
            loadChallenges()
        }
    }

    private func loadChallenges() {
        let firebaseService = FirebaseService(storageService, challengesService)
        firebaseService.signIn(callback: { [weak self] _, error in
            if let error = error {
                print("Failed to authenticate in Firebase: \(error)")
            } else {
                firebaseService.loadChallenges(callback: { error in
                    if let error = error {
                        print("Failed to download challenges:\(error)")
                    } else {
                        self?.showCurrentChallenge()
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
        showChallengeHeader(challenge)

        switch challenge.status {
        case nil:
            challengesService.markChallengeShown(challenge.challengeId)
            showShownChallengeFooterView(challenge)
        case .shown?:
            showShownChallengeFooterView(challenge)
        case .accepted?:
            if !challengesService.isTimeToFinishChallenge {
                showAcceptedChallengeFooterView(challenge)
            } else {
                showFinishingChallengeFooterView(challenge)
            }
        case .finished?:
            showFinishedChallengeFooterView(challenge)
        case .declined?:
            assertionFailure("Bad challenge status while showing current challenge")
        }
    }

    private func showChallengeFromJournal(_ challenge: Challenge) {
        showChallengeHeader(challenge)
        showFinishedChallengeFooterView(challenge)
    }

    private func showChallengeHeader(_ challenge: Challenge) {
        contentLabel.text = challenge.content
        detailsLabel.text = challenge.details
        quoteLabel.text = challenge.quote
        typeLabel.text = "\("Type".localized): \(challenge.type)"
        levelLabel.text =
        "\("challenge_screen_difficulty".localized): \(challenge.level.description)"
    }

    private func showShownChallengeFooterView(_ challenge: Challenge) {
        let view: ShownChallengeFooterView = ShownChallengeFooterView.fromNib()
        view.challengesService = challengesService
        showFooterView(view, challenge)
    }

    private func showAcceptedChallengeFooterView(_ challenge: Challenge) {
        let view: AcceptedChallengeFooterView = AcceptedChallengeFooterView.fromNib()
        showFooterView(view, challenge)
    }

    private func showFinishingChallengeFooterView(_ challenge: Challenge) {
        let view: FinishingChallengeFooterView = FinishingChallengeFooterView.fromNib()
        showFooterView(view, challenge)
    }

    private func showFinishedChallengeFooterView(_ challenge: Challenge) {
        let view: FinishedChallengeFooterView = FinishedChallengeFooterView.fromNib()
        // TODO: remove default text
        view.commentsLabel.text = challenge.comments ?? "-\n-\n-\n-\n-"
        showFooterView(view, challenge)
    }

    private func showFooterView(_ footerView: ChallengeFooterView, _ challenge: Challenge) {
        activeFooterView?.removeFromSuperview()
        activeFooterView = footerView

        footerHolderView.addSubview(footerView)

        footerView.challenge = challenge
        footerView.challengeFooterViewDelegate = self

        footerView.translatesAutoresizingMaskIntoConstraints = false

        let margins = footerHolderView.layoutMarginsGuide
        footerView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        footerView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        footerView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        footerView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true

        footerView.refreshUI()
    }
}

extension ChallengeViewController: ChallengeFooterViewDelegate {

    func onChallengeAccepted(_ challenge: Challenge) {
        challengesService.markChallengeAccepted(challenge.challengeId)
        showAcceptedChallengeFooterView(challenge)
    }

    func onChallengeFinishing(_ challenge: Challenge) {
        showFinishingChallengeFooterView(challenge)
    }

    func onChallengeFinished(_ challenge: Challenge) {
        challengesService.markChallengeFinished(challenge.challengeId)
        showFinishedChallengeFooterView(challenge)
    }
}
