import UIKit

final class ShownChallengeFooterView: ChallengeFooterView {

    @IBOutlet private weak var challengeButton: UIButton!

    var challengesService: ChallengesService?

    override func refreshUI() {
        super.refreshUI()
        updateChallengeButton()
    }

    @IBAction private func onChallengeButton(sender: UIButton!) {
        guard let challenge = challenge else {
            assertionFailure("Challenge is not initialized in footer view")
            return
        }
        challengeFooterViewDelegate?.onChallengeAccepted(challenge)
    }

    private func updateChallengeButton() {
        guard let challengesService = challengesService else {
            assertionFailure("Challenges service is not initialized in footer view")
            return
        }
        if challengesService.isTimeToAcceptChallenge {
            challengeButton.isEnabled = true
            challengeButton.setTitle(
                "challenge_screen_button_accept".localized,
                for: .normal)
        } else {
            challengeButton.isEnabled = false
            challengeButton.setTitle(
                "challenge_screen_button_accept_before_6pm".localized,
                for: .normal)
        }
    }
}
