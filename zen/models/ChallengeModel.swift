import Foundation

final class ChallengeModel {

    private static let probabilityGetDeclinedChallenge = 1 / 6
    private static let proportionAcceptMediumLavelChallenge = 1 / 3
    private static let proportionAcceptHighLevelChallenge = 2 / 3

    private var challengesMap: [String: Challenge] = [:]
    private var currentChallengeId = ""
    private var currentChallengeShownTime: TimeInterval = 0
    private(set) var currentLevel: ChallengeLevel = ChallengeLevel.low
    private let challengesArchiver = ChallengesArchiver()

    var currentChallenge: Challenge? {
        get {
            return challengesMap[currentChallengeId]
        }
        set {}
    }

    var shownChallengesNumber: Int {
        get {
            let shownNumber: Int = challengesByStatus(ChallengeStatus.shown).count
            return shownNumber + finishedChallenges.count
        }
        set {}
    }

    var finishedChallenges: [Challenge] {
        get {
            return challengesByStatus(ChallengeStatus.finished)
        }
        set {}
    }

    /// Returns challenges sorted by Id.
    var challenges: [Challenge] {
        get {
            let challenges = challengesMap.values
            return challenges.sorted(by: { (left, right) -> Bool in
                left.challengeId < right.challengeId
            })
        }
        set {}
    }

    var restoredCurrentChallenge: Challenge? {
        get {
            return challengesArchiver.restoreCurrentChallenge()
        }
        set {}
    }

    /// Challenge is ready to be accepted before 6pm
    var isTimeToAcceptChallenge: Bool {
        get {
            // TODO: implement
            return true
        }
        set {}
    }

    /// Challenge is ready to be finished today after 6pm
    var isTimeToFinishChallenge: Bool {
        get {
            if currentChallenge?.status == ChallengeStatus.accepted {
                // TODO: implement
            }
            return true
        }
        set {}
    }

    func challenge(_ challengeId: String) -> Challenge? {
        return challengesMap[challengeId]
    }

    func finishedChallengesSortedByTime() -> [Challenge] {
        return finishedChallenges.sorted(by: { (left, right) -> Bool in
            left.finishedTime < right.finishedTime
        })
    }

    func finishedChallengesSortedByTimeDesc() -> [Challenge] {
        return finishedChallenges.sorted(by: { (left, right) -> Bool in
            left.finishedTime > right.finishedTime
        })
    }

    /// Restores challenges from persistent storage and selects current challenge if needed
    func restoreChallenges() {
        if challengesMap.isEmpty {
            if let challenges = challengesArchiver.restoreChallenges() {
                for challenge in challenges {
                    challengesMap[challenge.challengeId] = challenge
                }
            }
        }
        selectChallengeIfNeeded()
    }

    /// Persistently stores challenges and refreshes challenges map
    func storeChallenges(_ challenges: [Challenge]) {
        challengesMap.removeAll()
        for challenge in challenges {
            challengesMap[challenge.challengeId] = challenge
        }
        challengesArchiver.storeChallenges(challenges)
    }

    /// Sets challenge status as 'shown' if current status is 'unknown'
    func markChallengeShown(_ challengeId: String) {
        // TODO: remove asserts after testing
        assert(
            currentChallengeId != challengeId,
            "Can't mark current challenge as shown. ChallengeId is not current challenge:"
                + " \(challengeId)")
        assert(
            currentChallenge?.status != nil,
            "Can't mark current challenge as shown. Challenge status is not unknown:"
                + " \(String(describing: currentChallenge?.status))")

        currentChallengeShownTime = NSDate().timeIntervalSince1970
        updateCurrentChallenge()
        storeState()
    }

    func markChallengeAccepted(_ challengeId: String) {
        assert(
            currentChallengeId != challengeId,
            "Can't mark current challenge as accepted. ChallengeId is not current challenge:"
                + " \(challengeId)")
        assert(
            currentChallenge?.status != ChallengeStatus.shown,
            "Can't mark current challenge as shown. Challenge status is not shown:"
                + " \(String(describing: currentChallenge?.status))")

        updateCurrentChallenge()
        storeState()
    }

    func markChallengeFinished(_ challengeId: String) {
        assert(
            currentChallengeId != challengeId,
            "Can't mark current challenge as finished. ChallengeId is not current challenge:"
                + " \(challengeId)")
        assert(
            currentChallenge?.status != ChallengeStatus.accepted,
            "Can't mark current challenge as finished. Challenge status is not accepted:"
                + " \(String(describing: currentChallenge?.status))")

        updateCurrentChallenge()
        storeState()
    }

    /// Checks if the level of the given challenge is higher than the current one. Updates and
    /// stores persistently the current one if needed.
    ///
    /// - Parameter challengeId: challenge id to check the level of
    // TODO: check level-up when generating chellenges of a new level
    func checkLevelUp(_ challengeId: String) -> Bool {
        assert(
            currentChallengeId != challengeId,
            "Can't mark current challenge as finished. ChallengeId is not current challenge:"
                + " \(challengeId)")

        guard let currentChallengeLevel = currentChallenge?.level else {
            print("Failed to check level-up. Current challenge level is null.")
            return false
        }
        assert(
            currentChallengeLevel.rawValue >= ChallengeLevel.low.rawValue,
            "The level of the current level is undefined")

        if currentChallengeLevel.rawValue > currentLevel.rawValue {
            currentLevel = currentChallengeLevel
            challengesArchiver.storeLevel(currentLevel)
            return true
        }
        return false
    }

    private func updateCurrentChallenge() {
        // TODO: implement
    }

    private func selectChallengeIfNeeded() {
        // TODO: implement
    }

    private func storeState() {
        // TODO: implement
    }

    private func challengesByStatus(_ challengeStatus: ChallengeStatus) -> [Challenge] {
        var challenges: [Challenge] = []
        for challenge in challengesMap.values where challenge.status == challengeStatus {
            challenges.append(challenge)
        }
        return challenges
    }
}
