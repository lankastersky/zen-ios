enum ChallengeLevel: Int, Codable {
    case low = 1
    case medium
    case high

    var description : String {
        switch self {
        // TODO: localize
        case .low: return "low"
        case .medium: return "medium"
        case .high: return "high"
        }
    }
}
