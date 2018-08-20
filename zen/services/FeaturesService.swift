import Foundation

/// Detects available features (free, paid, etc.)
final class FeaturesService {

    private static let appVersionKey = "app_version"

    private let storageService: StorageService

    init(_ storageService: StorageService) {
        self.storageService = storageService
    }

    convenience init() {
        self.init(StorageService())
    }

    func storeAppVersion() {
        if let storedVersion = storageService.string(forKey: FeaturesService.appVersionKey) {
            print("Stored app version: \(storedVersion)")
        } else {
            storageService.set(Utils.versionNumber, forKey: FeaturesService.appVersionKey)
        }
    }
}
