import UIKit

final class NotificationService {

    private static let reminderIdKey = "reminderId"
    private static let initialReminderId = "initialReminderId"

    // TODO: implement constant, final reminder notifications
    func setupReminder(_ reminderType: ReminderType, _ date: Date) {
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.repeatInterval = .day
        notification.alertBody = "You have a new challenge."
        notification.userInfo =
            [NotificationService.reminderIdKey: NotificationService.initialReminderId]

        NotificationService.setupNotification(notification)
    }

    func rescheduleReminder(_ reminderType: ReminderType) {
        NotificationService.cancelNotification(NotificationService.initialReminderId)
        guard let notification =
            NotificationService.findNotification(NotificationService.initialReminderId) else {
            assertionFailure("Failed to find initial reminder")
            return
        }
        guard let previousDate = notification.fireDate else {
            assertionFailure("Failed to get previous date for reminder")
            return
        }
        guard let date = Calendar.current.date(byAdding: .day, value: 1, to: previousDate) else {
            assertionFailure("Failed to get date for reminder")
            return
        }
        setupReminder(reminderType, date)
    }

    func cancelReminder(_ reminderType: ReminderType) {
        NotificationService.cancelNotification(NotificationService.initialReminderId)
    }

    private static func setupNotification(_ notification: UILocalNotification) {
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    private static func cancelNotification(_ notificationId: String) {
        if let notification = NotificationService.findNotification(notificationId) {
            UIApplication.shared.cancelLocalNotification(notification)
        }
    }

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
