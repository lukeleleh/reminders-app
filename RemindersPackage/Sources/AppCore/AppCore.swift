import AppDelegateCore
import ComposableArchitecture
import NotificationCenterClient
import RemindersListCore
import ReminderDetailCore
import UIApplicationClient
import UserNotificationClient

public struct AppState: Equatable {
    public var appDelegateState: AppDelegateState
    public var remindersListState: RemindersListState

    public init(appDelegateState: AppDelegateState, remindersListState: RemindersListState) {
        self.appDelegateState = appDelegateState
        self.remindersListState = remindersListState
    }
}

public enum AppAction: Equatable {
    case appDelegate(AppDelegateAction)
    case remindersList(RemindersListAction)
}

public struct AppEnvironment {
    var userNotifications: UserNotificationClient
    var applicationClient: UIApplicationClient
    var notificationCenterClient: NotificationCenterClient
    var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        userNotifications: UserNotificationClient,
        applicationClient: UIApplicationClient,
        notificationCenterClient: NotificationCenterClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.userNotifications = userNotifications
        self.applicationClient = applicationClient
        self.notificationCenterClient = notificationCenterClient
        self.mainQueue = mainQueue
    }
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    remindersListReducer.pullback(
        state: \.remindersListState,
        action: /AppAction.remindersList,
        environment: { environment in
            RemindersListEnvironment(
                uuid: UUID.init,
                userNotifications: environment.userNotifications,
                applicationClient: environment.applicationClient,
                notificationCenterClient: environment.notificationCenterClient,
                mainQueue: environment.mainQueue
            )
        }
    ),
    appDelegateReducer.pullback(
        state: \.appDelegateState,
        action: /AppAction.appDelegate,
        environment: {
            AppDelegateEnvironment(userNotifications: $0.userNotifications)
        }
    ),
    Reducer { state, action, _ in
        switch action {
        case let .appDelegate(.userTapOnNotification(identifier)):
            guard
                let reminderIdentifier = UUID(uuidString: identifier),
                let reminder = state.remindersListState.list[id: reminderIdentifier]
            else {
                return .none
            }
            state.remindersListState.detailState = .init(ReminderDetailState(initialReminder: reminder), id: reminder.id)
            return .none
        case .remindersList, .appDelegate:
            return .none
        }
    }
)
