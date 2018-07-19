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

        archiveService?.storeCurrentChallenge(challenge)
        let restoredChallenge = archiveService?.restoreCurrentChallenge()

        XCTAssertEqual(challenge.challengeId, restoredChallenge?.challengeId,
                       "Challenge id didn't restore")
        XCTAssertEqual(challenge.content, restoredChallenge?.content,
                       "Challenge id didn't restore")
        XCTAssertEqual(challenge.details, restoredChallenge?.details,
                       "Challenge id didn't restore")
        XCTAssertEqual(challenge.quote, restoredChallenge?.quote,
                       "Challenge id didn't restore")
        XCTAssertEqual(challenge.source, restoredChallenge?.source,
                       "Challenge id didn't restore")
        XCTAssertEqual(challenge.type, restoredChallenge?.type,
                       "Challenge id didn't restore")
        XCTAssertEqual(challenge.url, restoredChallenge?.url,
                       "Challenge id didn't restore")
        XCTAssertEqual(challenge.level, restoredChallenge?.level,
                       "Challenge id didn't restore")
        XCTAssertEqual(challenge.status, restoredChallenge?.status,
                       "Challenge id didn't restore")
        XCTAssertEqual(challenge.finishedTime, restoredChallenge?.finishedTime,
                       "Challenge id didn't restore")
        XCTAssertEqual(challenge.rating, restoredChallenge?.rating,
                       "Challenge id didn't restore")
        XCTAssertEqual(challenge.comments, restoredChallenge?.comments,
                       "Challenge id didn't restore")

    }
}
