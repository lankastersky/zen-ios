import UIKit

final class JournalCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var finishedTimeLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let screenWidth = UIScreen.main.bounds.size.width
        widthConstraint.constant = screenWidth - 2 * 12
    }
}
