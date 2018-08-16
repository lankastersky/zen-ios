import Foundation

/// Date-time utils
extension Date {

    static func dateBefore6pm(_ timeSinceEpoch: TimeInterval) -> Bool {
        let dateSinceEpoch = Date(timeIntervalSince1970: timeSinceEpoch)
        #if DEBUG_TIME
        // Several sec after current time to not wait
        guard let date6pm =
            Calendar.current.date(byAdding: .second, value: 5, to: dateSinceEpoch) else {
            print("Failed to get date of 6pm")
            return true
        }
        #else
        guard let date6pm = Calendar.current.date(
            bySettingHour: 18,
            minute: 0,
            second: 0,
            of: dateSinceEpoch
        )
        else {
            print("Failed to get date of 6pm")
            return true
        }
        #endif
        let now = Date()
        return now < date6pm
    }

    static func dateBeforeNextMidnight(_ timeSinceEpoch: TimeInterval) -> Bool {
        let dateSinceEpoch = Date(timeIntervalSince1970: timeSinceEpoch)
        #if DEBUG_TIME
        // Several sec after current time to not wait
        guard let nextMidnight =
            Calendar.current.date(byAdding: .second, value: 15, to: dateSinceEpoch) else {
            print("Failed to get date of 6pm")
            return true
        }
        #else
        let midnight = Calendar.current.startOfDay(for: dateSinceEpoch)
        guard let nextMidnight =
            Calendar.current.date(byAdding: .day, value: 1, to: midnight) else {
            print("Failed to get next midnight")
            return false
        }
        #endif
        let now = Date()
        return now < nextMidnight
    }

    func toStringWithMediumFormat() -> String {
        // Better make formatter static
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        return dateFormatter.string(from: self)
    }
}
