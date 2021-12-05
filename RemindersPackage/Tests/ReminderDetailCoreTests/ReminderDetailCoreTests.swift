import ComposableArchitecture
@testable import ReminderDetailCore
import SharedModels
import XCTest

class ReminderDetailCoreTests: XCTestCase {
    let scheduler = DispatchQueue.test

    var defaultEnvironment: ReminderDetailEnvironment {
        var environment = ReminderDetailEnvironment.failing
        environment.applicationClient.openSettingsURLString = { "settings:reminders//reminders/settings" }
        environment.mainQueue = .immediate
        environment.notificationCenterClient.publisher = { _ in .none }
        return environment
    }

    func testTitleTextFieldChanged() {
        let reminder = Reminder(id: UUID(), title: "Buy milk", isCompleted: false)
        let initialState = ReminderDetailState(initialReminder: reminder)
        let store = TestStore(
            initialState: initialState,
            reducer: reminderDetailReducer,
            environment: defaultEnvironment
        )

        store.send(.titleTextFieldChanged("Buy fruit")) {
            $0.currentReminder.title = "Buy fruit"
        }
    }

    func testNotesTextFieldChanged() {
        let reminder = Reminder(id: UUID(), title: "Buy milk", notes: "")
        let initialState = ReminderDetailState(initialReminder: reminder)
        let store = TestStore(
            initialState: initialState,
            reducer: reminderDetailReducer,
            environment: defaultEnvironment
        )

        store.send(.notesTextFieldChanged("Semi-skimmed")) {
            $0.currentReminder.notes = "Semi-skimmed"
        }
    }

    func testDateChanged() {
        let reminder = Reminder(id: UUID())
        let initialState = ReminderDetailState(initialReminder: reminder)
        let store = TestStore(
            initialState: initialState,
            reducer: reminderDetailReducer,
            environment: defaultEnvironment
        )

        let newDate = Date()
        store.send(.dateChanged(newDate)) {
            $0.currentReminder.date = newDate
        }
    }

    func testToggleDateField() {
        let reminder = Reminder(id: UUID(), isCompleted: false)
        let initialState = ReminderDetailState(initialReminder: reminder)
        let currentTestDate = Date()

        var environment = defaultEnvironment
        environment.currentDate = { currentTestDate }

        let store = TestStore(
            initialState: initialState,
            reducer: reminderDetailReducer,
            environment: environment
        )

        store.send(.toggleDateField(true)) {
            $0.isDateToggleOn = true
            $0.currentReminder.date = currentTestDate
        }

        store.send(.toggleDateField(false)) {
            $0.isDateToggleOn = false
            $0.currentReminder.date = nil
        }
    }

    func testConfirmDismissWithChanges() {
        let reminder = Reminder(id: UUID(), title: "Buy milk", isCompleted: false)
        let initialState = ReminderDetailState(initialReminder: reminder)
        let store = TestStore(
            initialState: initialState,
            reducer: reminderDetailReducer,
            environment: defaultEnvironment
        )

        store.send(.titleTextFieldChanged("Buy fruit")) {
            $0.currentReminder.title = "Buy fruit"
        }

        store.send(.cancelButtonTap) {
            $0.cancelSheet = ActionSheetState(
                title: TextState("Confirmation"),
                buttons: [.cancel(), .destructive(TextState("Don't save changes"), action: .send(.dontSaveChangesButtonTap))]
            )
        }

        store.assert(
            .send(.dontSaveChangesButtonTap),
            .receive(.closeDetail)
        )
    }

    func testCancelWithoutChanges() {
        let reminder = Reminder(id: UUID(), title: "Buy milk", isCompleted: false)
        let initialState = ReminderDetailState(initialReminder: reminder)
        let store = TestStore(
            initialState: initialState,
            reducer: reminderDetailReducer,
            environment: defaultEnvironment
        )

        store.assert(
            .send(.cancelButtonTap),
            .receive(.closeDetail)
        )
    }

    func testDoneButton_WithoutDate() {
        let reminder = Reminder(id: UUID(), date: nil)
        let initialState = ReminderDetailState(initialReminder: reminder)
        let store = TestStore(
            initialState: initialState,
            reducer: reminderDetailReducer,
            environment: defaultEnvironment
        )

        store.send(.doneButtonTap)

        store.receive(.closeAndSaveDetail)
    }

