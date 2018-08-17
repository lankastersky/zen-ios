enum ReminderType: Int {
    case initial
    case constant
    case final

    var name: String {
        switch self {
        case .initial: return "initial"
        case .constant: return "constant"
        case .final: return "final"
        }
    }
}
