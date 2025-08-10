import SwiftUI

struct RocketPathView: View {
    @Binding var pathProgress: CGFloat
    @Binding var rocketPosition: CGFloat
    @Binding var rocketPositionX: CGFloat
    @Binding var rocketRotation: Double
    @Binding var showRocketBoost: Bool
    @Binding var rocketTrailOpacity: Double
    @Binding var showRocketParticles: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            path
                .trim(from: 0, to: pathProgress)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                .foregroundColor(.white.opacity(0.5))
                .animation(.easeInOut(duration: 0.8), value: pathProgress)

            if rocketTrailOpacity > 0 {
                trail
                    .offset(x: rocketPositionX, y: -rocketPosition + 40)
                    .opacity(rocketTrailOpacity)
            }

            Text("🚀")
                .font(.system(size: 60))
                .rotationEffect(.degrees(rocketRotation))
                .offset(x: rocketPositionX, y: -rocketPosition)
                .overlay(
                    Group {
                        if showRocketBoost { booster.offset(y: 30) }
                    }
                )
        }
        .frame(height: 280)
        .padding(.vertical)
    }

    private var path: Path {
        Path { p in
            let width = UIScreen.main.bounds.width
            p.move(to: CGPoint(x: width/2, y: 280))
            for i in 1...8 {
                let xOffset: CGFloat = i % 2 == 0 ? 50 : -50
                let yStep: CGFloat = 240 / 9
                p.addLine(to: CGPoint(x: width/2 + xOffset, y: 280 - CGFloat(i) * yStep))
            }
            p.addLine(to: CGPoint(x: width/2, y: 0))
        }
    }

    private var trail: some View {
        VStack(spacing: 0) {
            ForEach(0..<10) { i in
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0.7), AppTheme.Colors.cosmicCyan.opacity(0.5), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 20 - CGFloat(i), height: 20 - CGFloat(i))
                    .offset(y: CGFloat(i) * 5)
                    .opacity(1.0 - Double(i) * 0.1)
                    .blur(radius: 0.5)
            }
        }
    }

    private var booster: some View {
        VStack(spacing: 0) {
            ForEach(0..<7) { i in
                let size = 20 - CGFloat(i) * 2
                let opacity = 1.0 - Double(i) * 0.15
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.yellow, .orange, .red]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: size, height: size)
                    .offset(y: CGFloat(i) * 5 + 10)
                    .opacity(opacity)
                    .blur(radius: 1)
            }
        }
    }
}


