import ComposableArchitecture
@testable import Reminders
import RemindersListCore
import ReminderDetailCore
import SharedModels
import UIApplicationClient
import UserNotificationClient
import XCTest

class RemindersListCoreTests: XCTestCase {
    let scheduler = DispatchQueue.test

    var defaultEnvironment: RemindersListEnvironment {
        RemindersListEnvironment(
            uuid: UUID.incrementing,
            userNotifications: .noop,
            applicationClient: .noop,
            notificationCenterClient: .noop,
            mainQueue: scheduler.eraseToAnyScheduler()
        )
    }

    func testAddButtonTap() {
        let store = TestStore(
            initialState: RemindersListState(list: []),
            reducer: remindersListReducer,
            environment: defaultEnvironment
        )

        store.send(.addButtonTap) {
            $0.list = [
                Reminder(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, title: "", isCompleted: false)
            ]
        }

        store.send(.addButtonTap) {
            $0.list = [
                Reminder(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, title: "", isCompleted: false),
                Reminder(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, title: "", isCompleted: false)
            ]
        }
    }

    func testCheckboxTap() {
        let reminder = Reminder(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            title: "",
            isCompleted: false
        )
        let store = TestStore(
            initialState: RemindersListState(list: [reminder]),
            reducer: remindersListReducer,
            environment: defaultEnvironment
        )

        store.assert(
            .send(.reminderRow(id: reminder.id, action: .checkboxTap)) {
                $0.list[id: reminder.id]?.isCompleted = true
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.todoDelayCompleted)
        )
    }

    func testRemindersSorting() {
        let reminder1 = Reminder(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            title: "",
            isCompleted: false
        )
        let reminder2 = Reminder(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            title: "",
            isCompleted: false
        )
        let store = TestStore(
            initialState: RemindersListState(list: [reminder1, reminder2]),
            reducer: remindersListReducer,
            environment: defaultEnvironment
        )

        store.assert(
            .send(.reminderRow(id: reminder1.id, action: .checkboxTap)) {
                $0.list[id: reminder1.id]?.isCompleted = true
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.todoDelayCompleted) {
                $0.list = [
                    $0.list[id: reminder2.id]!,
                    $0.list[id: reminder1.id]!
                ]
            }
        )
    }

    func testRemindersSortingCancellation() {
        let reminder1 = Reminder(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            title: "",
            isCompleted: false
        )
        let reminder2 = Reminder(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            title: "",
            isCompleted: false
        )
        let store = TestStore(
            initialState: RemindersListState(list: [reminder1, reminder2]),
            reducer: remindersListReducer,
            environment: defaultEnvironment
        )

        store.assert(
            .send(.reminderRow(id: reminder1.id, action: .checkboxTap)) {
                $0.list[id: reminder1.id]?.isCompleted = true
            },
            .do {
                self.scheduler.advance(by: 0.5)
            },
            .send(.reminderRow(id: reminder1.id, action: .checkboxTap)) {
                $0.list[id: reminder1.id]?.isCompleted = false
            },
            .do {
                self.scheduler.advance(by: 1.0)
            },
            .receive(.todoDelayCompleted)
        )
    }

    func testInfoButtonSelection() {
        let reminder = Reminder(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            title: "",
            isCompleted: false
        )
        let store = TestStore(
            initialState: RemindersListState(list: [reminder]),
            reducer: remindersListReducer,
            environment: defaultEnvironment
        )

        store.send(.reminderRow(id: reminder.id, action: .infoButtonTap)) {
            $0.detailState = Identified(ReminderDetailState(initialReminder: reminder), id: reminder.id)
        }

        store.send(.sheetSelection(nil)) {
            $0.detailState = nil
        }

        store.send(.reminderRow(id: reminder.id, action: .infoButtonTap)) {
            $0.detailState = Identified(ReminderDetailState(initialReminder: reminder), id: reminder.id)
        }
    }

    func testSelectionSheet() {
        let reminder = Reminder(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            title: "",
            isCompleted: false
        )
        let identifiedReminder = Identified(ReminderDetailState(initialReminder: reminder), id: reminder.id)
        let store = TestStore(
            initialState: RemindersListState(list: [reminder]),
            reducer: remindersListReducer,
            environment: defaultEnvironment
        )

        store.send(.sheetSelection(identifiedReminder)) {
            $0.detailState = identifiedReminder
        }

        store.send(.sheetSelection(nil)) {
            $0.detailState = nil
        }
    }

    func testListReminderGetsUpdatedFromDetail() {
        let reminder = Reminder(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            title: "",
            isCompleted: false
        )
        let store = TestStore(
            initialState: RemindersListState(list: [reminder]),
            reducer: remindersListReducer,
            environment: defaultEnvironment
        )

        store.send(.reminderRow(id: reminder.id, action: .infoButtonTap)) {
            $0.detailState = Identified(ReminderDetailState(initialReminder: reminder), id: reminder.id)
        }

        store.send(.reminderDetail(.titleTextFieldChanged("Buy milk"))) {
            $0.detailState?.currentReminder.title = "Buy milk"
        }

        store.send(.reminderDetail(.closeAndSaveDetail)) {
            let updatedDetailState = $0.detailState!
            $0.list[id: updatedDetailState.id] = updatedDetailState.currentReminder
            $0.detailState = nil
        }
    }

    func testCloseDetail() {
        let reminder = Reminder(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            title: "",
            isCompleted: false
        )
        let store = TestStore(
            initialState: RemindersListState(list: [reminder]),
            reducer: remindersListReducer,
            environment: defaultEnvironment
        )

        store.send(.reminderRow(id: reminder.id, action: .infoButtonTap)) {
            $0.detailState = Identified(ReminderDetailState(initialReminder: reminder), id: reminder.id)
        }

        store.send(.reminderDetail(.closeDetail)) {
            $0.detailState = nil
        }
    }
}

private extension UUID {
    // A deterministic, auto-incrementing "UUID" generator for testing.
    static var incrementing: () -> UUID {
        var uuid = 0
        return {
            defer { uuid += 1 }
            return UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", uuid))")!
        }
    }
}
