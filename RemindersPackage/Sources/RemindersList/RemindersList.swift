import ComposableArchitecture
import ReminderDetail
import RemindersListRow
import RemindersListCore
import SharedModels
import SwiftUI

public struct RemindersList: View {
    let store: Store<RemindersListState, RemindersListAction>

    public init(store: Store<RemindersListState, RemindersListAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                List {
                    ForEachStore(
                        store.scope(state: \.list, action: RemindersListAction.reminderRow),
                        content: RemindersListRow.init(store:)
                    )
                }
                .navigationTitle("Reminders")
                .navigationBarItems(trailing: Button("Add") { viewStore.send(.addButtonTap) })
                .sheet(
                    item: viewStore.binding(get: \.detailState, send: RemindersListAction.sheetSelection),
                    content: { reminder in
                        IfLetStore(
                            store.scope(state: \.detailState?.value, action: RemindersListAction.reminderDetail),
                            then: ReminderDetail.init(store:),
                            else: { Text("") }
                        )
                    }
                )
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
                    Reminder(id: UUID(), title: "", notes: "", isCompleted: false),
                    Reminder(id: UUID(), title: "Buy groceries", notes: "Also banana", isCompleted: false),
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
    }
}
