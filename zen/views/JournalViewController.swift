import UIKit

/// Shows the Journal of finished challenges
final class JournalViewController: UICollectionViewController {

    private static let journalViewCellReuseIdentifier = "JournalViewCell"

    private var challenges: [String: Challenge] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: localize
        navigationItem.title = "Finished Challenges"

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Failed to get app delegate")
            return
        }

        let challengesProvider = appDelegate.challengesProvider
        challenges = challengesProvider.challenges

        collectionView?.register(UINib.init(nibName: "JournalCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: JournalViewController.journalViewCellReuseIdentifier)
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {

        return challenges.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: JournalViewController.journalViewCellReuseIdentifier,
            for: indexPath) as? JournalCollectionViewCell else {
                print("Failed to instantiate journal cell")
                return UICollectionViewCell()
        }

        let challenge: Challenge = Array(challenges.values)[indexPath.item]
        cell.contentLabel.text = challenge.content
        cell.detailsLabel.text = challenge.details
        cell.backgroundColor = randomColor()
        return cell
    }

    // custom function to generate a random UIColor
    // TODO: remove after implementing real cells
    func randomColor() -> UIColor {
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
