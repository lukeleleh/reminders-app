import ComposableArchitecture
import NotificationCenterClient
import ReminderDetailCore
import RemindersListRowCore
import SharedModels
import UIApplicationClient
import UserNotificationClient

public struct RemindersListState: Equatable {
    public var list: IdentifiedArrayOf<Reminder>
    public var detailState: Identified<Reminder.ID, ReminderDetailState>?

    public init(list: IdentifiedArrayOf<Reminder>, detailState: Identified<Reminder.ID, ReminderDetailState>? = nil) {
        self.list = list
        self.detailState = detailState
    }

}

public enum RemindersListAction: Equatable {
    case addButtonTap
    case reminderRow(id: UUID, action: RemindersListRowAction)
    case sheetSelection(Identified<Reminder.ID, ReminderDetailState>?)
    case reminderDetail(ReminderDetailAction)
    case todoDelayCompleted

}

public struct RemindersListEnvironment {
    var uuid: () -> UUID
    var userNotifications: UserNotificationClient
    var applicationClient: UIApplicationClient
    var notificationCenterClient: NotificationCenterClient
    var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        uuid: @escaping () -> UUID,
        userNotifications: UserNotificationClient,
        applicationClient: UIApplicationClient,
        notificationCenterClient: NotificationCenterClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.uuid = uuid
        self.userNotifications = userNotifications
        self.applicationClient = applicationClient
        self.notificationCenterClient = notificationCenterClient
        self.mainQueue = mainQueue
    }
}

public let remindersListReducer = Reducer<RemindersListState, RemindersListAction, RemindersListEnvironment>.combine(
    remindersListRowReducer.forEach(
        state: \.list,
        action: /RemindersListAction.reminderRow,
        environment: { environment in
            RemindersListRowEnvironment(userNotificationClient: environment.userNotifications)
        }
    ),

    reminderDetailReducer
        .pullback(state: \Identified.value, action: .self, environment: { $0 })
        .optional()
        .pullback(
            state: \.detailState,
            action: /RemindersListAction.reminderDetail,
            environment: { environment in ReminderDetailEnvironment(
                currentDate: Date.init,
                userNotificationClient: environment.userNotifications,
                applicationClient: environment.applicationClient,
                notificationCenterClient: environment.notificationCenterClient,
                mainQueue: environment.mainQueue
            ) }
        ),

    Reducer { state, action, environment in
        switch action {
        case .addButtonTap:
            state.list.insert(Reminder(id: environment.uuid()), at: 0)
            return .none
        case let .reminderRow(id, .infoButtonTap):
            state.list[id: id].map {
                state.detailState = Identified(ReminderDetailState(initialReminder: $0), id: $0.id)
            }
            return .none
        case let .reminderRow(id, action: .checkboxTap):
            struct CancelDelayId: Hashable {}

            return Effect(value: .todoDelayCompleted)
                .debounce(id: CancelDelayId(), for: 1, scheduler: environment.mainQueue.animation())
        case let .sheetSelection(.some(identified)):
            state.detailState = identified
            return .none
        case .sheetSelection(.none):
            state.detailState = nil
            return .none
        case .reminderRow:
            return .none
        case .todoDelayCompleted:
            let sortedList = state.list
                .enumerated()
                .sorted { lhs, rhs in
                    (!lhs.element.isCompleted && rhs.element.isCompleted) || lhs.offset < rhs.offset
                }
                .map(\.element)
            state.list = IdentifiedArrayOf(uniqueElements: sortedList)
            return .none
        case .reminderDetail(.closeAndSaveDetail):
            state.detailState.map { state.list[id: $0.id] = $0.currentReminder }
            state.detailState = nil
            return .none
        case .reminderDetail(.closeDetail):
            state.detailState = nil
            return .none
        case .reminderDetail:
            return .none
        }
    }
)
