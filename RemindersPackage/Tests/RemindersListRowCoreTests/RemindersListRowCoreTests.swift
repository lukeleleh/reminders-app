import ComposableArchitecture
@testable import RemindersListRowCore
import SharedModels
import XCTest

class RemindersListRowCoreTests: XCTestCase {
    var defaultEnvironment: RemindersListRowEnvironment {
        RemindersListRowEnvironment.failing
    }

    func testCheckboxTap_WithDate_Completing() {
        var environment = defaultEnvironment
        var canceledNotificationId: String?
        environment.userNotificationClient.removePendingNotificationRequestsWithIdentifiers = { identifiers in
            canceledNotificationId = identifiers.first
            return .none
        }

        let reminder = Reminder(id: UUID(), isCompleted: false, date: Date())
        let store = TestStore(
            initialState: reminder,
            reducer: remindersListRowReducer,
            environment: environment
        )

        store.send(.checkboxTap) {
            $0.isCompleted = true
        }

        XCTAssertEqual(canceledNotificationId, reminder.id.uuidString)
    }

    func testCheckboxTap_WithDate_Uncompleting() {
        var environment = defaultEnvironment
        var scheduledNotificationId: String?
        environment.userNotificationClient.add = { request in
            scheduledNotificationId = request.identifier
            return .none
        }

        let reminder = Reminder(id: UUID(), isCompleted: true, date: Date())
        let store = TestStore(
            initialState: reminder,
            reducer: remindersListRowReducer,
            environment: environment
        )

        store.send(.checkboxTap) {
            $0.isCompleted = false
        }

        XCTAssertEqual(scheduledNotificationId, reminder.id.uuidString)
    }

    func testCheckboxTap_WithoutDate() {
        let store = TestStore(
            initialState: Reminder(id: UUID(), isCompleted: false),
            reducer: remindersListRowReducer,
            environment: defaultEnvironment
        )

        store.send(.checkboxTap) {
            $0.isCompleted = true
        }

        store.send(.checkboxTap) {
            $0.isCompleted = false
        }
    }

    func testTextFieldChanged() {
        let store = TestStore(
            initialState: Reminder(id: UUID(), title: "Buy milk"),
            reducer: remindersListRowReducer,
            environment: defaultEnvironment
        )

        store.send(.textFieldChanged("Buy fruit")) {
            $0.title = "Buy fruit"
        }
    }
}
