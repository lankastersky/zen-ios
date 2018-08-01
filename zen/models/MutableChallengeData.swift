import Foundation

/// Modifiable challenge data for serialization etc.
final class MutableChallengeData: Codable {

    let challengeId: String
    let status: ChallengeStatus?
    let finishedTime: TimeInterval
    let rating: Double?
    let comments: String?

//    enum CodingKeys: String, CodingKey {
//        case challengeId
//        case status
//        case finishedTime
//        case rating
//        case comments
//    }

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

//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        challengeId = try container.decode(String.self, forKey: .challengeId)
//        if let statusInt = try container.decodeIfPresent(Int.self, forKey: .status) {
//            status = ChallengeStatus(rawValue: statusInt)
//        } else {
//            status = nil
//        }
//        finishedTime = try container.decode(Double.self, forKey: .finishedTime)
//        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
//        comments = try container.decodeIfPresent(String.self, forKey: .comments)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        
//    }
}
