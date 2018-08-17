import Foundation

final class ReminderUtils {
    
    private init() {}

    static let initialReminderPickerValues = [
        "settings_screen_time_never".localized,
        "settings_screen_time_6am".localized,
        "settings_screen_time_8am".localized,
        "settings_screen_time_10am".localized,
        "settings_screen_time_12pm".localized,
        "settings_screen_time_random_morning".localized]
    static let constantReminderPickerValues = [
        "settings_screen_time_never".localized,
        "settings_screen_time_every_1h".localized,
        "settings_screen_time_random_day".localized]
    static let finalReminderPickerValues = [
        "settings_screen_time_never".localized,
        "settings_screen_time_6pm".localized,
        "settings_screen_time_8pm".localized,
        "settings_screen_time_10pm".localized,
        "settings_screen_time_12am".localized,
        "settings_screen_time_random_evening".localized]

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
        case "settings_screen_time_6am".localized:
            hours = 6
        case "settings_screen_time_8am".localized:
            hours = 8
        case "settings_screen_time_10am".localized:
            hours = 10
        case "settings_screen_time_12pm".localized:
            hours = 12
        case "settings_screen_time_6pm".localized:
            hours = 18
        case "settings_screen_time_8pm".localized:
            hours = 20
        case "settings_screen_time_10pm".localized:
            hours = 22
        case "settings_screen_time_12am".localized:
            hours = 0
        case "settings_screen_time_every_1h".localized:
            hours = 1
        case "settings_screen_time_random_morning".localized:
            hours = Int(arc4random_uniform(6) + 6)
        case "settings_screen_time_random_day".localized:
            hours = Int(arc4random_uniform(12) + 6)
        case "settings_screen_time_random_evening".localized:
            hours = Int(arc4random_uniform(18) + 6)
        default:
            assertionFailure("Failed to get reminder hours")
        }
        return hours
    }
}
