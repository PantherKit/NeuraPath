import SwiftUI

// MARK: - Glass Progress View
struct CosmicGlassProgressView: View {
    let progress: Double
    let trackColor: Color
    let fillColor: Color
    let showParticles: Bool
    
    @State private var animateParticles = false
    
    init(
        progress: Double,
        trackColor: Color = AppTheme.Colors.glassMedium,
        fillColor: Color = AppTheme.Colors.cosmicCyan,
        showParticles: Bool = true
    ) {
        self.progress = progress
        self.trackColor = trackColor
        self.fillColor = fillColor
        self.showParticles = showParticles
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusS)
                    .fill(.ultraThinMaterial)
                    .opacity(AppTheme.Glass.opacityLight)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusS)
                            .fill(trackColor)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusS)
                            .stroke(AppTheme.Glass.secondaryBorder, lineWidth: 1)
                    )
                
                // Fill
                RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusS)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [fillColor, fillColor.opacity(0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(max(0, min(1, progress))))
                    .shadow(color: fillColor.opacity(0.5), radius: 4, x: 0, y: 0)
                    .animation(AppTheme.Animation.cosmicSpring, value: progress)
                
                // Particles (optional)
                if showParticles && progress > 0 {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 2, height: 2)
                            .offset(
                                x: (geometry.size.width * CGFloat(progress)) - 10 + CGFloat(i * 4),
                                y: animateParticles ? -2 : 2
                            )
                            .opacity(animateParticles ? 0 : 1)
                            .animation(
                                Animation.easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.2),
                                value: animateParticles
                            )
                    }
                }
            }
        }
        .onAppear { if showParticles { animateParticles = true } }
    }
}


