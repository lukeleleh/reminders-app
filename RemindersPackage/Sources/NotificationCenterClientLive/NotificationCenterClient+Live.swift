import UIKit
import NotificationCenterClient

extension NotificationCenterClient {
    public static let live = Self(
        publisher: { notification in
            NotificationCenter.default.publisher(for: UIKit.Notification.Name(notification: notification))
                .map { _ in () }
                .eraseToEffect()
        }
    )
}

// MARK: -

extension Notification.Name {
    init(notification: NotificationCenterClient.Notification) {
        switch notification {
        case .didBecomeActive:
            self = UIApplication.didBecomeActiveNotification
        }
    }
}
