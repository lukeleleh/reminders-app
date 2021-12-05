import AppCore
import AppDelegateCore
import ComposableArchitecture
import RemindersListCore
import SharedModels
import SwiftUI
import UserNotificationClientLive
import WatchOSApp

@main
struct RemindersApp: App {
    public let store = Store(
        initialState: AppState(
            appDelegateState: AppDelegateState(),
            remindersListState: RemindersListState(
                list: [
                    Reminder(id: UUID(), title: "Buy fruit", notes: "Bananas", isCompleted: false, date: Date()),
                    Reminder(id: UUID(), title: "Buy milk", notes: "", isCompleted: false),
                    Reminder(id: UUID(), title: "Charge phone", notes: "", isCompleted: true)
                ],
                detailState: nil
            )
        ),
        reducer: appReducer,
        environment: .live
    )

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                WatchOSAppView(store: store)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

extension AppEnvironment {
    static var live: Self {
        AppEnvironment(
            userNotifications: .live,
            applicationClient: .noop,
            notificationCenterClient: .noop,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler()
        )
    }
}
