import UIKit

final class AcceptedChallengeFooterView: ChallengeFooterView {

    @IBOutlet private weak var challengeButton: UIButton!

    override func refreshUI() {
        super.refreshUI()
        updateChallengeButton()
    }

    @IBAction private func onChallengeButton(sender: UIButton!) {
        guard let challenge = challenge else {
            assertionFailure("Challenge is not initialized in footer view")
            return
        }
        challengeFooterViewDelegate?.onChallengeFinishing(challenge)
    }

    private func updateChallengeButton() {
        challengeButton.isEnabled = false
        challengeButton.setTitle(
            "challenge_screen_button_return_after_6pm".localized,
            for: .normal)
    }
}
