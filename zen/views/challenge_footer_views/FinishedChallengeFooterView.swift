import UIKit
import Cosmos

final class FinishedChallengeFooterView: ChallengeFooterView {

    @IBOutlet private weak var ratingView: CosmosView!
    @IBOutlet private weak var commentsLabel: UILabel!

    var commentsText: String? {
        get { return commentsLabel.text }
        set { commentsLabel.text = newValue }
    }

    var rating: Double {
        get { return ratingView.rating }
        set { ratingView.rating = newValue }
    }
    override func refreshUI() {
        super.refreshUI()
        ratingView.settings.updateOnTouch = false
    }
}
