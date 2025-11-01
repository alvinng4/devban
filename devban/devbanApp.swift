import FirebaseCore
import SwiftUI

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
