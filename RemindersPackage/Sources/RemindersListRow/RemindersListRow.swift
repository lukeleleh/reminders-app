import ComposableArchitecture
import RemindersListRowCore
import SharedModels
import UserNotificationClient
import SwiftUI

public struct RemindersListRow: View {
    let store: Store<Reminder, RemindersListRowAction>
    @State private var isTextFieldFocused = false

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
                    TextField(
                        "Untitled",
                        text: viewStore.binding(get: \.title, send: RemindersListRowAction.textFieldChanged),
                        onEditingChanged: { isTextFieldFocused = $0 }
                    )

                    if !viewStore.notes.isEmpty {
                        Text(viewStore.notes)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    if let date = viewStore.date {
                        HStack {
                            Text(date, style: .date)
                            Text(date, style: .time)
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    }
                }

                Button(action: { viewStore.send(.infoButtonTap) }) {
                    Image(systemName: "info")
                        .padding(6)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .buttonStyle(BorderlessButtonStyle())
                .opacity(isTextFieldFocused ? 1.0 : 0.0)
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
