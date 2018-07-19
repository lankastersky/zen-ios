import Foundation

final class ChallengesService {

    private static let calendar = Calendar.current

    private static let probabilityGetDeclinedChallenge = 1.0 / 6
    private static let proportionAcceptMediumLavelChallenge = 1.0 / 3
    private static let proportionAcceptHighLevelChallenge = 2.0 / 3

    private var challengesDictionary: [String: Challenge] = [:]
    private var currentChallengeId: String?
    private var currentChallengeShownTime: TimeInterval = 0
    private(set) var currentLevel: ChallengeLevel = .low
    private let challengesArchiveService = ChallengesArchiveService()

    var currentChallenge: Challenge? {
        get {
            if let currentChallengeId = currentChallengeId {
                return challengesDictionary[currentChallengeId]
            }
            return nil
        }
        set {}
    }

    var shownChallengesNumber: Int {
        get {
            let shownNumber = challengesByStatus(.shown).count
            return shownNumber + finishedChallenges.count
        }
        set {}
    }

    var finishedChallenges: [Challenge] {
        get { return challengesByStatus(.finished) }
        set {}
    }

    /// Returns challenges sorted by Id.
    var sortedChallenges: [Challenge] {
        get { return challengesDictionary.values.sorted(by: { $0.challengeId < $1.challengeId }) }
        set {}
    }

    var restoredCurrentChallenge: Challenge? {
        get { return challengesArchiveService.restoreCurrentChallenge() }
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
            if currentChallenge?.status == .accepted {
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
        return challengesDictionary[challengeId]
    }

    func finishedChallengesSortedByTime() -> [Challenge] {
        return finishedChallenges.sorted(by: { $0.finishedTime < $1.finishedTime })
    }

    func finishedChallengesSortedByTimeDesc() -> [Challenge] {
        return finishedChallenges.sorted(by: { $0.finishedTime > $1.finishedTime })
    }

    /// Persistently stores challenges and refreshes challenges dictionary
    func storeChallenges(_ challengesDictionary: [String: Challenge]) {
        self.challengesDictionary = challengesDictionary
        challengesArchiveService.storeChallenges(Array(challengesDictionary.values))
    }

    /// Restores challenges from persistent storage and selects current challenge if needed
    func restoreChallenges() {
        if challengesDictionary.isEmpty {
            if let challenges = challengesArchiveService.restoreChallenges() {
                challenges.forEach({ challenge in
                    challengesDictionary[challenge.challengeId] = challenge
                })
            }
        }
        selectChallengeIfNeeded()
    }

    private func storeState() {
        challengesArchiveService.storeChallengeData(challengesDictionary)
        challengesArchiveService.storeCurrentChallenge(currentChallenge)
        challengesArchiveService.storeCurrentChallengeShownTime(currentChallengeShownTime)
        challengesArchiveService.storeLevel(currentLevel)
    }

    private func restoreState() {
        challengesArchiveService.restoreChallengeData(challengesDictionary)
        if let challenge = challengesArchiveService.restoreCurrentChallenge() {
            currentChallengeId = challenge.challengeId
        }
        currentChallengeShownTime = challengesArchiveService.restoreCurrentChallengeShownTime()
        currentLevel = challengesArchiveService.restoreLevel()
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
            currentChallenge?.status != .shown,
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
        assert(currentChallenge?.status != .accepted,
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
            challengesArchiveService.storeLevel(currentLevel)
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

        if currentChallengeId == nil {
            newChallengeRequired = true
        } else {

            assert(
                currentChallenge != nil,
                "Failed to select current challenge \(String(describing: currentChallengeId))"
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
            currentChallengeId = newChallengeId
        }
        assert(currentChallenge != nil, "Failed to select current challenge")
        print(
            "New challenge id: \(String(describing: currentChallengeId));"
                + " content: \(String(describing: currentChallenge?.content))"
        )
        storeState()
    }

    /// If there are nonfinished challenges, get a random challenge from them taking into account
    /// levels.
    /// Else if there are declined challenges, get a challenge from them with some probability.
    /// Else get a challenge from all not equal to previous one.
    ///
    /// - Returns: new challenge Id
    private var newChallengeId: String {
        get {
            var challenge: Challenge
            let nonFinishedChallenges = challengesByStatus(nil) + challengesByStatus(.accepted)
                + challengesByStatus(.shown)
            let filteredNonFinishedChallenges = challengesOfCurrentLevel(nonFinishedChallenges)

            if !(filteredNonFinishedChallenges.isEmpty) {
                challenge = ChallengesService.randomChallenge(filteredNonFinishedChallenges)
                return challenge.challengeId
            }
            let declinedChallenges = challengesByStatus(.declined)
            if !declinedChallenges.isEmpty
                && drand48() < ChallengesService.probabilityGetDeclinedChallenge {
                // Don't force the user to take a declined challenge again. Show declined challenges
                // with some probability
                print("Assign random declined challenge")
                challenge = ChallengesService.randomChallenge(declinedChallenges)
                return challenge.challengeId
            }
            // All challenges are finished. Return a random old one not equal to previous one
            let challengesArray = Array(challengesDictionary.values)

            challenge = ChallengesService.randomChallenge(challengesArray)
            while challenge.challengeId == currentChallenge?.challengeId {
                challenge = ChallengesService.randomChallenge(challengesArray)
            }
            return challenge.challengeId
        }
        set {}
    }

    /// Low-level challenges are available from the beginning.
    /// Medium-level challenges are available when 1/3 of challenges are finished.
    /// High-level challenges are available when 2/3 of challenges are finished.
    ///
    /// - Parameter challenges: chellenges to select from
    /// - Returns: challenges of current and lower levels
    private func challengesOfCurrentLevel(_ nonFinishedChallenges: [Challenge]) -> [Challenge] {
        let challenges = Array(challengesDictionary.values)
        guard !challenges.isEmpty else {
            return []
        }
        let percentOfFinishedChallenges =
            Double(challenges.count - nonFinishedChallenges.count) / Double(challenges.count)
        let acceptMediumChallenges =
            percentOfFinishedChallenges >= ChallengesService.proportionAcceptMediumLavelChallenge
        let acceptHighChallenges =
            percentOfFinishedChallenges >= ChallengesService.proportionAcceptHighLevelChallenge

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
        return challengesDictionary.values.filter { $0.status == challengeStatus }
    }

    private static func randomChallenge(_ challenges: [Challenge]) -> Challenge {
        assert(!challenges.isEmpty, "Failed to get random challenge from empty array")
        let randomIndex = Int(arc4random_uniform(UInt32(challenges.count)))
        return challenges[randomIndex]
    }
}
