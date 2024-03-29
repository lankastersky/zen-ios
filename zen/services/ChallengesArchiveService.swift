import Foundation

/// Stores-restores challenges data persistently
final class ChallengesArchiveService {

    private static let challengeDataKey = "challenge_data"
    private static let challengesKey = "challenges"
    private static let currentChallengeShownTimeKey = "current_challenge_shown_time"
    private static let currentChallengeKey = "current_challenge"
    private static let currentLevelKey = "current_challenge_level"

    private let storageService: StorageService
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    init(_ storageService: StorageService) {
        self.storageService = storageService
        self.jsonEncoder = JSONEncoder()
        self.jsonDecoder = JSONDecoder()
    }

    convenience init() {
        self.init(StorageService())
    }

    func storeCurrentChallenge(_ challenge: Challenge?) {
        guard let encoded = try? jsonEncoder.encode(challenge) else {
            assertionFailure("Failed to store current challenge")
            return
        }
        storageService.set(encoded, forKey: ChallengesArchiveService.currentChallengeKey)
    }

    func restoreCurrentChallenge() -> Challenge? {
        guard let challengeData =
            storageService.data(forKey: ChallengesArchiveService.currentChallengeKey) else {
                print("No current challenge to restore")
                return nil
        }
        guard let challenge =
            ((try? jsonDecoder.decode(Challenge?.self, from: challengeData)) as Challenge??) else {
                assertionFailure("Failed to restore challenge data")
                return nil
        }
        return challenge
    }

    func storeChallenges(_ challenges: [Challenge]) {
        guard let encoded = try? jsonEncoder.encode(challenges) else {
            assertionFailure("Failed to store challenges")
            return
        }
        storageService.set(encoded, forKey: ChallengesArchiveService.challengesKey)
    }

    func restoreChallenges() -> [Challenge]? {
        guard let challengesData =
            storageService.data(forKey: ChallengesArchiveService.challengesKey) else {
                assertionFailure("Failed to restore challenges")
                return nil
        }
        guard let challengesArray =
            try? jsonDecoder.decode([Challenge].self, from: challengesData) else {
                assertionFailure("Failed to restore challenges")
                return nil
        }
        return challengesArray
    }

    func storeLevel(_ level: ChallengeLevel) {
        storageService.set(level.rawValue, forKey: ChallengesArchiveService.currentLevelKey)
    }

    func restoreLevel() -> ChallengeLevel {
        guard let level =  ChallengeLevel(
            rawValue: storageService.integer(forKey: ChallengesArchiveService.currentLevelKey)) else {
                assertionFailure("Failed to restore level")
                return .low
        }
        return level
    }

    func storeCurrentChallengeShownTime(_ timeSinceEpoch: TimeInterval) {
        storageService.set(
            timeSinceEpoch, forKey: ChallengesArchiveService.currentChallengeShownTimeKey)
    }

    func restoreCurrentChallengeShownTime() -> TimeInterval {
        return storageService.double(forKey: ChallengesArchiveService.currentChallengeShownTimeKey)
    }

    func storeChallengeData(_ challengesDictionary: [String: Challenge]) {
        var challengeDataArray: [MutableChallengeData] = []
        challengesDictionary.forEach({ arg in
            let (_, challenge) = arg
            challengeDataArray.append(
                MutableChallengeData(
                    challenge.challengeId,
                    challenge.status,
                    challenge.finishedTime,
                    challenge.rating,
                    challenge.comments))
        })
        guard let encoded = try? jsonEncoder.encode(challengeDataArray) else {
            assertionFailure("Failed to store challenge data")
            return
        }
        storageService.set(encoded, forKey: ChallengesArchiveService.challengeDataKey)
    }

    func restoreChallengeData(_ challengesDictionary: [String: Challenge]) -> Bool {
        guard let challengeData =
            storageService.data(forKey: ChallengesArchiveService.challengeDataKey) else {
                print("No challenge data to restore")
                return false
        }
        guard let challengeDataArray =
                try? jsonDecoder.decode([MutableChallengeData].self, from: challengeData) else {
                    assertionFailure("Failed to restore challenge data")
                    return false
        }

        challengeDataArray.forEach({challengeData in
            guard let challenge = challengesDictionary[challengeData.challengeId] else {
                assertionFailure("Failed to restore challenge data")
                return
            }
            challenge.status = challengeData.status
            challenge.finishedTime = challengeData.finishedTime
            challenge.rating = challengeData.rating
            challenge.comments = challengeData.comments
        })
        return true
    }
}
