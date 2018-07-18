import Foundation

/// Challenge model
final class Challenge: Codable {

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

    func updateStatus() {
        switch status {
        case nil:
            status = .shown
        case .shown?:
            status = .accepted
        case .accepted?:
            status = .finished
            finishedTime = Date().timeIntervalSince1970
        case .finished?, .declined?:
            assertionFailure("Wrong challenge status")
        }
    }

    func decline() {
        switch status {
        case .shown?, .accepted?:
            status = .declined
            finishedTime = Date().timeIntervalSince1970
        case nil, .finished?, .declined?:
            assertionFailure("Wrong challenge status")
        }
    }

    func reset() {
        status = nil
        finishedTime = 0
        rating = nil
    }

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
        guard let challengeLevel = ChallengeLevel(rawValue: levelInt) else {
            throw ServiceError.runtimeError("level is not defined")
        }
        level = challengeLevel
        guard let decodedId = decoder.codingPath.first?.stringValue else {
            throw ServiceError.runtimeError("Challenge id is not defined")
        }
        challengeId = decodedId
    }
}
