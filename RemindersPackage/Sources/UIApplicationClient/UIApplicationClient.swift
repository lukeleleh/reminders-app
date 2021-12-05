import ComposableArchitecture

public struct UIApplicationClient {
    public var open: (URL) -> Effect<Bool, Never>
    public var openSettingsURLString: () -> String

    public init(
        open: @escaping (URL) -> Effect<Bool, Never>,
        openSettingsURLString: @escaping () -> String
    ) {
        self.open = open
        self.openSettingsURLString = openSettingsURLString
    }
}
