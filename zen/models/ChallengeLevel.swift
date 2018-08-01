import Foundation

enum ChallengeLevel: Int, Codable {
    case low = 1
    case medium
    case high

    var description: String {
        switch self {
        case .low: return NSLocalizedString("challenge_difficulty_low", comment: "")
        case .medium: return NSLocalizedString("challenge_difficulty_medium", comment: "")
        case .high: return NSLocalizedString("challenge_difficulty_high", comment: "")
        }
    }
}
