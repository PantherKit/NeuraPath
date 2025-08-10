import SwiftUI

struct DynamicConstellation: View {
    @State private var connectionOpacity: Double = 0
    @State private var constellationRotation: Double = 0
    @State private var activeConnections: Set<Int> = []

    private let starPositions: [(CGFloat, CGFloat)] = [
        (0.2, 0.3), (0.4, 0.2), (0.6, 0.35), (0.8, 0.25),
        (0.3, 0.5), (0.7, 0.6), (0.5, 0.45), (0.25, 0.7), (0.6, 0.8), (0.75, 0.75)
    ]
    private let connectionPairs: [(Int, Int)] = [
        (0, 1), (1, 2), (2, 3), (0, 4), (4, 6), (6, 5), (2, 6), (6, 8), (4, 7), (7, 8), (8, 9), (9, 5)
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(connectionPairs.indices, id: \.self) { index in
                    let pair = connectionPairs[index]
                    let startPos = starPositions[pair.0]
                    let endPos = starPositions[pair.1]
                    Path { path in
                        path.move(to: CGPoint(x: startPos.0 * geometry.size.width, y: startPos.1 * geometry.size.height))
                        path.addLine(to: CGPoint(x: endPos.0 * geometry.size.width, y: endPos.1 * geometry.size.height))
                    }
                    .stroke(
                        LinearGradient(colors: [AppTheme.Colors.cosmicCyan.opacity(0.4), AppTheme.Colors.cosmicBlue.opacity(0.2), AppTheme.Colors.cosmicCyan.opacity(0.4)], startPoint: .leading, endPoint: .trailing),
                        lineWidth: 1.2
                    )
                    .opacity(activeConnections.contains(index) ? connectionOpacity : 0.1)
                    .animation(.easeInOut(duration: 2.0).delay(Double(index) * 0.3), value: activeConnections)
                }
                ForEach(starPositions.indices, id: \.self) { index in
                    let position = starPositions[index]
                    Circle()
                        .fill(
                            RadialGradient(colors: [Color.white.opacity(0.9), AppTheme.Colors.cosmicCyan.opacity(0.6), Color.clear], center: .center, startRadius: 0, endRadius: 4)
                        )
                        .frame(width: 6, height: 6)
                        .position(x: position.0 * geometry.size.width, y: position.1 * geometry.size.height)
                        .scaleEffect(connectionOpacity > 0.5 ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.5).delay(Double(index) * 0.1), value: connectionOpacity)
                }
            }
        }
        .frame(height: 250)
        .rotationEffect(.degrees(constellationRotation))
        .onAppear { startConstellationAnimation() }
    }

    private func startConstellationAnimation() {
        withAnimation(.easeOut(duration: 2.0).delay(0.5)) { connectionOpacity = 0.8 }
        for i in 0..<connectionPairs.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4 + 1.0) {
                withAnimation(.easeInOut(duration: 1.0)) { _ = activeConnections.insert(i) }
            }
        }
        withAnimation(.linear(duration: 120).repeatForever(autoreverses: false).delay(3.0)) {
            constellationRotation = 360
        }
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            cycleDynamicConnections()
        }
    }

    private func cycleDynamicConnections() {
        withAnimation(.easeInOut(duration: 1.5)) {
            let toFade = Array(activeConnections.prefix(3))
            for c in toFade { activeConnections.remove(c) }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 1.5)) {
                let newConnections = connectionPairs.indices.shuffled().prefix(5)
                for c in newConnections { _ = activeConnections.insert(c) }
            }
        }
    }
}


