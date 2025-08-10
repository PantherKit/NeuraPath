import SwiftUI

struct SparkleParticle: View {
    let index: Int
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0

    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: CGFloat.random(in: 8...16), weight: .light))
            .foregroundColor([
                AppTheme.Colors.cosmicCyan,
                AppTheme.Colors.cosmicBlue,
                AppTheme.Colors.cosmicPink
            ].randomElement() ?? AppTheme.Colors.cosmicCyan)
            .opacity(opacity)
            .scaleEffect(scale)
            .position(x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50), y: CGFloat.random(in: 200...UIScreen.main.bounds.height - 300))
            .offset(x: offsetX, y: offsetY)
            .onAppear {
                let duration = Double.random(in: 3...6)
                let delay = Double.random(in: 0...2)
                withAnimation(.easeInOut(duration: 1.0).delay(delay)) {
                    opacity = Double.random(in: 0.4...0.8); scale = 1.0
                }
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true).delay(delay)) {
                    offsetY = CGFloat.random(in: -30...30); offsetX = CGFloat.random(in: -20...20)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                    withAnimation(.easeOut(duration: 1.0)) { opacity = 0; scale = 0 }
                }
            }
    }
}


