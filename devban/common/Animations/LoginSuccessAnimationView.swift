import SwiftUI

/// A view that displays a login success animation with sword flash, white flash, and text fade-in effects.
/// Fully adapted for iPhone, iPad, and Mac (Catalyst)
struct LoginSuccessAnimationView: View {
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State private var swordFlashProgress: CGFloat = 0
    @State private var whiteFlashOpacity: CGFloat = 0
    @State private var textOpacity: CGFloat = 0
    @State private var textScale: CGFloat = 0.5
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // background
            Color.black
                .ignoresSafeArea()
            
            // sword flash (0s - 0.4s)
            SwordFlashShape()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0), location: 0),
                            .init(color: ThemeManager.shared.buttonColor.opacity(0.8), location: 0.4),
                            .init(color: ThemeManager.shared.buttonColor.opacity(0.4), location: 0.6),
                            .init(color: Color.white.opacity(0), location: 1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .offset(x: swordFlashProgress * getFlashDistance() - getFlashDistance() / 2)
                .opacity(swordFlashProgress < 1 ? 1 : 0)
            
            // white flash (0.4s - 0.55s)
            Color.white
                .opacity(whiteFlashOpacity)
                .ignoresSafeArea()
            
            // wordmark text (0.55s - 1.15s)
            VStack(spacing: 20) {
                Text("Devban")
                    .font(.system(size: getTextSize(), weight: .bold, design: .rounded))
                    .foregroundColor(ThemeManager.shared.buttonColor)
                    .tracking(2)
                    .opacity(textOpacity)
                    .scaleEffect(textScale)
            }
        }
        .task {
            await playAnimation()
        }
    }
    
    /// get the distance the sword flash needs to travel based on device type
    private func getFlashDistance() -> CGFloat {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            // iPad or Mac
            return 1200
        } else if horizontalSizeClass == .compact {
            // iPhone
            return 800
        } else {
            // iPad landscape
            return 1000
        }
    }
    
    /// get the appropriate text size based on device type
    private func getTextSize() -> CGFloat {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            // iPad or Mac - larger text
            return 96
        } else if horizontalSizeClass == .compact {
            // iPhone - standard text
            return 72
        } else {
            // iPad landscape - medium text
            return 84
        }
    }
    
    /// plays the full login success animation sequence asynchronously
    private func playAnimation() async {
        // First stage: sword flash (0.4 seconds)
        withAnimation(.easeInOut(duration: 0.4)) {
            swordFlashProgress = 1.0
        }
        
        // Wait for the sword flash to complete
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 秒
        
        // Second stage: white flash (0.15 seconds)
        withAnimation(.easeInOut(duration: 0.15)) {
            whiteFlashOpacity = 0.6
        }
        
        // Delay and restore black background
        try? await Task.sleep(nanoseconds: 150_000_000) // 0.15 秒
        
        withAnimation(.easeInOut(duration: 0.1)) {
            whiteFlashOpacity = 0
        }

        // Third stage: text fade-in (0.6 seconds)
        withAnimation(.easeOut(duration: 0.6)) {
            textOpacity = 1.0
            textScale = 1.0
        }

        // Wait for animation to complete
        try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2 seconds

        // Play success sound
        await SoundManager.shared.playSuccessSound()
        
        // Short delay before calling completion
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Call the completion handler
        onComplete()
    }
}

/// A custom shape representing the sword flash effect.
struct SwordFlashShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let startX = rect.minX
        let endX = rect.maxX
        let startY = rect.minY - 200
        let endY = rect.maxY + 200
        
        // Create a diagonal rectangle as the sword flash
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: endX, y: startY))
        path.addLine(to: CGPoint(x: endX + 50, y: endY))
        path.addLine(to: CGPoint(x: startX + 50, y: endY))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    LoginSuccessAnimationView(onComplete: {
        print("Animation completed!")
    })
}
