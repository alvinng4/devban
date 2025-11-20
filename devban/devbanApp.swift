import FirebaseCore
import SwiftUI

/// Application delegate responsible for Firebase initialization.
class AppDelegate: NSObject, UIApplicationDelegate
{
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil,
    ) -> Bool
    {
        FirebaseApp.configure()

        return true
    }
}

/// The main application entry point for Devban.
@main
struct devbanApp: App
{
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene
    {
        WindowGroup
        {
            MainView()
        }
    }
}
