import SwiftUI

// MARK: - Magazine Cosmic Background
struct MagazineCosmicBackground: View {
    @State private var nebulaeRotation: Double = 0
    @State private var starsShimmer = false
    
    var body: some View {
        ZStack {
            // Deep space gradient
            RadialGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color.black,
                    Color(red: 0.05, green: 0.02, blue: 0.15)
                ],
                center: .center,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height
            )
            
            // Sophisticated nebulae layers
            ZStack {
                // Primary nebula
                EllipticalGradient(
                    colors: [
                        AppTheme.Colors.cosmicBlue.opacity(0.08),
                        AppTheme.Colors.cosmicCyan.opacity(0.04),
                        Color.clear
                    ],
                    center: .topTrailing,
                    startRadiusFraction: 0.1,
                    endRadiusFraction: 0.8
                )
                .blur(radius: 30)
                .rotationEffect(.degrees(nebulaeRotation))
                
                // Secondary nebula
                EllipticalGradient(
                    colors: [
                        AppTheme.Colors.cosmicPurple.opacity(0.06),
                        AppTheme.Colors.cosmicPink.opacity(0.03),
                        Color.clear
                    ],
                    center: .bottomLeading,
                    startRadiusFraction: 0.2,
                    endRadiusFraction: 0.9
                )
                .blur(radius: 40)
                .rotationEffect(.degrees(-nebulaeRotation * 0.7))
            }
            
            // Refined star field
            ForEach(0..<25, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.4...0.9)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 20...UIScreen.main.bounds.width - 20),
                        y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 100)
                    )
                    .scaleEffect(starsShimmer ? Double.random(in: 0.8...1.4) : 1.0)
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...3)),
                        value: starsShimmer
                    )
            }
        }
        .onAppear {
            starsShimmer = true
            
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                nebulaeRotation = 360
            }
        }
    }
}

// MARK: - Animated Star Field
struct AnimatedStarField: View {
    let numberOfStars: Int
    let starBrightness: Double
    let starSpeed: Double
    
    @State private var starPositions: [CGPoint] = []
    @State private var starOpacities: [Double] = []
    
    var body: some View {
        ZStack {
            ForEach(0..<numberOfStars, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(starPositions.indices.contains(index) ? starPositions[index] : .zero)
                    .opacity(starOpacities.indices.contains(index) ? starOpacities[index] : 0)
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)),
                        value: starOpacities.indices.contains(index) ? starOpacities[index] : 0
                    )
            }
        }
        .onAppear {
            generateStars()
        }
    }
    
    private func generateStars() {
        starPositions = (0..<numberOfStars).map { _ in
            CGPoint(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
            )
        }
        
        starOpacities = (0..<numberOfStars).map { _ in
            Double.random(in: 0.3...starBrightness)
        }
    }
}

// MARK: - Star Field (Simple)
struct StarField: View {
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                    .frame(width: CGFloat.random(in: 1...2))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MagazineCosmicBackground()
        .preferredColorScheme(.dark)
} 