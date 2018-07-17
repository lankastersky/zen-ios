import Foundation

/// Modifiable challenge data for serialization etc.
final class MutableChallengeData {

    let challengeId: String
    // TODO: somehow I get compilation error Use of undeclared type 'ChallengeStatus'
    //let status: ChallengeStatus?
    let finishedTime: TimeInterval
    let rating: Float?
    let comments: String?

    init(
        _ challengeId: String,
        //_ status: ChallengeStatus?,
        _ finishedTime: TimeInterval,
        _ rating: Float,
        _ comments: String) {

        self.challengeId = challengeId
        //self.status = status
        self.finishedTime = finishedTime
        self.rating = rating
        self.comments = comments
    }
}
