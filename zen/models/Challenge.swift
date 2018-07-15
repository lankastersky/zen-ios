import Foundation

/// Challenge model
struct Challenge: Decodable {

    // Locale-dependent properties.
    let content: String
    let details: String
    let quote: String
    let source: String
    let type: String
    let url: String

    let challengeId: String
    let level: ChallengeLevel
    var status: ChallengeStatus
    var finishedTime: TimeInterval
    var rating: Double
    var comments: String
}
