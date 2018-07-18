import Foundation

/// Stores-restores challenges data persistently
final class ChallengesArchiveService {

    func storeCurrentChallenge(_ challenge: Challenge?) {
        // TODO: implement
    }

    func restoreCurrentChallenge() -> Challenge? {
        // TODO: implement
        return nil
    }

    func storeChallenges(_ challenges: [Challenge]) {
        // TODO: implement
    }

    func restoreChallenges() -> [Challenge]? {
        // TODO: implement
        return nil
    }

    func storeLevel(_ level: ChallengeLevel) {
        // TODO: implement
    }

    func restoreLevel() -> ChallengeLevel {
        return .low
    }

    func storeCurrentChallengeShownTime(_ timeSinceEpoch: TimeInterval) {
        // TODO: implement
    }

    func restoreCurrentChallengeShownTime() -> TimeInterval {
        // TODO: implement
        return 0
    }

    func storeChallengeData(_ challengesDictionary: [String: Challenge]) {
        // TODO: implement
    }

    func restoreChallengeData(_ challengesDictionary: [String: Challenge]) {
        // TODO: implement
    }
}
