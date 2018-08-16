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

    func setupReminders() {
        setReminderTime(.initial, initialReminderTimeIndex)
    }

    func setupRemindersForAcceptedChallenge() {
        setReminderTime(.constant, constantReminderTimeIndex)
        setReminderTime(.final, finalReminderTimeIndex)
    }

    func setupRemindersForFinishedChallenge() {
        ReminderService.cancelReminderNotification(.constant)
        ReminderService.cancelReminderNotification(.final)
    }

    /// Stores new time persistently and schedules the notification if needed.
    func setReminderTime(_ reminderType: ReminderType, _ reminderTimeIndex: Int) {
        var pickerValue: String?
        switch reminderType {
        case .initial:
            initialReminderTimeIndex = reminderTimeIndex
            pickerValue = ReminderUtils.initialReminderPickerValues[reminderTimeIndex]
        case .constant:
            constantReminderTimeIndex = reminderTimeIndex
            pickerValue = ReminderUtils.constantReminderPickerValues[reminderTimeIndex]
        case .final:
            finalReminderTimeIndex = reminderTimeIndex
            pickerValue = ReminderUtils.finalReminderPickerValues[reminderTimeIndex]
        }

        ReminderService.cancelReminderNotification(reminderType)

        if reminderTimeIndex != ReminderService.reminderTimeIndexNever {
            guard let pickerValue = pickerValue else {
                assertionFailure("Failed to get picker value")
                return
            }
            let reminderTime = ReminderUtils.reminderTime(pickerValue)
            ReminderService.setReminderNotification(reminderType, reminderTime)
        }
    }

    private static func setReminderNotification(_ reminderType: ReminderType, _ date: Date) {
        let reminderId = self.reminderId(reminderType)
        switch reminderType {
        case .initial:
            NotificationUtils.setNotification(
                reminderId, date, .day, "notification_new_challenge".localized)
        case .final:
            NotificationUtils.setNotification(
                reminderId, date, .day, "notification_finish_challenge".localized)
        case .constant:
            NotificationUtils.setNotification(
                reminderId, date, .hour, "notification_do_challenge".localized)
        }
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
