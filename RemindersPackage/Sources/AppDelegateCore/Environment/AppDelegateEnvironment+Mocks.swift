#if DEBUG
import UserNotificationClient

public extension AppDelegateEnvironment {
    static let failing = Self(
        userNotifications: .failing
    )
}
#endif
