import Foundation
import Firebase

final class AnalyticsService {

    private static let challengeStatusEventName = "challenge_status"
    private static let challengeRatingEventName = "challenge_rating"
    private static let challengeCommentsEventName = "challenge_comments"
    private static let levelEventName = "level"
    private static let reminderEventName = "reminder"

    private init() {}

    static func logChallengeStatus(_ challenge: Challenge) {
        guard let action = challenge.status?.name else {
            assertionFailure("Failed to get challenge status for analytics")
            return
        }
        Analytics.logEvent(challengeStatusEventName, parameters: [
            AnalyticsParameterItemID: challenge.challengeId,
            AnalyticsParameterItemName: action])
    }

    static func logChallengeRating(_ challenge: Challenge) {
        Analytics.logEvent(challengeRatingEventName, parameters: [
            AnalyticsParameterItemID: challenge.challengeId,
            AnalyticsParameterItemName: challenge.rating ?? 0])
    }

    static func logChallengeComments(_ challenge: Challenge) {
        Analytics.logEvent(challengeCommentsEventName, parameters: [
            AnalyticsParameterItemID: challenge.challengeId,
            AnalyticsParameterItemName: challenge.comments?.count ?? 0])
    }

    static func logLevelUp(_ level: ChallengeLevel) {
        Analytics.logEvent(levelEventName, parameters: [
            AnalyticsParameterItemID: level])
    }

    static func logReminder(_ reminderName: String, _ timeValue: String) {
        Analytics.logEvent(reminderEventName, parameters: [
            AnalyticsParameterItemID: reminderName,
            AnalyticsParameterItemName: timeValue])
    }
}
