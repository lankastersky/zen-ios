import Foundation

/// Date-time utils
extension Date {

    static func dateBefore6pm(_ timeSinceEpoch: TimeInterval) -> Bool {
        guard let date6pm = Calendar.current.date(
            bySettingHour: 18,
            minute: 0,
            second: 0,
            of: Date()
            ) else {
                print("Failed to get date of 6pm")
                return true
        }
        let currentChallengeShownDate = Date(timeIntervalSince1970: timeSinceEpoch)
        return currentChallengeShownDate < date6pm
    }

    static func dateBeforeNextMidnight(_ timeSinceEpoch: TimeInterval) -> Bool {
        let midnight = Calendar.current.startOfDay(for: Date())
        guard let nextMidnight =
            Calendar.current.date(byAdding: .day, value: 1, to: midnight) else {
                print("Failed to get next midnight")
                return false
        }
        let currentChallengeShownDate = Date(timeIntervalSince1970: timeSinceEpoch)
        return currentChallengeShownDate < nextMidnight
    }
}
