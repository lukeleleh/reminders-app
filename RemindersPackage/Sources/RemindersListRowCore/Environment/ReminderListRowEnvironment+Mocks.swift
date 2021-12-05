#if DEBUG
import XCTestDynamicOverlay
import Foundation

extension RemindersListRowEnvironment {
    public static let failing = Self(
        userNotificationClient: .failing
    )
}
#endif
