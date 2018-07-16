import Foundation

final class ChallengesModel {

    private static let calendar = Calendar.current

    private static let probabilityGetDeclinedChallenge = 1.0 / 6
    private static let proportionAcceptMediumLavelChallenge = 1.0 / 3
    private static let proportionAcceptHighLevelChallenge = 2.0 / 3

    private var challengesMap: [String: Challenge] = [:]
    private var currentChallengeId = ""
    private var currentChallengeShownTime: TimeInterval = 0
    private(set) var currentLevel: ChallengeLevel = ChallengeLevel.low
    private let challengesArchiver = ChallengesArchiver()

    var currentChallenge: Challenge? {
        get { return challengesMap[currentChallengeId] }
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
        get { return challengesByStatus(ChallengeStatus.finished) }
        set {}
    }

    /// Returns challenges sorted by Id.
    var sortedChallenges: [Challenge] {
        get {
            let challenges = challengesMap.values
            return challenges.sorted(by: { (left, right) -> Bool in
                left.challengeId < right.challengeId
            })
        }
        set {}
    }

    var restoredCurrentChallenge: Challenge? {
        get { return challengesArchiver.restoreCurrentChallenge() }
        set {}
    }

    /// Challenge is ready to be accepted before 6pm
    var isTimeToAcceptChallenge: Bool {
        get { return Date.dateBefore6pm(currentChallengeShownTime) }
        set {}
    }

    /// Challenge is ready to be finished today after 6pm
    var isTimeToFinishChallenge: Bool {
        get {
            if currentChallenge?.status == ChallengeStatus.accepted {
                return !Date.dateBefore6pm(currentChallengeShownTime)
            }
            return true
        }
        set {}
    }

