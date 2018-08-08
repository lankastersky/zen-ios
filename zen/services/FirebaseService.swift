import Firebase
import Foundation
import Zip

typealias LoadChallengesCallback = (_ error: Error?) -> Void
typealias FirebaseSignInCallback = (_ user: User?, _ error: Error?) -> Void

/// Loads challenges from Firebase
final class FirebaseService {

    private static let challengesFileName = "challenges_en"
    private static let loadAfterDays = 7
    private static let lastLoadTimeKey = "last_load_time"

    private lazy var storage = Storage.storage()
    private var storageService: StorageService
    private var challengesService: ChallengesService

    init(_ storageService: StorageService, _ challengesService: ChallengesService) {
        self.storageService = storageService
        self.challengesService = challengesService
    }

    /// Signs in to Firebase using email and password from the config file.
    ///
    /// - Parameter callback: callback with the signed user or error.
    func signIn(callback: @escaping FirebaseSignInCallback) {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist") else {
            callback(nil, ServiceError.runtimeError("Failed to load config file"))
            return
        }
        guard let constants = NSDictionary(contentsOfFile: path) else {
            callback(nil, ServiceError.runtimeError("Failed to parse config file"))
            return
        }
        guard let email = constants["email"] as? String else {
            callback(nil, ServiceError.runtimeError("Failed to get email"))
            return
        }
        guard let password = constants["password"] as? String else {
            callback(nil, ServiceError.runtimeError("Failed to get password"))
            return
        }

        let user = Auth.auth().currentUser
        if user == nil {
            Auth.auth().signIn(withEmail: email, password: password) { user, error in
                callback(user?.user, error)
            }
        } else {
            callback(user, nil)
        }
    }

    /// Loads challenges from Firebase Storage as a zipped json file
    ///
    /// - Parameter callback: callback with the list of challenges
    func loadChallenges(callback: @escaping LoadChallengesCallback) {
        if !isTimeToLoad() {
            challengesService.restoreChallenges()
            callback(nil)
            return
        }
        var challenges: [String: Challenge] = [:]
        let zipFileName = "\(FirebaseService.challengesFileName).zip"
        // There is no easy way to decompress zip data directly to memory. So storing it as a
        // temporary file, unzip to another file and read to NSData.
        guard let localURL = FirebaseService.zippedChallengesFilePath(zipFileName) else {
            callback(ServiceError.runtimeError("Failed to unzip challenges"))
            return
        }
        let fileRef = storage.reference().child(zipFileName)

        fileRef.write(toFile: localURL) { url, error in
            if let error = error {
                callback(error)
            } else if let url = url {
                do {
                    let unzippedData = try FirebaseService
                        .unzip(url, "\(FirebaseService.challengesFileName).json")
                    challenges = try FirebaseService.parseChallenges(data: unzippedData)
                    self.challengesService.storeChallenges(challenges)
                    self.storeLastLoadTime()
                    callback(nil)
                } catch {
                    callback(error)
                }
            } else {
                callback(ServiceError.runtimeError("Failed to get URL of zip file"))
            }
        }
    }

    private func isTimeToLoad() -> Bool {
        let lastLoadTime = restoreLastLoadTime()
        if lastLoadTime.timeIntervalSince1970 == 0 {
            return true
        }
        #if DEBUG_TIME
        // Several sec after current time to not wait
        guard let nextLoadTime =
            Calendar.current.date(byAdding: .second, value: 15, to: lastLoadTime) else {
                print("Failed to get next load time for Firebase service")
                return true
        }
        #else
        guard let nextLoadTime = Calendar.current.date(
            byAdding: .day, value: FirebaseService.loadAfterDays, to: lastLoadTime) else {
                print("Failed to get next load time for Firebase service")
                return true
        }
        #endif
        let now = Date()
        return now > nextLoadTime
    }

    private func storeLastLoadTime() {
        let timeSinceEpoch = Date().timeIntervalSince1970
        storageService.set(timeSinceEpoch, forKey: FirebaseService.lastLoadTimeKey)
    }

    private func restoreLastLoadTime() -> Date {
        let lastLoadTimeSinceEpoch = storageService.double(forKey: FirebaseService.lastLoadTimeKey)
        return Date(timeIntervalSince1970: lastLoadTimeSinceEpoch)
    }
}

/// ChallengesProvider + zip operations.
extension FirebaseService {

    private static func unzip(_ sourcePath: URL, _ fileName: String) throws -> Data? {
        let unzipDirectory = try Zip.quickUnzipFile(sourcePath)
        if let unzipURL = URL(string: "\(unzipDirectory)/\(fileName)") {
            return try Data(contentsOf: unzipURL)
        }
        return nil
    }

    private static func parseChallenges(data: Data?) throws -> [String: Challenge] {
        return try JSONDecoder().decode([String: Challenge].self, from: data!)
    }

    private static func zippedChallengesFilePath(_ filename: String) -> URL? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let documentsDirectory = paths.first else {
            return nil
        }
        let filePath = "file:\(documentsDirectory)/\(filename)"
        return URL(string: filePath)
    }
}
