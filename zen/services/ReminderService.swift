import Foundation

/// Schedules reminder notifications. This class is stateless becase stores all information about
/// notifications  persistenlty but can be reimplemented in different ways.
final class ReminderService {

    private static let initialReminderPickerRowKey = "initial_reminder_time"
    private static let constantReminderPickerRowKey = "constant_reminder_time"
    private static let finalReminderPickerRowKey = "finalc_reminder_time"

    private static let reminderTimeIndexNever = 0

    private static let initialReminderId = "initialReminderId"
    private static let constantReminderId = "constantReminderId"
    private static let finalReminderId = "finalReminderId"

    private let storageService: StorageService

    private var initialReminderTimeIndex: Int {
        get {
            return storageService.object(forKey: ReminderService.initialReminderPickerRowKey)
                as? Int
                ?? ReminderUtils.initialReminderPickerValues.count - 1 // random time index
        }
        set {
            storageService.set(newValue, forKey: ReminderService.initialReminderPickerRowKey)
        }
    }

    private var constantReminderTimeIndex: Int {
        get {
            return storageService.object(
                forKey: ReminderService.constantReminderPickerRowKey) as? Int ?? 1
        }
        set {
            storageService.set(newValue, forKey: ReminderService.constantReminderPickerRowKey)
        }
    }

    private var finalReminderTimeIndex: Int {
        get {
            return storageService.object(forKey: ReminderService.finalReminderPickerRowKey)
                as? Int
                ?? ReminderUtils.finalReminderPickerValues.count - 1 // random time index
        }
        set {
            storageService.set(newValue, forKey: ReminderService.finalReminderPickerRowKey)
        }
    }

    init(_ storageService: StorageService) {
        self.storageService = storageService
    }

    convenience init() {
        self.init(StorageService())
    }

    func reminderTimeIndex(_ reminderType: ReminderType) -> Int {
        switch reminderType {
        case .initial:
            return initialReminderTimeIndex
        case .constant:
            return constantReminderTimeIndex
        case .final:
            return finalReminderTimeIndex
        }
    }

    func seRemindersForNewChallenge(_ challenge: Challenge) {
        setReminderNotification(.initial, challenge)
    }

    func setRemindersForAcceptedChallenge(_ challenge: Challenge) {
        ReminderService.cancelReminderNotification(.initial)
        setReminderNotification(.constant, challenge)
        setReminderNotification(.final, challenge)
    }

    func cancelRemindersForFinishedChallenge() {
        ReminderService.cancelReminderNotification(.constant)
        ReminderService.cancelReminderNotification(.final)
    }

    /// Stores new time persistently and schedules the notification if needed.
    func setReminderTime(_ reminderType: ReminderType, _ reminderTimeIndex: Int) {
        switch reminderType {
        case .initial:
            initialReminderTimeIndex = reminderTimeIndex
        case .constant:
            constantReminderTimeIndex = reminderTimeIndex
        case .final:
            finalReminderTimeIndex = reminderTimeIndex
        }
    }

    private func setReminderNotification(_ reminderType: ReminderType, _ challenge: Challenge) {
        ReminderService.cancelReminderNotification(reminderType)

        var pickerValue: String
        switch reminderType {
        case .initial:
            pickerValue = ReminderUtils.initialReminderPickerValues[initialReminderTimeIndex]
        case .constant:
            pickerValue = ReminderUtils.constantReminderPickerValues[constantReminderTimeIndex]
        case .final:
            pickerValue = ReminderUtils.finalReminderPickerValues[finalReminderTimeIndex]
        }

        if pickerValue == "settings_screen_time_never".localized {
            // Don't set notification
            return
        }

        let reminderTime = ReminderUtils.reminderTime(pickerValue)
        let reminderId = ReminderService.reminderId(reminderType)
        var repeatInterval: NSCalendar.Unit
        let title: String
        switch reminderType {
        case .initial:
            repeatInterval = .day
            title = "notification_new_challenge".localized
        case .constant:
            repeatInterval = .hour
            title = "notification_do_challenge".localized
        case .final:
            repeatInterval = .day
            title = "notification_finish_challenge".localized
        }
        NotificationUtils.setNotification(
            reminderId, reminderTime, repeatInterval, title, challenge.content)
    }

    private static func cancelReminderNotification(_ reminderType: ReminderType) {
        NotificationUtils.cancelNotification(reminderId(reminderType))
    }

    private static func reminderId(_ reminderType: ReminderType) -> String {
        switch reminderType {
        case .initial:
            return ReminderService.initialReminderId
        case .constant:
            return ReminderService.constantReminderId
        case .final:
            return ReminderService.finalReminderId
        }
    }
}
