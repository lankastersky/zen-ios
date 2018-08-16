import UIKit

final class NotificationUtils {

    private static let notificationIdKey = "notificationId"

    private init() {}
    
    static func setNotification(_ notificationId: String,
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
        notification.userInfo = [NotificationUtils.notificationIdKey: notificationId]

        setNotification(notification)
    }


    static func cancelNotification(_ notificationId: String) {
        while let notification = NotificationUtils.findNotification(notificationId) {
            UIApplication.shared.cancelLocalNotification(notification)
        }
    }

    /// There could be several notifications with the same id
    static func findNotification(_ notificationId: String) -> UILocalNotification? {
        guard let notifications = UIApplication.shared.scheduledLocalNotifications else {
            assertionFailure("Failed to get notifications")
            return nil
        }
        for notification in notifications {
            guard let userInfo = notification.userInfo else {
                assertionFailure("Failed to get notification user info")
                return nil
            }
            if userInfo[NotificationUtils.notificationIdKey] as? String == notificationId {
                return notification
            }
        }
        return nil
    }

    private static func setNotification(_ notification: UILocalNotification) {
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
