import ComposableArchitecture
import XCTestDynamicOverlay

extension UIApplicationClient {
    #if DEBUG
    public static let failing = Self(
        open: { _ in .failing("\(Self.self).open is unimplemented") },
        openSettingsURLString: {
            XCTFail("\(Self.self).openSettingsURLString is unimplemented")
            return ""
        }
    )
    #endif

    public static let noop = Self(
        open: { _ in .none },
        openSettingsURLString: { "settings://reminders/settings" }
    )
}