    /// Challenge expires at midnight of the next day.
    private var isChallengeTimeExpired: Bool {
        get { return !Date.dateBeforeNextMidnight(currentChallengeShownTime) }
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

    /// Persistently stores challenges and refreshes challenges map
    func storeChallenges(_ challengesMap: [String: Challenge]) {
        self.challengesMap = challengesMap
        challengesArchiver.storeChallenges(Array(challengesMap.values))
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

    private func storeState() {
        challengesArchiver.storeChallengeData(challengesMap)
        challengesArchiver.storeCurrentChallenge(currentChallenge)
        challengesArchiver.storeCurrentChallengeShownTime(currentChallengeShownTime)
        challengesArchiver.storeLevel(currentLevel)
    }

    private func restoreState() {
        challengesArchiver.restoreChallengeData(challengesMap)
        if let challenge = challengesArchiver.restoreCurrentChallenge() {
            currentChallengeId = challenge.challengeId
        }
        currentChallengeShownTime = challengesArchiver.restoreCurrentChallengeShownTime()
        currentLevel = challengesArchiver.restoreLevel()
    }

    /// Sets challenge status as 'shown' if current status is 'unknown'
    func markChallengeShown(_ challengeId: String) {
        // TODO: remove asserts after testing
        assert(currentChallengeId != challengeId,
            "Can't mark current challenge as shown. ChallengeId is not current challenge:"
                + " \(challengeId)"
        )
        assert(currentChallenge?.status != nil,
            "Can't mark current challenge as shown. Challenge status is not unknown:"
                + " \(String(describing: currentChallenge?.status))"
        )
        currentChallengeShownTime = NSDate().timeIntervalSince1970
        updateCurrentChallenge()
        storeState()
    }

    func markChallengeAccepted(_ challengeId: String) {
        assert(currentChallengeId != challengeId,
            "Can't mark current challenge as accepted. ChallengeId is not current challenge:"
                + " \(challengeId)"
        )
        assert(
            currentChallenge?.status != ChallengeStatus.shown,
            "Can't mark current challenge as shown. Challenge status is not shown:"
                + " \(String(describing: currentChallenge?.status))"
        )
        updateCurrentChallenge()
        storeState()
    }

    func markChallengeFinished(_ challengeId: String) {
        assert(currentChallengeId != challengeId,
            "Can't mark current challenge as finished. ChallengeId is not current challenge:"
                + " \(challengeId)"
        )
        assert(currentChallenge?.status != ChallengeStatus.accepted,
            "Can't mark current challenge as finished. Challenge status is not accepted:"
                + " \(String(describing: currentChallenge?.status))"
        )
        updateCurrentChallenge()
        storeState()
    }

    /// Checks if the level of the given challenge is higher than the current one. Updates and
    /// stores persistently the current one if needed.
    ///
    /// - Parameter challengeId: challenge id to check the level of
    // TODO: check level-up when generating chellenges of a new level
    func checkLevelUp(_ challengeId: String) -> Bool {
        assert(currentChallengeId != challengeId,
            "Can't mark current challenge as finished. ChallengeId is not current challenge:"
                + " \(challengeId)"
        )

        guard let currentChallengeLevel = currentChallenge?.level else {
            print("Failed to check level-up. Current challenge level is null.")
            return false
        }
        assert(currentChallengeLevel.rawValue >= ChallengeLevel.low.rawValue,
            "The level of the current level is undefined"
        )

        if currentChallengeLevel.rawValue > currentLevel.rawValue {
            currentLevel = currentChallengeLevel
            challengesArchiver.storeLevel(currentLevel)
            return true
        }
        return false
    }

    private func updateCurrentChallenge() {
        currentChallenge?.updateStatus()
        // TODO: send analytics
    }

    /// Updates the status of current challenge and selects new one if needed
    private func selectChallengeIfNeeded() {
        restoreState()

        var newChallengeRequired = false

        if currentChallengeId == "" {
            newChallengeRequired = true
        } else {
            assert(
                challengesMap[currentChallengeId] != nil,
                "Failed to select current challenge with id \(currentChallengeId)"
            )
            switch currentChallenge?.status {
            case nil:
                break
            case .shown?:
                if isChallengeTimeExpired {
                    currentChallenge?.decline()
                    newChallengeRequired = true
                }
            case .accepted?:
                if isChallengeTimeExpired {
                    currentChallenge?.reset()
                    newChallengeRequired = true
                }
            case .finished?, .declined?:
                if isChallengeTimeExpired {
                    newChallengeRequired = true
                }
            }
        }
        if newChallengeRequired {
            currentChallengeId = newChallengeId()
        }
        assert(currentChallenge != nil, "Failed to select current challenge")
        print(
            "New challenge id: \(currentChallengeId);"
                + " content: \(String(describing: currentChallenge?.content))"
        )
        storeState()
    }

    /// If there are nonfinished challenges, get random challenge from them taking into account
    /// levels.
    /// Else if there are declined challenges, get random challenge from them with some probability.
    /// Else get random challenge from all not equal to previous one.
    ///
    /// - Returns: new challenge Id
    private func newChallengeId() -> String {
        var challenge: Challenge
        let nonFinishedChallenges = challengesByStatus(nil) + challengesByStatus(.accepted)
            + challengesByStatus(.shown)
        let filteredNonFinishedChallenges = challengesOfCurrentLevel(nonFinishedChallenges)

        if !(filteredNonFinishedChallenges.isEmpty) {
            challenge = ChallengesModel.randomChallenge(filteredNonFinishedChallenges)
        } else {
            let declinedChallenges = challengesByStatus(.declined)
            if !declinedChallenges.isEmpty
                && drand48() < ChallengesModel.probabilityGetDeclinedChallenge {
                // Don't force user to take a declined challenge again. Show declined challenges
                // with some probability
                print("Assign random declined challenge")
                challenge = ChallengesModel.randomChallenge(declinedChallenges)
            } else {
                // All challenges are finished. Return random old one
                let challengesArray = Array(challengesMap.values)

                challenge = ChallengesModel.randomChallenge(challengesArray)
                while challenge.challengeId == currentChallenge?.challengeId {
                    challenge = ChallengesModel.randomChallenge(challengesArray)
                }
            }
        }
        return challenge.challengeId
    }

    /// Low-level challenges are available from the beginning.
    /// Medium-level challenges are available when 1/3 of challenges are finished.
    /// High-level challenges are available when 2/3 of challenges are finished.
    ///
    /// - Parameter challenges: chellenges to select from
    /// - Returns: challenges of current and lower levels
    private func challengesOfCurrentLevel(_ nonFinishedChallenges: [Challenge]) -> [Challenge] {
        let challenges = Array(challengesMap.values)
        if challenges.isEmpty {
            return []
        }
        let percentOfFinishedChallenges =
            Double(challenges.count - nonFinishedChallenges.count) / Double(challenges.count)
        let acceptMediumChallenges =
            percentOfFinishedChallenges >= ChallengesModel.proportionAcceptMediumLavelChallenge
        let acceptHighChallenges =
            percentOfFinishedChallenges >= ChallengesModel.proportionAcceptHighLevelChallenge

        var challengesOfCurrentLevel: [Challenge] = []
        for challenge in nonFinishedChallenges {
            switch challenge.level {
            case .low:
                challengesOfCurrentLevel.append(challenge)
            case .medium:
                if acceptMediumChallenges {
                    challengesOfCurrentLevel.append(challenge)
                }
            case .high:
                if acceptHighChallenges {
                    challengesOfCurrentLevel.append(challenge)
                }
            }
        }
        return challengesOfCurrentLevel
    }

    private func challengesByStatus(_ challengeStatus: ChallengeStatus?) -> [Challenge] {
        var challenges: [Challenge] = []
        for challenge in challengesMap.values where challenge.status == challengeStatus {
            challenges.append(challenge)
        }
        return challenges
    }

    private class func randomChallenge(_ challenges: [Challenge]) -> Challenge {
        assert(!challenges.isEmpty, "Failed to get random challenge from empty array")
        let randomIndex = Int(arc4random_uniform(UInt32(challenges.count)))
        return challenges[randomIndex]
    }
}