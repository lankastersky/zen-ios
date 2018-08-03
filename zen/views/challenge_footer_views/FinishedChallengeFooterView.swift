import UIKit
import Cosmos

final class FinishedChallengeFooterView: ChallengeFooterView {

    @IBOutlet private weak var cosmosView: CosmosView!

    @IBOutlet weak var commentsLabel: UILabel!

    override func refreshUI() {
        super.refreshUI()
        cosmosView.settings.updateOnTouch = false
    }
}
