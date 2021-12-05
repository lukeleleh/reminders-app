import ComposableArchitecture

public struct NotificationCenterClient {
    public var publisher: (Notification) -> Effect<Void, Never>

    public init(publisher: @escaping (Notification) -> Effect<Void, Never>) {
        self.publisher = publisher
    }
}

extension NotificationCenterClient {
    public enum Notification {
        case didBecomeActive
    }
}
