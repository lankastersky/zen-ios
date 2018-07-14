import UIKit

/// UIViewController Utils.
extension UIViewController {
    var challengesProvider: ChallengesProvider? {
        get {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("Failed to get app delegate")
                return nil
            }
            
            let challengesProvider = appDelegate.challengesProvider
            return challengesProvider
        }
        set {}
    }
}
