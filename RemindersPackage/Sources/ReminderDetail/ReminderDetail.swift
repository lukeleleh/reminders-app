import ComposableArchitecture
import ReminderDetailCore
import SharedModels
import SwiftUI
import UIApplicationClient
import UserNotificationClient

public struct ReminderDetail: View {
    public let store: Store<ReminderDetailState, ReminderDetailAction>

    public init(store: Store<ReminderDetailState, ReminderDetailAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Form {
                    Section {
                        TextField(
                            "Title",
                            text: viewStore.binding(
                                get: \.currentReminder.title,
                                send: ReminderDetailAction.titleTextFieldChanged
                            )
                        )

                        TextField(
                            "Notes",
                            text: viewStore.binding(
                                get: \.currentReminder.notes,
                                send: ReminderDetailAction.notesTextFieldChanged
                            )
                        )
                    }

                    Section {
                        IconToggleRow(
                            icon: "🗓",
                            label: "Date",
                            toggleBinding: viewStore.binding(
                                get: \.isDateToggleOn,
                                send: ReminderDetailAction.toggleDateField
                            )
                        )
                        if viewStore.isDateToggleOn {
                            DatePicker(
                                "Start Date",
                                selection: viewStore.binding(
                                    get: \.currentReminder.displayedDate,
                                    send: ReminderDetailAction.dateChanged
                                ),
                                in: Date()...
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                        }
                    }
                }
                .actionSheet(
                    store.scope(state: \.cancelSheet),
                    dismiss: .cancelSheetDismissed
                )
                .alert(
                    store.scope(state: \.alert),
                    dismiss: .cancelAlertDismissed
                )
                .navigationTitle("Details")
                .navigationBarItems(
                    leading: Button("Cancel") { viewStore.send(.cancelButtonTap) },
                    trailing: Button("Done") { viewStore.send(.doneButtonTap) }
                )
            }
            .onAppear(perform: { viewStore.send(.onAppear) })
        }
    }
}

struct ReminderDetail_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: ReminderDetailState(
                initialReminder: Reminder(id: UUID(), title: "Buy groceries", notes: "", isCompleted: false)
            ),
            reducer: reminderDetailReducer,
            environment: ReminderDetailEnvironment(
                currentDate: Date.init,
                userNotificationClient: .noop,
                applicationClient: .noop,
                notificationCenterClient: .noop,
                mainQueue: .main
            )
        )
        ReminderDetail(store: store)
    }
}

private extension Reminder {
    var displayedDate: Date {
        date ?? Date()
    }
}
