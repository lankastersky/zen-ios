import UIKit
import Cosmos

final class FinishedChallengeFooterView: ChallengeFooterView {

    @IBOutlet private weak var ratingView: CosmosView!

    @IBOutlet weak var commentsLabel: UILabel!

    override func refreshUI() {
        super.refreshUI()
        ratingView.settings.updateOnTouch = false
    }
}
