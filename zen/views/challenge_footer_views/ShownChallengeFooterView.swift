import UIKit

final class ShownChallengeFooterView: ChallengeFooterView {

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
        challengeFooterViewDelegate?.onChallengeAccepted(challenge)
    }

    private func updateChallengeButton() {
        challengeButton.setTitle(
            "challenge_screen_button_accept".localized,
            for: .normal)
        challengeButton.setTitleColor(UIColor.darkSkinColor, for: .normal)
    }
}
