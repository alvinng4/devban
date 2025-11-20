import SwiftUI

/// Manages haptic feedback throughout the application.
///
/// This singleton provides methods to trigger different types of haptic feedback
/// based on user actions and events, respecting user preferences.
final class HapticManager
{
    /// Shared singleton instance
    static let shared = HapticManager()

    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let lightFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    private init() {}

    /// Plays a success haptic notification if enabled in user settings.
    @MainActor
    func playSuccessNotification()
    {
        guard DevbanUserContainer.shared.getHapticEffectSetting() else { return }

        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
    }

    /// Plays a warning haptic notification if enabled in user settings.
    @MainActor
    func playWarningNotification()
    {
        guard DevbanUserContainer.shared.getHapticEffectSetting() else { return }

        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.warning)
    }

    /// Plays an error haptic notification if enabled in user settings.
    @MainActor
    func playErrorNotification()
    {
        guard DevbanUserContainer.shared.getHapticEffectSetting() else { return }

        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.error)
    }

    /// Plays a light haptic feedback if enabled in user settings.
    @MainActor
    func playLightFeedback()
    {
        guard DevbanUserContainer.shared.getHapticEffectSetting() else { return }

        lightFeedbackGenerator.prepare()
        lightFeedbackGenerator.impactOccurred()
    }
}
