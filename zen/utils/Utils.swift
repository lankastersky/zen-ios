import Foundation
import UIKit

final class Utils {

    private init() {}

    static let appName =
        Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ?? ""

    static let versionNumber =
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

    static let buildNumber =
        Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""

    static func buildAlert(_ title: String, _ message: String) -> UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        return alert
    }
}
