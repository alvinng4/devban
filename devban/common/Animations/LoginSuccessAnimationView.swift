import SwiftUI

// MARK: - Configuration
struct SlashConfig {
    static let coreColor: Color = .white
    static let edgeColor: Color = Color(red: 0.85, green: 0.95, blue: 1.0)
    static let glowColor: Color = Color(red: 0.6, green: 0.9, blue: 1.0).opacity(0.8)
}

// MARK: - Login Success Animation View
struct LoginSuccessAnimationView: View {
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State private var slash1Progress: CGFloat = 0
    @State private var slash2Progress: CGFloat = 0
    @State private var slashOpacity: Double = 1
    
    @State private var whiteFlashOpacity: CGFloat = 0
    @State private var textOpacity: CGFloat = 0
    @State private var textScale: CGFloat = 1.5
    @State private var textBlur: CGFloat = 20
    
    @State private var shakeOffset: CGFloat = 0
    @State private var particles: [Particle] = []
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .blur(radius: 1)
            }
            
            // First Slash
            Group {
                CurvedSlashShape(curvature: 100).fill(slashGradient).blur(radius: 20).opacity(0.7)
                CurvedSlashShape(curvature: 100).fill(coreGradient).blur(radius: 2).blendMode(.screen)
            }
            .frame(width: 2000, height: 600)
            .rotationEffect(.degrees(-35))
            .offset(x: -100, y: 50)
            .mask(
                Rectangle()
                    .fill(Color.white)
                    .offset(x: (slash1Progress - 0.5) * 4000)
                    .rotationEffect(.degrees(-35))
            )
            .opacity(slashOpacity)
            
            // Second Slash
            Group {
                CurvedSlashShape(curvature: -100).fill(slashGradient).blur(radius: 20).opacity(0.7)
                CurvedSlashShape(curvature: -100).fill(coreGradient).blur(radius: 2).blendMode(.screen)
            }
            .frame(width: 2000, height: 600)
            .rotationEffect(.degrees(35))
            .offset(x: -50, y: -50)
            .mask(
                Rectangle()
                    .fill(Color.white)
                    .offset(x: (0.5 - slash2Progress) * 4000)
                    .rotationEffect(.degrees(35))
            )
            .opacity(slashOpacity)
            
            Color.white
                .opacity(whiteFlashOpacity)
                .ignoresSafeArea()
                .blendMode(.plusLighter)
            
            Text("Devban")
                .font(.system(size: textSize, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: SlashConfig.glowColor, radius: 10)
                .tracking(8)
                .blur(radius: textBlur)
                .opacity(textOpacity)
                .scaleEffect(textScale)
                .offset(x: shakeOffset)
        }
        .task {
            await playAnimation()
        }
    }
}

// MARK: - Animation Logic
private extension LoginSuccessAnimationView {
    
    var textSize: CGFloat {
        (horizontalSizeClass == .regular && verticalSizeClass == .regular) ? 120 : 80
    }
    
    var slashGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.clear, SlashConfig.glowColor, SlashConfig.edgeColor, SlashConfig.glowColor, .clear]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var coreGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: SlashConfig.coreColor, location: 0.2),
                .init(color: SlashConfig.coreColor, location: 0.8),
                .init(color: .clear, location: 1)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Animation Logic (只顯示 playAnimation 部分)
    func playAnimation() async {
        generateParticles()
        
        // First Slash
        await SoundManager.shared.playSlashSound1()
        
        withAnimation(.easeOut(duration: 0.15)) {
            slash1Progress = 1
        }
        
        try? await Task.sleep(nanoseconds: 80_000_000)
        
        // Second Slash
        await SoundManager.shared.playSlashSound2()
        
        withAnimation(.easeOut(duration: 0.15)) {
            slash2Progress = 1
        }
        
        try? await Task.sleep(nanoseconds: 150_000_000)
        
        // Finalize Animation
        withAnimation(.easeOut(duration: 0.1)) {
            slashOpacity = 0
            whiteFlashOpacity = 1.0
        }
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) { shakeOffset = 5 }
        Task {
            try? await Task.sleep(nanoseconds: 50_000_000)
            withAnimation { shakeOffset = 0 }
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            textOpacity = 1
            textScale = 1
            textBlur = 0
        }
        
        animateParticles()
        
        // white flash fade out
        try? await Task.sleep(nanoseconds: 100_000_000)
        withAnimation(.easeOut(duration: 0.5)) {
            whiteFlashOpacity = 0
        }
        
        // play success sound
        await SoundManager.shared.playSuccessSound()
        
        // stay for a while before completing
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        onComplete()
    }

    
    func generateParticles() {
        let screenCenter = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        for _ in 0..<30 {
            let destinationPoint = CGPoint(
                x: screenCenter.x + CGFloat.random(in: -300...300),
                y: screenCenter.y + CGFloat.random(in: -300...300)
            )
            let newParticle = Particle(
                id: UUID(),
                position: screenCenter,
                destination: destinationPoint,
                size: CGFloat.random(in: 2...8),
                opacity: 1
            )
            particles.append(newParticle)
        }
    }
    
    func animateParticles() {
        for index in particles.indices {
            withAnimation(.easeOut(duration: 0.6)) {
                particles[index].position = particles[index].destination
                particles[index].opacity = 0
            }
        }
    }
}

// MARK: - Shapes
struct CurvedSlashShape: Shape {
    var curvature: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width, height = rect.height, midY = height / 2
        path.move(to: CGPoint(x: 0, y: midY))
        path.addQuadCurve(to: CGPoint(x: width, y: midY), control: CGPoint(x: width / 2, y: midY - curvature))
        path.addQuadCurve(to: CGPoint(x: 0, y: midY), control: CGPoint(x: width / 2, y: midY - (curvature * 0.2)))
        path.closeSubpath()
        return path
    }
}

struct Particle: Identifiable {
    let id: UUID
    var position: CGPoint
    var destination: CGPoint
    var size: CGFloat
    var opacity: Double
}

#Preview {
    LoginSuccessAnimationView(onComplete: {})
}
