import UIKit

final class ChallengeStatusFooterView: ChallengeFooterView {

    @IBOutlet private weak var statusLabel: UILabel!

    var statusText: String? {
        get { return statusLabel.text }
        set { statusLabel.text = newValue }
    }
}
