import AppCore
import ComposableArchitecture
import RemindersListCore
import WatchRemindersListRow
import SharedModels
import SwiftUI

public struct WatchOSAppView: View {
    let store: Store<AppState, AppAction>

    public init(store: Store<AppState, AppAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            RemindersList(store: store.scope(state: \.remindersListState, action: AppAction.remindersList))
        }
    }
}

struct RemindersList: View {
    let store: Store<RemindersListState, RemindersListAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                List {
                    ForEachStore(
                        store.scope(state: \.list, action: RemindersListAction.reminderRow),
                        content: RemindersListRow.init(store:)
                    )
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct RemindersList_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: RemindersListState(
                list: [
                    Reminder(id: UUID(), title: "Buy groceries", notes: "Also banana", isCompleted: false)
                ]
            ),
            reducer: remindersListReducer,
            environment: RemindersListEnvironment(
                uuid: UUID.init,
                userNotifications: .noop,
                applicationClient: .noop,
                notificationCenterClient: .noop,
                mainQueue: DispatchQueue.main.eraseToAnyScheduler()
            )
        )
        RemindersList(store: store)
            .previewDevice("Apple Watch Series 5 - 40mm")
    }
}
