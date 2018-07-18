import Foundation

/// Stores-restores challenges data persistently
final class ChallengesArchiveService {

    private static let challengeDataKey = "challenge_data"
    private static let challengesKey = "challenges"
    private static let currentChallengeShownTimeKey = "current_challenge_shown_time"
    private static let currentChallengeKey = "current_challenge"
    private static let currentLevelKey = "current_challenge_level"

    private var userDefaults: UserDefaults

    init(_ userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    convenience init() {
        self.init(UserDefaults.standard)
    }

    func storeCurrentChallenge(_ challenge: Challenge?) {
        guard let encoded = try? JSONEncoder().encode(challenge) else {
            assertionFailure("Failed to store current challenge")
            return
        }
        userDefaults.set(encoded, forKey: ChallengesArchiveService.currentChallengeKey)

    }

    func restoreCurrentChallenge() -> Challenge? {
        guard let challengeData =
            userDefaults.data(forKey: ChallengesArchiveService.currentChallengeKey) else {
                assertionFailure("Failed to decode current challenge")
                return nil
        }
        guard let challenge =
            try? JSONDecoder().decode(Challenge.self, from: challengeData) else {
                assertionFailure("Failed to decode challenge data")
                return nil
        }
        return challenge
    }

    func storeChallenges(_ challenges: [Challenge]) {
        guard let encoded = try? JSONEncoder().encode(challenges) else {
            assertionFailure("Failed to store challenges")
            return
        }
        userDefaults.set(encoded, forKey: ChallengesArchiveService.challengesKey)
    }

    func restoreChallenges() -> [Challenge]? {
        guard let challengesData =
            userDefaults.data(forKey: ChallengesArchiveService.challengesKey) else {
                assertionFailure("Failed to decode challenges")
                return nil
        }
        guard let challengesArray =
            try? JSONDecoder().decode([Challenge].self, from: challengesData) else {
                assertionFailure("Failed to decode challenges")
                return nil
        }
        return challengesArray
    }

    func storeLevel(_ level: ChallengeLevel) {
        userDefaults.set(level, forKey: ChallengesArchiveService.currentLevelKey)
    }

    func restoreLevel() -> ChallengeLevel {
        guard let level =  ChallengeLevel(
            rawValue: userDefaults.integer(forKey: ChallengesArchiveService.currentLevelKey)) else {
                assertionFailure("Failed to decode level")
                return .low
        }
        return level
    }

    func storeCurrentChallengeShownTime(_ timeSinceEpoch: TimeInterval) {
        userDefaults.set(
            timeSinceEpoch, forKey: ChallengesArchiveService.currentChallengeShownTimeKey)
    }

    func restoreCurrentChallengeShownTime() -> TimeInterval {
        return userDefaults.double(forKey: ChallengesArchiveService.currentChallengeShownTimeKey)
    }

    func storeChallengeData(_ challengesDictionary: [String: Challenge]) {
        var challengeDataArray: [MutableChallengeData] = []
        challengesDictionary.forEach({ arg in
            let (_, challenge) = arg
            challengeDataArray.append(
                MutableChallengeData(
                    challenge.challengeId,
                    //challenge.status,
                    challenge.finishedTime,
                    challenge.rating,
                    challenge.comments))
        })
        guard let encoded = try? JSONEncoder().encode(challengeDataArray) else {
            assertionFailure("Failed to store challenge data")
            return
        }
        userDefaults.set(encoded, forKey: ChallengesArchiveService.challengeDataKey)
    }

    func restoreChallengeData(_ challengesDictionary: [String: Challenge]) {
        guard let challengeData =
            userDefaults.data(forKey: ChallengesArchiveService.challengeDataKey) else {
                assertionFailure("Failed to decode challenge data")
                return
        }
        guard let challengeDataArray =
                try? JSONDecoder().decode([MutableChallengeData].self, from: challengeData) else {
                    assertionFailure("Failed to decode challenge data")
                    return
        }

        challengeDataArray.forEach({challengeData in
            guard let challenge = challengesDictionary[challengeData.challengeId] else {
                assertionFailure("Failed to decode challenge data")
                return
            }
            //challenge.status = challengeData.status
            challenge.finishedTime = challengeData.finishedTime
            challenge.rating = challengeData.rating
            challenge.comments = challengeData.comments
        })
    }
}
