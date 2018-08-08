import Foundation

final class Utils {

    static let appName =
        Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ?? ""

    static let versionNumber =
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

    static let buildNumber =
        Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
}
