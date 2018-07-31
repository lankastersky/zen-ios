import Foundation

enum ChallengeLevel: Int, Codable {
    case low = 1
    case medium
    case high

    var description: String {
        switch self {
        case .low: return NSLocalizedString("low", comment: "")
        case .medium: return NSLocalizedString("medium", comment: "")
        case .high: return NSLocalizedString("high", comment: "")
        }
    }
}
