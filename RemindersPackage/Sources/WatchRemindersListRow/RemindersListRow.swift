import ComposableArchitecture
import RemindersListRowCore
import SharedModels
import UserNotificationClient
import SwiftUI

public struct RemindersListRow: View {
    let store: Store<Reminder, RemindersListRowAction>

    public init(store: Store<Reminder, RemindersListRowAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            HStack(alignment: .firstTextBaseline) {
                Button(action: { viewStore.send(.checkboxTap) }) {
                    Image(systemName: viewStore.isCompleted ? "checkmark.square" : "square")
                }
                .buttonStyle(PlainButtonStyle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewStore.title)

                    if !viewStore.notes.isEmpty {
                        Text(viewStore.notes)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    if let date = viewStore.date {
                        VStack(alignment: .leading) {
                            Text(date, style: .date)
                            Text(date, style: .time)
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    }
                }
            }
            .foregroundColor(viewStore.isCompleted ? .gray : nil)
        }
    }
}

struct RemindersListRow_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: Reminder(
                id: UUID(),
                title: "Buy groceries",
                notes: "Remember banana",
                isCompleted: false,
                date: Date()
            ),
            reducer: remindersListRowReducer,
            environment: RemindersListRowEnvironment(userNotificationClient: .noop)
        )
        RemindersListRow(store: store)
            .previewLayout(.sizeThatFits)
    }
}
