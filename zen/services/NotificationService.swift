import UIKit

final class NotificationService {

    private static let reminderIdKey = "reminderId"
    private static let initialReminderId = "initialReminderId"
    private static let constantReminderId = "constantReminderId"
    private static let finalReminderId = "finalReminderId"

    func setupReminder(_ reminderType: ReminderType, _ date: Date) {
        let reminderId = NotificationService.reminderId(reminderType)
        switch reminderType {
        case .initial:
            setupReminder(reminderId, date, .day, "notification_new_challenge".localized)
        case .final:
            setupReminder(reminderId, date, .day, "notification_finish_challenge".localized)
        case .constant:
            setupReminder(reminderId, date, .hour, "notification_do_challenge".localized)
        }
    }

    func rescheduleReminder(_ reminderType: ReminderType) {
        NotificationService.cancelNotification(NotificationService.reminderId(reminderType))
        guard let notification = NotificationService.findNotification(
            NotificationService.reminderId(reminderType)) else {
            assertionFailure("Failed to find initial reminder")
            return
        }
        guard let previousDate = notification.fireDate else {
            assertionFailure("Failed to get previous date for reminder")
            return
        }
        let reminderId = NotificationService.reminderId(reminderType)
        switch reminderType {
        case .initial, .final:
            guard let date = Calendar.current.date(byAdding: .day,
                                                   value: 1,
                                                   to: previousDate) else {
                assertionFailure("Failed to get date for reminder")
                return
            }
            setupReminder(reminderId, date, .day, notification.alertBody)
        case .constant:
            setupReminder(reminderId, previousDate, .hour, notification.alertBody)
        }
    }

    func cancelReminder(_ reminderType: ReminderType) {
            NotificationService.cancelNotification(NotificationService.reminderId(reminderType))
    }

    private func setupReminder(_ reminderId: String,
                               _ date: Date,
                               _ repeatInterval: NSCalendar.Unit,
                               _ message: String?) {
        
        let notification = UILocalNotification()
        notification.fireDate = date
        #if DEBUG_TIME
        notification.repeatInterval = .minute
        #else
        notification.repeatInterval = repeatInterval
        #endif
        notification.alertBody = message
        notification.userInfo = [NotificationService.reminderIdKey: reminderId]

        NotificationService.setupNotification(notification)
    }

    private static func reminderId(_ reminderType: ReminderType) -> String {
        switch reminderType {
        case .initial:
            return NotificationService.initialReminderId
        case .constant:
            return NotificationService.constantReminderId
        case .final:
            return NotificationService.finalReminderId
        }
    }
    
    private static func setupNotification(_ notification: UILocalNotification) {
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    private static func cancelNotification(_ notificationId: String) {
        while let notification = NotificationService.findNotification(notificationId) {
            UIApplication.shared.cancelLocalNotification(notification)
        }
    }

    /// There could be several notifications with the same id
    private static func findNotification(_ notificationId: String) -> UILocalNotification? {
        guard let notifications = UIApplication.shared.scheduledLocalNotifications else {
            assertionFailure("Failed to get notifications")
            return nil
        }
        for notification in notifications {
            guard let userInfo = notification.userInfo else {
                assertionFailure("Failed to get notification user info")
                return nil
            }
            if userInfo[NotificationService.reminderIdKey] as? String == notificationId {
                return notification
            }
        }
        return nil
    }
}
