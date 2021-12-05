import ComposableArchitecture
import SharedModels
import UserNotificationClient

public enum RemindersListRowAction: Equatable {
    case checkboxTap
    case textFieldChanged(String)
    case infoButtonTap
}

public struct RemindersListRowEnvironment {
    var userNotificationClient: UserNotificationClient

    public init(userNotificationClient: UserNotificationClient) {
        self.userNotificationClient = userNotificationClient
    }

}

public let remindersListRowReducer = Reducer<Reminder, RemindersListRowAction, RemindersListRowEnvironment> { state, action, environment in
    switch action {
    case .checkboxTap:
        state.isCompleted.toggle()

        switch state.date {
        case let .some(date) where state.isCompleted:
            return environment.userNotificationClient.removePendingNotificationRequestsWithIdentifiers([state.id.uuidString])
                .fireAndForget()
        case let .some(date) where !state.isCompleted:
            return environment.userNotificationClient.add(state.makeNotificationRequest(scheduleDate: date))
                .fireAndForget()
        default:
            return .none
        }

    case let .textFieldChanged(text):
        state.title = text
        return .none
    case .infoButtonTap:
        return .none
    }
}
