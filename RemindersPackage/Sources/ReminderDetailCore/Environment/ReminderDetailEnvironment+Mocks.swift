#if DEBUG
import XCTestDynamicOverlay
import Foundation
import UIApplicationClient
import NotificationCenterClient
import UserNotificationClient

extension ReminderDetailEnvironment {
    public static let failing = Self(
        currentDate: { Date() },
        userNotificationClient: .failing,
        applicationClient: .failing,
        notificationCenterClient: .failing,
        mainQueue: .failing
    )
}
#endif
