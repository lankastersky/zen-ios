import UIKit

/// UIViewController Utils.
extension UIViewController {
    var challengesManager: ChallengesManager? {
        get {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("Failed to get app delegate")
                return nil
            }
            return appDelegate.challengesManager
        }
        set {}
    }
}
