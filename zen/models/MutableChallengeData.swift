import Foundation

/// Modifiable challenge data for serialization etc.
final class MutableChallengeData: Codable {

    let challengeId: String
    let status: ChallengeStatus?
    let finishedTime: TimeInterval
    let rating: Double?
    let comments: String?

    init(
        _ challengeId: String,
        _ status: ChallengeStatus?,
        _ finishedTime: TimeInterval,
        _ rating: Double?,
        _ comments: String?) {

        self.challengeId = challengeId
        self.status = status
        self.finishedTime = finishedTime
        self.rating = rating
        self.comments = comments
    }
}
