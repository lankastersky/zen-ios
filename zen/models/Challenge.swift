import Foundation

/// Challenge model
final class Challenge: Codable {

    enum CodingKeys: String, CodingKey {
        case challengeId
        case content
        case details
        case quote
        case source
        case type
        case url
        case level
        case status
        case finishedTime
        case rating
        case comments
    }

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

    public init(
        _ challengeId: String,
        _ content: String,
        _ details: String,
        _ quote: String,
        _ source: String,
        _ type: String,
        _ url: String,
        _ level: ChallengeLevel) {

        self.challengeId = challengeId
        self.content = content
        self.details = details
        self.quote = quote
        self.source = source
        self.type = type
        self.url = url
        self.level = level
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decoding [Challenge] array
        if let decodedId = try container.decodeIfPresent(String.self, forKey: .challengeId) {
            challengeId = decodedId
        } else {
            // Decoding [String: Challenge] dictionary
            guard let decodedId = decoder.codingPath.first?.stringValue else {
                throw ServiceError.runtimeError("Challenge id is not defined")
            }
            challengeId = decodedId
        }

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
    }

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
}
