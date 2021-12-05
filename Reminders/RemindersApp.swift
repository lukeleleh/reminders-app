import App
import SwiftUI

@main
struct RemindersApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RemindersAppView(store: appDelegate.store)
        }
    }
}
