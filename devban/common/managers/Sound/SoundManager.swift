#if targetEnvironment(macCatalyst)
    import AVFoundation

    final class SoundManager
    {
        static let shared = SoundManager()

        private init() {}

        var player: AVAudioPlayer?

        @MainActor
        func playSuccessSound()
        {
            guard DevbanUserContainer.shared.getSoundEffectSetting() else { return }

            guard let url = Bundle.main.url(forResource: "payment_success", withExtension: "caf")
            else
            {
                print("payment_success.caf audio file not found")
                return
            }

            do
            {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            }
            catch
            {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }
#else
    import AudioToolbox

    final class SoundManager
    {
        static let shared = SoundManager()

        private init() {}

        @MainActor
        func playSuccessSound()
        {
            guard DevbanUserContainer.shared.getSoundEffectSetting() else { return }

            AudioServicesPlaySystemSound(1407)
        }
    }
#endif
