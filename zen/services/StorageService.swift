import Foundation

/// Key-value storage, uses UserDefaults.
final class StorageService {

    private static let userDefaultsName = "com.hcyclone.zen.challenges_archive_service"

    private var userDefaults: UserDefaults

    init(_ userDefaultsName: String) {
        guard let userDefaults = UserDefaults(suiteName: userDefaultsName) else {
            assertionFailure("Failed to create user defaults")
            self.userDefaults = UserDefaults()
            return
        }
        self.userDefaults = userDefaults
    }

    convenience init() {
        self.init(StorageService.userDefaultsName)
    }

    func set(_ value: Any?, forKey defaultName: String) {
        userDefaults.set(value, forKey: defaultName)
    }

    func data(forKey defaultName: String) -> Data? {
        return userDefaults.data(forKey: defaultName)
    }

    func integer(forKey defaultName: String) -> Int {
        return userDefaults.integer(forKey: defaultName)
    }

    func float(forKey defaultName: String) -> Float {
        return userDefaults.float(forKey: defaultName)
    }

    func double(forKey defaultName: String) -> Double {
        return userDefaults.double(forKey: defaultName)
    }

    func string(forKey defaultName: String) -> String? {
        return userDefaults.string(forKey: defaultName)
    }
}
