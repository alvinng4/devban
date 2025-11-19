import SwiftUI

final class HapticManager
{
    static let shared = HapticManager()

    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let lightFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    private init() {}

    @MainActor
    func playSuccessNotification()
    {
        guard DevbanUserContainer.shared.getHapticEffectSetting() else { return }

        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
    }

    @MainActor
    func playWarningNotification()
    {
        guard DevbanUserContainer.shared.getHapticEffectSetting() else { return }

        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.warning)
    }

    @MainActor
    func playErrorNotification()
    {
        guard DevbanUserContainer.shared.getHapticEffectSetting() else { return }

        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.error)
    }

    @MainActor
    func playLightFeedback()
    {
        guard DevbanUserContainer.shared.getHapticEffectSetting() else { return }

        lightFeedbackGenerator.prepare()
        lightFeedbackGenerator.impactOccurred()
    }
}
