import UIKit

final class ChallengeStatusFooterView: ChallengeFooterView {

    @IBOutlet private weak var statusLabel: UILabel!

    internal var statusText: String? {
        get { return statusLabel.text }
        set { statusLabel.text = newValue }
    }
}
