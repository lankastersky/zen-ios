//
//  ChallengesProvider.swift
//  zen
//
//  Created by Anton Popov on 6/27/18.
//  Copyright © 2018 Anton Popov. All rights reserved.
//

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
class ChallengesProvider {

    private static let challengeFileName: String = "challenges"

    /// Singleton
    static let shared = ChallengesProvider()

    private lazy var storage = Storage.storage()
    private var _challenges: [String: Challenge]

    var challenges: [String: Challenge] {
        get { return _challenges }
        set {}
    }
    /// Private to protect singleton
    private init() {
        _challenges = [:]
    }

    /// Signs in to Firebase using email and password from the config file.
    ///
    /// - Parameter callback: callback with the signed user or error.
    func signIn(callback: @escaping FirebaseSignInCallback) {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist") else {
            print("Failed to load config file")
            return
        }
        guard let constants = NSDictionary(contentsOfFile: path) else {
            print("Failed to parse config file")
            return
        }
        guard let email = constants["email"] as? String else {
            print("Failed to get email")
            return
        }
        guard let password = constants["password"] as? String else {
            print("Failed to get password")
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
    /// - Throws: ServiceError if failed to download or parse challenges.
    func loadChallenges(callback: @escaping LoadChallengesCallback) {
        _challenges = [:]
        let zipFileName = "\(ChallengesProvider.challengeFileName).zip"
        // There is no easy way to decompress zip data directly to memory. So storing it as a
        // temporary file, unzip to another file and read to NSData.
        let localURL = ChallengesProvider.zippedChallengesFilePath(zipFileName)
        let fileRef = self.storage.reference().child(zipFileName)

        fileRef.write(toFile: localURL) { url, error in
            if let error = error {
                callback(nil, error)
            } else {
                do {
                    let unzippedData = try ChallengesProvider
                        .unzip(url!, "\(ChallengesProvider.challengeFileName).json")
                    self._challenges = try ChallengesProvider.parseChallenges(data: unzippedData)
                    callback(self._challenges, nil)
                } catch {
                    callback(nil, error)
                }
            }
        }
    }

    private class func unzip(_ sourcePath: URL, _ fileName: String) throws -> Data {
        let unzipDirectory = try Zip.quickUnzipFile(sourcePath)
        let unzipURL = URL(string: "\(unzipDirectory)/\(fileName)")
        return try Data(contentsOf: unzipURL!)
    }

    private class func parseChallenges(data: Data?) throws -> [String: Challenge] {
        return try JSONDecoder().decode([String: Challenge].self, from: data!)
    }

    private class func zippedChallengesFilePath(_ filename: String) -> URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let filePath = "file:\(documentsDirectory)/\(filename)"
        return URL(string: filePath)!
    }
}
