// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemindersPackage",
    platforms: [
        .iOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(name: "App", targets: ["App"]),
        .library(name: "AppCore", targets: ["AppCore"]),

        .library(name: "AppDelegateCore", targets: ["AppDelegateCore"]),

        .library(name: "NotificationCenterClient", targets: ["NotificationCenterClient"]),
        .library(name: "NotificationCenterClientLive", targets: ["NotificationCenterClientLive"]),

        .library(name: "ReminderDetailCore", targets: ["ReminderDetailCore"]),
        .library(name: "ReminderDetail", targets: ["ReminderDetail"]),

        .library(name: "RemindersListCore", targets: ["RemindersListCore"]),
        .library(name: "RemindersList", targets: ["RemindersList"]),

        .library(name: "RemindersListRowCore", targets: ["RemindersListRowCore"]),
        .library(name: "RemindersListRow", targets: ["RemindersListRow"]),

        .library(name: "SharedModels", targets: ["SharedModels"]),

        .library(name: "UIApplicationClient", targets: ["UIApplicationClient"]),
        .library(name: "UIApplicationClientLive", targets: ["UIApplicationClientLive"]),

        .library(name: "UserNotificationClient", targets: ["UserNotificationClient"]),
        .library(name: "UserNotificationClientLive", targets: ["UserNotificationClientLive"]),

        .library(name: "WatchOSApp", targets: ["WatchOSApp"]),

        .library(name: "WatchRemindersListRow", targets: ["WatchRemindersListRow"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.27.1")
    ],
    targets: [
        .target(
            name: "AppCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "AppDelegateCore",
                "RemindersListCore"
            ]
        ),
        .target(
            name: "App",
            dependencies: [
                "AppCore",
                "NotificationCenterClientLive",
                "RemindersList",
                "UIApplicationClientLive",
                "UserNotificationClientLive"
            ]
        ),

        .target(
            name: "AppDelegateCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "UserNotificationClient"
            ]
        ),

        .target(
            name: "NotificationCenterClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "NotificationCenterClientLive",
            dependencies: ["NotificationCenterClient"]
        ),

        .target(
            name: "ReminderDetailCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "NotificationCenterClient",
                "SharedModels",
                "UIApplicationClient",
                "UserNotificationClient"
            ]
        ),
        .testTarget(
            name: "ReminderDetailCoreTests",
            dependencies: ["ReminderDetailCore"]
        ),
        .target(
            name: "ReminderDetail",
            dependencies: ["ReminderDetailCore"]
        ),

        .target(
            name: "RemindersListCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SharedModels",
                "ReminderDetailCore",
                "RemindersListRowCore"
            ]
        ),
        .testTarget(
            name: "RemindersListCoreTests",
            dependencies: ["RemindersListCore"]
        ),
        .target(
            name: "RemindersList",
            dependencies: ["ReminderDetail", "RemindersListCore", "RemindersListRow"]
        ),

        .target(
            name: "RemindersListRowCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "SharedModels",
                "UserNotificationClient"
            ]
        ),
        .testTarget(
            name: "RemindersListRowCoreTests",
            dependencies: ["RemindersListRowCore"]
        ),
        .target(
            name: "RemindersListRow",
            dependencies: ["RemindersListRowCore"]
        ),

        .target(
            name: "SharedModels",
            dependencies: []
        ),
        
        .target(
            name: "UIApplicationClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "UIApplicationClientLive",
            dependencies: ["UIApplicationClient"]
        ),

        .target(
            name: "UserNotificationClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "UserNotificationClientLive",
            dependencies: ["UserNotificationClient"]
        ),

        .target(name: "WatchOSApp", dependencies: [
            "AppCore",
            "WatchRemindersListRow",
            "UserNotificationClientLive"
        ]),

        .target(name: "WatchRemindersListRow", dependencies: ["RemindersListRowCore"])
    ]
)
