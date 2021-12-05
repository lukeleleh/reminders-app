import UserNotifications

public extension Reminder {
    func makeNotificationRequest(scheduleDate: Date) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = notes

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: scheduleDate),
            repeats: false
        )

        return UNNotificationRequest(
            identifier: id.uuidString,
            content: content,
            trigger: trigger
        )
    }
}
