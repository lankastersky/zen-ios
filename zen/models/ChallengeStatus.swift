enum ChallengeStatus: Int, Codable {
    case shown
    case accepted
    case finished
    case declined

    var name: String {
        switch self {
        case .shown: return "shown"
        case .accepted: return "accepted"
        case .finished: return "finished"
        case .declined: return "declined"
        }
    }
}
