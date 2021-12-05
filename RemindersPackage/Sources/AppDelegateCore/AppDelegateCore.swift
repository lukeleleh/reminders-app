import ComposableArchitecture
import UserNotifications
import UserNotificationClient

public struct AppDelegateState: Equatable {
    public init() { }
}

public enum AppDelegateAction: Equatable {
    case didFinishLaunching
    case userNotifications(UserNotificationClient.DelegateEvent)
    case userTapOnNotification(identifier: String)
}

public struct AppDelegateEnvironment {
    var userNotifications: UserNotificationClient

    public init(userNotifications: UserNotificationClient) {
        self.userNotifications = userNotifications
    }
}

public let appDelegateReducer = Reducer<AppDelegateState, AppDelegateAction, AppDelegateEnvironment> { state, action, environment in
    switch action {
    case .didFinishLaunching:
        return environment.userNotifications.delegate
            .map(AppDelegateAction.userNotifications)
    case let .userNotifications(.willPresentNotification(_, completionHandler)):
        return .fireAndForget {
            completionHandler(.banner)
        }
    case let .userNotifications(.didReceiveResponse(response, completionHandler)):
        completionHandler()
        return Effect(value: .userTapOnNotification(identifier: response.notification.request.identifier))
    case .userNotifications:
        return .none
    case .userTapOnNotification:
        return .none
    }
}
