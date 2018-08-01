import Foundation

enum ChallengeLevel: Int, Codable {
    case low = 1
    case medium
    case high

    var description: String {
        switch self {
        case .low: return "challenge_difficulty_low".localized
        case .medium: return "challenge_difficulty_medium".localized
        case .high: return "challenge_difficulty_high".localized
        }
    }
}
