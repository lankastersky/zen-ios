import Foundation

/// Modifiable challenge data for serialization etc.
struct ChallengeData {
    let challengeId: String
    let status: Int
    let finishedTime: TimeInterval
    let rating: Float
    let comments: String
    let prevStatuses: [Int]
    let prevFinishedTimes: [TimeInterval]
    let prevRatings: [Float]
}
