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
        let now = Date()
        return now < date6pm
        #else
        guard let date6pm = Calendar.current.date(
            bySettingHour: 18,
            minute: 0,
            second: 0,
            of: Date()
        )
        else {
            print("Failed to get date of 6pm")
            return true
        }
        return dateSinceEpoch < date6pm
        #endif
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
        let now = Date()
        return now < nextMidnight
        #else
        let midnight = Calendar.current.startOfDay(for: Date())
        guard let nextMidnight =
            Calendar.current.date(byAdding: .day, value: 1, to: midnight) else {
            print("Failed to get next midnight")
            return false
        }
        return dateSinceEpoch < nextMidnight
        #endif
    }

    func toStringWithMediumFormat() -> String {
        // TODO: make formatter static.
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        return dateFormatter.string(from: self)
    }
}
