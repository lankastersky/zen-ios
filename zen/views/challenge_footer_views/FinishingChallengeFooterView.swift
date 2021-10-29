import UIKit
import Cosmos

final class FinishingChallengeFooterView: ChallengeFooterView {

    @IBOutlet private weak var ratingView: CosmosView!
    @IBOutlet private weak var challengeButton: UIButton!
    @IBOutlet private weak var commentsTextView: UITextView!

    override func refreshUI() {
        super.refreshUI()
        updateChallengeButton()
        updateChallengeComments()
        updateRatingView()
    }

    @IBAction private func onChallengeButton(sender: UIButton!) {
        guard let challenge = challenge else {
            assertionFailure("Challenge is not initialized in footer view")
            return
        }
        challengeFooterViewDelegate?.onChallengeFinished(challenge)
    }

    private func updateChallengeButton() {
        challengeButton.setTitle(
            "challenge_screen_button_finish".localized,
            for: .normal)
        challengeButton.setTitleColor(UIColor.darkSkinColor, for: .normal)
    }

    private func updateChallengeComments() {
        commentsTextView.textColor = UIColor.lightGray
        commentsTextView.text = "challenge_screen_comments_placeholder".localized
        commentsTextView.delegate = self
    }

    private func updateRatingView() {
        ratingView.didFinishTouchingCosmos = { rating in self.challenge?.rating = rating }
        ratingView.settings.filledColor = UIColor.accentSkinColor
    }
}

extension FinishingChallengeFooterView: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if commentsTextView.text == "challenge_screen_comments_placeholder".localized {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            commentsTextView.text = "challenge_screen_comments_placeholder".localized
            textView.textColor = UIColor.lightGray
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        challenge?.comments = textView.text
    }
}
