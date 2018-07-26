import XCTest
@testable import zen

import Foundation

final class ChallengesArchiveServiceTest: XCTestCase {
    private static let userDefaultsName = "challenges_archive_service_test"

    private var archiveService: ChallengesArchiveService?
    private var userDefaults: UserDefaults?

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: ChallengesArchiveServiceTest.userDefaultsName)
        archiveService = ChallengesArchiveService(userDefaults!)
    }

    func test_store_restore_CurrentChallengeShownTime() {
        let shownTime = TimeInterval(1)

        archiveService?.storeCurrentChallengeShownTime(shownTime)
        let restoredShownTime = archiveService?.restoreCurrentChallengeShownTime()

        XCTAssertEqual(shownTime, restoredShownTime, "shown time didn't restore")
    }

    func test_store_restore_level() {
        let level = ChallengeLevel.high

        archiveService?.storeLevel(level)
        let restoredLevel = archiveService?.restoreLevel()

        XCTAssertEqual(level, restoredLevel, "level didn't restore")
    }

    func test_store_restore_currentChallenge() {
        let challenge = ChallengesArchiveServiceTest.buildChallenge()

        archiveService?.storeCurrentChallenge(challenge)
        let restoredChallenge = archiveService?.restoreCurrentChallenge()

        ChallengesArchiveServiceTest.assertChallenges(challenge, restoredChallenge)
    }

    func test_store_restore_challenges() {
        let challenge = ChallengesArchiveServiceTest.buildChallenge()

        archiveService?.storeChallenges([challenge])
        guard let restoredChallenges = archiveService?.restoreChallenges() else {
            assertionFailure("Failed to restore challenges")
            return
        }

        ChallengesArchiveServiceTest.assertChallenges(challenge, restoredChallenges[0])
    }

    func test_store_restore_challengeData() {
        let challenge = ChallengesArchiveServiceTest.buildChallenge()
        let finishedTime = challenge.finishedTime
        let rating = challenge.rating
        let status = challenge.status
        let comments = challenge.comments

        archiveService?.storeChallengeData([challenge.challengeId: challenge])

        challenge.finishedTime = 0
        challenge.rating = nil
        challenge.status = nil
        challenge.comments = nil

        archiveService?.restoreChallengeData([challenge.challengeId: challenge])

//        XCTAssertEqual(status, challenge.status,
//                       "Challenge status didn't restore")
        XCTAssertEqual(finishedTime, challenge.finishedTime,
                       "Challenge finishedTime didn't restore")
        XCTAssertEqual(rating, challenge.rating,
                       "Challenge rating didn't restore")
        XCTAssertEqual(comments, challenge.comments,
                       "Challenge comments didn't restore")
    }

    private static func assertChallenges(_ challenge: Challenge, _ restoredChallenge: Challenge?) {
        XCTAssertEqual(challenge.challengeId, restoredChallenge?.challengeId,
                       "Challenge id didn't restore")
        XCTAssertEqual(challenge.content, restoredChallenge?.content,
                       "Challenge content didn't restore")
        XCTAssertEqual(challenge.details, restoredChallenge?.details,
                       "Challenge details didn't restore")
        XCTAssertEqual(challenge.quote, restoredChallenge?.quote,
                       "Challenge quote didn't restore")
        XCTAssertEqual(challenge.source, restoredChallenge?.source,
                       "Challenge source didn't restore")
        XCTAssertEqual(challenge.type, restoredChallenge?.type,
                       "Challenge type didn't restore")
        XCTAssertEqual(challenge.url, restoredChallenge?.url,
                       "Challenge url didn't restore")
        XCTAssertEqual(challenge.level, restoredChallenge?.level,
                       "Challenge level didn't restore")
        XCTAssertEqual(challenge.status, restoredChallenge?.status,
                       "Challenge status didn't restore")
        XCTAssertEqual(challenge.finishedTime, restoredChallenge?.finishedTime,
                       "Challenge finishedTime didn't restore")
        XCTAssertEqual(challenge.rating, restoredChallenge?.rating,
                       "Challenge rating didn't restore")
        XCTAssertEqual(challenge.comments, restoredChallenge?.comments,
                       "Challenge comments didn't restore")
    }

    private static func buildChallenge() -> Challenge {
        let challenge = Challenge(
            "challengeId",
            "content",
            "details",
            "quote",
            "source",
            "type",
            "url",
            .high)
        challenge.status = .finished
        challenge.finishedTime = 1
        challenge.rating = 1
        challenge.comments = "comments"
        return challenge
    }
}