    func testDoneButton_WithDate_NotDeterminedNotificationPermissions_ButUserAccepts() {
        let reminderDate = Date.distantFuture
        let reminder = Reminder(id: UUID(), date: reminderDate)
        let initialState = ReminderDetailState(initialReminder: reminder)

        var scheduledNoticationDate: Date?
        var environment = defaultEnvironment
        environment.userNotificationClient.getNotificationSettings = .init(value: .init(authorizationStatus: .notDetermined))
        environment.userNotificationClient.requestAuthorization = { _ in .init(value: true) }
        environment.userNotificationClient.add = { request in
            scheduledNoticationDate = (request.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
            return .init(value: ())
        }

        let store = TestStore(
            initialState: initialState,
            reducer: reminderDetailReducer,
            environment: environment
        )

        store.send(.onAppear)

        store.receive(.userNotificationSettingsResponse(.init(authorizationStatus: .notDetermined))) {
            $0.userNotificationSettings = .init(authorizationStatus: .notDetermined)
        }

        store.send(.doneButtonTap)

        store.receive(.userNotificationAuthorizationResponse(result: .success(true), date: reminderDate))

        store.receive(.addNotificationRequest(reminderDate))

        XCTAssertEqual(reminderDate, scheduledNoticationDate)

        store.receive(.closeAndSaveDetail)
    }

    func testDoneButton_WithDate_NotDeterminedNotificationPermissions_ButUserDenies() {
        let reminderDate = Date.distantFuture
        let reminder = Reminder(id: UUID(), date: reminderDate)
        let initialState = ReminderDetailState(initialReminder: reminder)

        var environment = defaultEnvironment
        environment.userNotificationClient.getNotificationSettings = .init(value: .init(authorizationStatus: .notDetermined))
        environment.userNotificationClient.requestAuthorization = { _ in .init(value: false) }
        let store = TestStore(
            initialState: initialState,
            reducer: reminderDetailReducer,
            environment: environment
        )

        store.send(.onAppear)

        store.receive(.userNotificationSettingsResponse(.init(authorizationStatus: .notDetermined))) {
            $0.userNotificationSettings = .init(authorizationStatus: .notDetermined)
        }

        store.send(.doneButtonTap)

        store.receive(.userNotificationAuthorizationResponse(result: .success(false), date: reminderDate))

        store.send(.closeDetail)
    }

    func testDoneButton_WithDate_AuthorizedNotificationPermissions() {
        let reminderDate = Date.distantFuture
        let reminder = Reminder(id: UUID(), date: reminderDate)
        let initialState = ReminderDetailState(initialReminder: reminder)

        var scheduledNoticationDate: Date?
        var environment = defaultEnvironment
        environment.userNotificationClient.getNotificationSettings = .init(value: .init(authorizationStatus: .authorized))
        environment.userNotificationClient.add = { request in
            scheduledNoticationDate = (request.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
            return .init(value: ())
        }

        let store = TestStore(
            initialState: initialState,
            reducer: reminderDetailReducer,
            environment: environment
        )

        store.send(.onAppear)

        store.receive(.userNotificationSettingsResponse(.init(authorizationStatus: .authorized))) {
            $0.userNotificationSettings = .init(authorizationStatus: .authorized)
        }

        store.send(.doneButtonTap)

        store.receive(.addNotificationRequest(reminderDate))

        XCTAssertEqual(reminderDate, scheduledNoticationDate)

        store.receive(.closeAndSaveDetail)
    }

    func testDoneButton_WithDate_DeniedNotificationPermissions() {
        let reminderDate = Date.distantFuture
        let reminder = Reminder(id: UUID(), date: reminderDate)
        let initialState = ReminderDetailState(initialReminder: reminder)

        var openSettingsUrl: URL?
        var environment = defaultEnvironment
        environment.userNotificationClient.getNotificationSettings = .init(value: .init(authorizationStatus: .denied))
        environment.applicationClient.open = { url in
            openSettingsUrl = url
            return .init(value: true)
        }

        let store = TestStore(
            initialState: initialState,
            reducer: reminderDetailReducer,
            environment: environment
        )

        store.send(.onAppear)

        store.receive(.userNotificationSettingsResponse(.init(authorizationStatus: .denied))) {
            $0.userNotificationSettings = .init(authorizationStatus: .denied)
        }

        store.send(.doneButtonTap) {
            $0.alert = AlertState<ReminderDetailAction>(
                title: TextState("Enable push notifications"),
                primaryButton: .default(TextState("Go to settings"), action: .send(.openNotificationSettings)),
                secondaryButton: .cancel()
            )
        }

        store.send(.openNotificationSettings)

        XCTAssertEqual(openSettingsUrl, URL(string: "settings:reminders//reminders/settings"))

        store.send(.closeDetail)
    }
}
