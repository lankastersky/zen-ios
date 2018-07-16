import Foundation

/// Challenge model
struct Challenge {

    // Locale-dependent properties.
    let content: String
    let details: String
    let quote: String
    let source: String
    let type: String
    let url: String

    let challengeId: String
    let level: ChallengeLevel
    var status: ChallengeStatus?
    var finishedTime: TimeInterval = 0
    var rating: Double?
    var comments: String?

    let prevStatuses: [Int]? = nil
    let prevFinishedTimes: [TimeInterval]? = nil
    let prevRatings: [Float]? = nil
}

extension Challenge: Decodable {
    
    enum CodingKeys: String, CodingKey {
        //case challengeId = "id"
        case content
        case details
        case quote
        case source
        case type
        case url
        case level
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        content = try container.decode(String.self, forKey: .content)
        details = try container.decode(String.self, forKey: .details)
        quote = try container.decode(String.self, forKey: .quote)
        source = try container.decode(String.self, forKey: .source)
        type = try container.decode(String.self, forKey: .type)
        url = try container.decode(String.self, forKey: .url)
        let levelInt = try container.decode(Int.self, forKey: .level)
        if let challengeLevel = ChallengeLevel(rawValue: levelInt) {
            level = challengeLevel
        } else {
            level = .low
        }
        if let decodedId = decoder.codingPath.first?.stringValue {
            challengeId = decodedId
        } else {
            print("Challenge id is not defined")
            challengeId = ""
        }
    }
}
