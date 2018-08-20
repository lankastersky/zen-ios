import Foundation

final class ReminderUtils {
    
    private init() {}

    static let initialReminderPickerValues = [
        "reminder_time_never",
        "reminder_time_6am",
        "reminder_time_8am",
        "reminder_time_10am",
        "reminder_time_12pm",
        "reminder_time_random_morning"]
    static let constantReminderPickerValues = [
        "reminder_time_never",
        "reminder_time_every_1h",
        "reminder_time_random_day"]
    static let finalReminderPickerValues = [
        "reminder_time_never",
        "reminder_time_6pm",
        "reminder_time_8pm",
        "reminder_time_10pm",
        "reminder_time_12am",
        "reminder_time_random_evening"]

    /// Returns closest reminder date-time by the string value from resources
    static func reminderTime(_ stringValue: String) -> Date {
        let now = Date()
        let midnight = Calendar.current.startOfDay(for: now)
        let hours = reminderHours(stringValue)
        guard let date = Calendar.current.date(byAdding: .hour,
                                               value: hours,
                                               to: midnight) else {
            assertionFailure("Failed to get date for reminder")
            return now
        }
        return date
    }

    static func reminderHours(_ stringValue: String) -> Int {
        var hours = 0
        switch stringValue {
        case "reminder_time_6am":
            hours = 6
        case "reminder_time_8am":
            hours = 8
        case "reminder_time_10am":
            hours = 10
        case "reminder_time_12pm":
            hours = 12
        case "reminder_time_6pm":
            hours = 18
        case "reminder_time_8pm":
            hours = 20
        case "reminder_time_10pm":
            hours = 22
        case "reminder_time_12am":
            hours = 0
        case "reminder_time_every_1h":
            hours = 1
        case "reminder_time_random_morning":
            hours = Int(arc4random_uniform(6) + 6)
        case "reminder_time_random_day":
            hours = Int(arc4random_uniform(12) + 6)
        case "reminder_time_random_evening":
            hours = Int(arc4random_uniform(18) + 6)
        default:
            assertionFailure("Failed to get reminder hours")
        }
        return hours
    }
}
