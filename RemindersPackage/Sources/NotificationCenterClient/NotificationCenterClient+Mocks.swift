import ComposableArchitecture
import XCTestDynamicOverlay

extension NotificationCenterClient {
    #if DEBUG
    public static let failing = Self(
        publisher: { _ in .failing("\(Self.self).publisher is unimplemented") }
    )
    #endif

    public static let noop = Self(
        publisher: { _ in .none }
    )
}
