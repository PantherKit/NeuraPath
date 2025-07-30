import SwiftUI

// MARK: - Sparkle Particle
struct SparkleParticle: View {
    let index: Int
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: CGFloat.random(in: 8...16), weight: .light))
            .foregroundColor(
                [AppTheme.Colors.cosmicCyan, AppTheme.Colors.cosmicBlue, AppTheme.Colors.cosmicPink].randomElement() ?? AppTheme.Colors.cosmicCyan
            )
            .opacity(opacity)
            .scaleEffect(scale)
            .position(
                x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                y: CGFloat.random(in: 200...UIScreen.main.bounds.height - 300)
            )
            .offset(x: offsetX, y: offsetY)
            .onAppear {
                let duration = Double.random(in: 3...6)
                let delay = Double.random(in: 0...2)
                
                withAnimation(.easeInOut(duration: 1.0).delay(delay)) {
                    opacity = Double.random(in: 0.4...0.8)
                    scale = 1.0
                }
                
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true).delay(delay)) {
                    offsetY = CGFloat.random(in: -30...30)
                    offsetX = CGFloat.random(in: -20...20)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                    withAnimation(.easeOut(duration: 1.0)) {
                        opacity = 0
                        scale = 0
                    }
                }
            }
    }
}

// MARK: - Dynamic Constellation
struct DynamicConstellation: View {
    @State private var connectionOpacity: Double = 0
    @State private var constellationRotation: Double = 0
    @State private var activeConnections: Set<Int> = []
    
    // Constellation star positions (relative to view)
    private let starPositions: [(CGFloat, CGFloat)] = [
        (0.2, 0.3), (0.4, 0.2), (0.6, 0.35), (0.8, 0.25),
        (0.3, 0.5), (0.7, 0.6), (0.5, 0.45),
        (0.25, 0.7), (0.6, 0.8), (0.75, 0.75)
    ]
    
    // Connection pairs that form meaningful paths
    private let connectionPairs: [(Int, Int)] = [
        (0, 1), (1, 2), (2, 3), // Top path
        (0, 4), (4, 6), (6, 5), // Left to center to right
        (2, 6), (6, 8), // Center connections
        (4, 7), (7, 8), (8, 9), (9, 5) // Lower path
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Connection lines
                ForEach(connectionPairs.indices, id: \.self) { index in
                    let pair = connectionPairs[index]
                    let startPos = starPositions[pair.0]
                    let endPos = starPositions[pair.1]
                    
                    Path { path in
                        path.move(to: CGPoint(
                            x: startPos.0 * geometry.size.width,
                            y: startPos.1 * geometry.size.height
                        ))
                        path.addLine(to: CGPoint(
                            x: endPos.0 * geometry.size.width,
                            y: endPos.1 * geometry.size.height
                        ))
                    }
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.cosmicCyan.opacity(0.4),
                                AppTheme.Colors.cosmicBlue.opacity(0.2),
                                AppTheme.Colors.cosmicCyan.opacity(0.4)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.2
                    )
                    .opacity(activeConnections.contains(index) ? connectionOpacity : 0.1)
                    .animation(
                        .easeInOut(duration: 2.0)
                        .delay(Double(index) * 0.3),
                        value: activeConnections
                    )
                }
                
                // Constellation stars
                ForEach(starPositions.indices, id: \.self) { index in
                    let position = starPositions[index]
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    AppTheme.Colors.cosmicCyan.opacity(0.6),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 4
                            )
                        )
                        .frame(width: 6, height: 6)
                        .position(
                            x: position.0 * geometry.size.width,
                            y: position.1 * geometry.size.height
                        )
                        .scaleEffect(connectionOpacity > 0.5 ? 1.2 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .delay(Double(index) * 0.1),
                            value: connectionOpacity
                        )
                }
            }
        }
        .frame(height: 250)
        .rotationEffect(.degrees(constellationRotation))
        .onAppear {
            startConstellationAnimation()
        }
    }
    
    private func startConstellationAnimation() {
        // Initial connection reveal
        withAnimation(.easeOut(duration: 2.0).delay(0.5)) {
            connectionOpacity = 0.8
        }
        
        // Gradual connection activation
        for i in 0..<connectionPairs.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4 + 1.0) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    _ = activeConnections.insert(i)
                }
            }
        }
        
        // Subtle rotation
        withAnimation(.linear(duration: 120).repeatForever(autoreverses: false).delay(3.0)) {
            constellationRotation = 360
        }
        
        // Dynamic connection cycling
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            cycleDynamicConnections()
        }
    }
    
    private func cycleDynamicConnections() {
        withAnimation(.easeInOut(duration: 1.5)) {
            // Fade some connections
            let connectionsToFade = Array(activeConnections.prefix(3))
            for connection in connectionsToFade {
                activeConnections.remove(connection)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 1.5)) {
                // Reactivate different connections
                let newConnections = connectionPairs.indices.shuffled().prefix(5)
                for connection in newConnections {
                    _ = activeConnections.insert(connection)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            SparkleParticle(index: 0)
            DynamicConstellation()
        }
    }
    .preferredColorScheme(.dark)
} 