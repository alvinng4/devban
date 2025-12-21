import Foundation

extension Notification.Name {
    
    /// A notification posted when a user successfully logs in.
    ///
    /// This notification signal is typically observed by the root view (e.g., `MainView`) to trigger
    /// post-login visual effects, such as the `LoginSuccessAnimationView`.
    ///
    /// - Usage:
    ///   - **Post:** Call this from the view model or authentication service when the login API returns success.
    ///   - **Observe:** Listen in the main UI layer to present overlays or transition views.
    static let loginSuccessAnimation = Notification.Name("loginSuccessAnimation")
}
