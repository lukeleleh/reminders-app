import AppCore
import AppDelegateCore
import ComposableArchitecture
import NotificationCenterClientLive
import RemindersListCore
import SharedModels
import SwiftUI
import UIApplicationClientLive
import UserNotificationClientLive

public final class AppDelegate: NSObject, UIApplicationDelegate {
    public let store = Store(
        initialState: AppState(
            appDelegateState: AppDelegateState(),
            remindersListState: RemindersListState(
                list: [Reminder(id: UUID(), title: "Buy fruit", notes: "Bananas", isCompleted: false, date: Date())],
                detailState: nil
            )
        ),
        reducer: appReducer,
        environment: .live
    )
    
    private(set) lazy var viewStore = ViewStore(
        self.store.scope(state: { _ in () }),
        removeDuplicates: ==
    )

    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        self.viewStore.send(.appDelegate(.didFinishLaunching))
        return true
    }
}

extension AppEnvironment {
    static var live: Self {
        AppEnvironment(
            userNotifications: .live,
            applicationClient: .live,
            notificationCenterClient: .live,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler()
        )
    }
}
