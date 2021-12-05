import ComposableArchitecture
import NotificationCenterClient
import SharedModels
import UIApplicationClient
import UserNotificationClient

public struct ReminderDetailState: Equatable {
    public let initialReminder: Reminder
    public var currentReminder: Reminder
    public var cancelSheet: ActionSheetState<ReminderDetailAction>?
    public var alert: AlertState<ReminderDetailAction>?
    public var isDateToggleOn: Bool

    public var userNotificationSettings: UserNotificationClient.Notification.Settings?

    public init(initialReminder: Reminder) {
        self.initialReminder = initialReminder
        self.currentReminder = initialReminder
        self.isDateToggleOn = initialReminder.date != nil
    }
}

public enum ReminderDetailAction: Equatable {
    case onAppear
    case didBecomeActive
    case titleTextFieldChanged(String)
    case notesTextFieldChanged(String)
    case dateChanged(Date)
    case toggleDateField(Bool)
    case cancelButtonTap
    case cancelSheetDismissed
    case dontSaveChangesButtonTap

    case cancelAlertDismissed
    case openNotificationSettings

    case doneButtonTap
    case closeDetail
    case closeAndSaveDetail

    case addNotificationRequest(Date)
    case userNotificationSettingsResponse(UserNotificationClient.Notification.Settings)
    case userNotificationAuthorizationResponse(result: Result<Bool, NSError>, date: Date)
}

public struct ReminderDetailEnvironment {
    var currentDate: () -> Date
    var userNotificationClient: UserNotificationClient
    var applicationClient: UIApplicationClient
    var notificationCenterClient: NotificationCenterClient
    var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        currentDate: @escaping () -> Date,
        userNotificationClient: UserNotificationClient,
        applicationClient: UIApplicationClient,
        notificationCenterClient: NotificationCenterClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.currentDate = currentDate
        self.userNotificationClient = userNotificationClient
        self.applicationClient = applicationClient
        self.notificationCenterClient = notificationCenterClient
        self.mainQueue = mainQueue
    }
}

public let reminderDetailReducer = Reducer<ReminderDetailState, ReminderDetailAction, ReminderDetailEnvironment> { state, action, environment in
    struct DidBecomeActiveId: Hashable { }

    switch action {
    case .onAppear:
        return .merge(
            environment.userNotificationClient.getNotificationSettings
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(ReminderDetailAction.userNotificationSettingsResponse),
            environment.notificationCenterClient.publisher(.didBecomeActive)
                .map { _ in .didBecomeActive }
                .eraseToEffect()
                .cancellable(id: DidBecomeActiveId())
        )
    case .didBecomeActive:
        return environment.userNotificationClient.getNotificationSettings
            .receive(on: environment.mainQueue)
            .eraseToEffect()
            .map(ReminderDetailAction.userNotificationSettingsResponse)
    case let .titleTextFieldChanged(text):
        state.currentReminder.title = text
        return .none
    case let .notesTextFieldChanged(text):
        state.currentReminder.notes = text
        return .none
    case let .dateChanged(date):
        state.currentReminder.date = date
        return .none
    case let .toggleDateField(isOn):
        state.isDateToggleOn = isOn
        state.currentReminder.date = isOn ? environment.currentDate() : nil
        return .none
    case .cancelButtonTap:
        if state.initialReminder == state.currentReminder {
            return Effect(value: .closeDetail)
        } else {
            state.cancelSheet = ActionSheetState(
                title: TextState("Confirmation"),
                buttons: [
                    .cancel(),
                    .destructive(TextState("Don't save changes"), action: .send(.dontSaveChangesButtonTap))
                ]
            )
        }
        return .none
    case .cancelSheetDismissed:
        state.cancelSheet = nil
        return .none
    case .dontSaveChangesButtonTap:
        return Effect(value: .closeDetail)
    case .cancelAlertDismissed:
        state.alert = nil
        return .none
    case .openNotificationSettings:
        guard let settingsURL = URL(string: environment.applicationClient.openSettingsURLString()) else { return .none }
        return environment.applicationClient.open(settingsURL).fireAndForget()
    case .doneButtonTap:
        guard
            let date = state.currentReminder.date,
            let userNotificationSettings = state.userNotificationSettings
        else {
            return Effect(value: .closeAndSaveDetail)
        }

        switch userNotificationSettings.authorizationStatus {
        case .authorized, .provisional:
            return Effect(value: .addNotificationRequest(date))
        case .denied, .ephemeral:
            state.alert = AlertState<ReminderDetailAction>(
                title: TextState("Enable push notifications"),
                primaryButton: .default(TextState("Go to settings"), action: .send(.openNotificationSettings)),
                secondaryButton: .cancel()
            )
            return .none
        case .notDetermined:
            return environment.userNotificationClient.requestAuthorization([.alert, .badge, .sound])
                .mapError { $0 as NSError }
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { ReminderDetailAction.userNotificationAuthorizationResponse(result: $0, date: date) }
        @unknown default:
            return .none
        }
    case .closeDetail, .closeAndSaveDetail:
        return .cancel(id: DidBecomeActiveId())
    case let .addNotificationRequest(date):
        return .concatenate(
            environment.userNotificationClient.add(state.currentReminder.makeNotificationRequest(scheduleDate: date))
                .fireAndForget(),
            Effect(value: .closeAndSaveDetail)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
        )
    case let .userNotificationSettingsResponse(settings):
        state.userNotificationSettings = settings
        return .none
    case let .userNotificationAuthorizationResponse(result, date):
        let isGranted = (try? result.get()) ?? false
        return isGranted ? Effect(value: .addNotificationRequest(date)) : .none
    }
}
