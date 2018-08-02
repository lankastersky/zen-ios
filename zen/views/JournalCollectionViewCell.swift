import UIKit
import Cosmos

final class JournalCollectionViewCell: UICollectionViewCell {

    static let journalViewCellReuseIdentifier = "JournalViewCell"

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var finishedTimeLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!

    @IBOutlet weak private var widthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Used to make cells resizable by height. See https://goo.gl/yAUR1R
        // TODO: consider using table cells instead.
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let screenWidth = UIScreen.main.bounds.size.width
        widthConstraint.constant = screenWidth - 2 * 0
    }
}
