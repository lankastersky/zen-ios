import UIKit

/// UIViewController Utils.
extension UIViewController {
    var challengesModel: ChallengesModel? {
        get {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("Failed to get app delegate")
                return nil
            }

            let challengesModel = appDelegate.challengesModel
            return challengesModel
        }
        set {}
    }
}
