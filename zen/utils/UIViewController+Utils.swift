import UIKit

/// UIViewController Utils.
extension UIViewController {
    var challengesService: ChallengesService {
        get {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                assertionFailure("Failed to get app delegate")
                return ChallengesService()
            }
            return appDelegate.challengesService
        }
        set {}
    }

    var storageService: StorageService {
        get {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                assertionFailure("Failed to get app delegate")
                return StorageService()
            }
            return appDelegate.storageService
        }
        set {}
    }
}
