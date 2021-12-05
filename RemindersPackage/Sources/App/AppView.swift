import AppCore
import ComposableArchitecture
import RemindersList
import SwiftUI

public struct RemindersAppView: View {
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
