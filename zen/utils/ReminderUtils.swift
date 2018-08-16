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
        "settings_screen_time_every_2h".localized,
        "settings_screen_time_every_3h".localized,
        "settings_screen_time_every_4h".localized]
    static let finalReminderPickerValues = [
        "settings_screen_time_never".localized,
        "settings_screen_time_6pm".localized,
        "settings_screen_time_8pm".localized,
        "settings_screen_time_10pm".localized,
        "settings_screen_time_12am".localized,
        "settings_screen_time_random_evening".localized]

    static func reminderTime(_ reminderType: ReminderType, _ stringValue: String) -> Date {
        let now = Date()
        let midnight = Calendar.current.startOfDay(for: now)
        let hours = reminderHours(stringValue)
        switch reminderType {
        case .initial, .final:
            guard let date = Calendar.current.date(byAdding: .hour,
                                                   value: hours,
                                                   to: midnight) else {
                assertionFailure("Failed to get date for reminder")
                return now
            }
            return date
        case .constant:
            return midnight
        }
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
        case "settings_screen_time_random_morning".localized:
            hours = Int(arc4random_uniform(6) + 6)
        case "settings_screen_time_random_evening".localized:
            hours = Int(arc4random_uniform(18) + 6)
        case "settings_screen_time_every_1h".localized:
            hours = 1
        case "settings_screen_time_every_2h".localized:
            hours = 2
        case "settings_screen_time_every_3h".localized:
            hours = 3
        case "settings_screen_time_every_4h".localized:
            hours = 4
        default:
            assertionFailure("Failed to get reminder hours")
        }
        return hours
    }
}
