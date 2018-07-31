import UIKit

/// Shows the Journal of finished challenges
final class JournalViewController: UIViewController {

    @IBOutlet weak private var collectionView: UICollectionView!

    private var challenges: [Challenge] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: localize
        navigationItem.title = "Finished Challenges"

        challenges = challengesService?.sortedChallenges ?? []

        collectionView?.register(UINib(nibName: "JournalCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: JournalCollectionViewCell.journalViewCellReuseIdentifier)
        // See https://goo.gl/yAUR1R
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }
}

extension JournalViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {

        return challenges.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: JournalCollectionViewCell.journalViewCellReuseIdentifier,
            for: indexPath) as? JournalCollectionViewCell else {
                print("Failed to instantiate journal cell")
                return UICollectionViewCell()
        }

        assert(indexPath.item < challenges.count,
               "Bad challenge index when creating collection view")
        
        let challenge: Challenge = challenges[indexPath.item]
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
