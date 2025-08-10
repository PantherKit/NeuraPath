import SwiftUI

// MARK: - Reusable Glass Background for Cards
struct GlassCardBackground: View {
    let cornerRadius: CGFloat
    let level: AppTheme.GlassLevel
    let shimmerOffset: CGFloat

    init(cornerRadius: CGFloat = 20, level: AppTheme.GlassLevel = .primary, shimmerOffset: CGFloat = -200) {
        self.cornerRadius = cornerRadius
        self.level = level
        self.shimmerOffset = shimmerOffset
    }

    var body: some View {
        ZStack {
            // Base glass layers
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .opacity(level.opacity)

            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.thinMaterial)
                .opacity(level == .primary ? 0.6 : 0.3)

            // Tint
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(level.tint)

            // Natural light reflection
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.22),
                            Color.white.opacity(0.1),
                            Color.clear,
                            Color.clear,
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Border
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(level.borderGradient, lineWidth: AppTheme.Layout.glassBorderWidth)

            // Shimmer (organic shine)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    EllipticalGradient(
                        colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.08),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.3 + (shimmerOffset / UIScreen.main.bounds.width) * 0.4, y: 0.2),
                        startRadiusFraction: 0.1,
                        endRadiusFraction: 0.8
                    )
                )
                .mask(RoundedRectangle(cornerRadius: cornerRadius))
                .opacity(0.5)
        }
    }
}

// MARK: - Glow Effect
struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius, x: x, y: y)
    }
}

extension View {
    func glow(color: Color, radius: CGFloat = AppTheme.CosmicEffects.glowMediumRadius, x: CGFloat = 0, y: CGFloat = 0) -> some View {
        modifier(GlowEffect(color: color, radius: radius, x: x, y: y))
    }
}


