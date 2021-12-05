import Combine
import ComposableArchitecture
import UserNotifications
import UserNotificationClient

extension UserNotificationClient {
    public static let live = Self(
        add: { request in
            .future { callback in
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        callback(.failure(error))
                    } else {
                        callback(.success(()))
                    }
                }
            }
        },
        delegate:
            Effect
            .run { subscriber in
                var delegate: Optional = Delegate(subscriber: subscriber)
                UNUserNotificationCenter.current().delegate = delegate
                return AnyCancellable {
                    delegate = nil
                }
            }
            .share()
            .eraseToEffect(),
        getNotificationSettings: .future { callback in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                callback(.success(.init(rawValue: settings)))
            }
        },
        removeDeliveredNotificationsWithIdentifiers: { identifiers in
            .fireAndForget {
                UNUserNotificationCenter.current()
                    .removeDeliveredNotifications(withIdentifiers: identifiers)
            }
        },
        removePendingNotificationRequestsWithIdentifiers: { identifiers in
            .fireAndForget {
                UNUserNotificationCenter.current()
                    .removePendingNotificationRequests(withIdentifiers: identifiers)
            }
        },
        requestAuthorization: { options in
            .future { callback in
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: options) { granted, error in
                        if let error = error {
                            callback(.failure(error))
                        } else {
                            callback(.success(granted))
                        }
                    }
            }
        }
    )
}

extension UserNotificationClient.Notification {
    public init(rawValue: UNNotification) {
        self.init(date: rawValue.date, request: rawValue.request)
    }
}

extension UserNotificationClient.Notification.Response {
    public init(rawValue: UNNotificationResponse) {
        self.init(notification: .init(rawValue: rawValue.notification))
    }
}

extension UserNotificationClient.Notification.Settings {
    public init(rawValue: UNNotificationSettings) {
        self.init(authorizationStatus: rawValue.authorizationStatus)
    }
}

extension UserNotificationClient {
    fileprivate class Delegate: NSObject, UNUserNotificationCenterDelegate {
        let subscriber: Effect<UserNotificationClient.DelegateEvent, Never>.Subscriber

        init(subscriber: Effect<UserNotificationClient.DelegateEvent, Never>.Subscriber) {
            self.subscriber = subscriber
        }

        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void
        ) {
            self.subscriber.send(
                .didReceiveResponse(.init(rawValue: response), completionHandler: completionHandler)
            )
        }

        #if os(iOS)
        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            openSettingsFor notification: UNNotification?
        ) {
            self.subscriber.send(
                .openSettingsForNotification(notification.map(Notification.init(rawValue:)))
            )
        }
        #endif

        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            willPresent notification: UNNotification,
            withCompletionHandler completionHandler:
                @escaping (UNNotificationPresentationOptions) -> Void
        ) {
            self.subscriber.send(
                .willPresentNotification(
                    .init(rawValue: notification),
                    completionHandler: completionHandler
                )
            )
        }
    }
}
