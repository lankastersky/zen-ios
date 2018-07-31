import Firebase
import Foundation
import Zip

typealias LoadChallengesCallback = (_ challenges: [String: Challenge]?, _ error: Error?) -> Void
typealias FirebaseSignInCallback = (_ user: User?, _ error: Error?) -> Void

/// Base error protocol for Service Layer
enum ServiceError: Error {
    case runtimeError(String)
}

/// Loads challenges from Firebase
final class FirebaseService {

    private static let challengesFileName = "challenges_en"

    private lazy var storage = Storage.storage()

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
        var challenges: [String: Challenge] = [:]
        let zipFileName = "\(FirebaseService.challengesFileName).zip"
        // There is no easy way to decompress zip data directly to memory. So storing it as a
        // temporary file, unzip to another file and read to NSData.
        guard let localURL = FirebaseService.zippedChallengesFilePath(zipFileName) else {
            callback(nil, ServiceError.runtimeError("Failed to unzip challenges"))
            return
        }
        let fileRef = storage.reference().child(zipFileName)

        fileRef.write(toFile: localURL) { url, error in
            if let error = error {
                callback(nil, error)
            } else if let url = url {
                do {
                    let unzippedData = try FirebaseService
                        .unzip(url, "\(FirebaseService.challengesFileName).json")
                    challenges = try FirebaseService.parseChallenges(data: unzippedData)
                    callback(challenges, nil)
                } catch {
                    callback(nil, error)
                }
            } else {
                callback(nil, ServiceError.runtimeError("Failed to get URL of zip file"))
            }
        }
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
