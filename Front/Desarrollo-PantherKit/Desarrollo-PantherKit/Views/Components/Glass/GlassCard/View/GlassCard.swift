import SwiftUI

// MARK: - Glass Card Base Component
struct GlassCard<Content: View>: View {
    let level: AppTheme.GlassLevel
    let cornerRadius: CGFloat
    let content: () -> Content
    
    init(
        level: AppTheme.GlassLevel = .secondary,
        cornerRadius: CGFloat = AppTheme.Layout.glassRadiusM,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.level = level
        self.cornerRadius = cornerRadius
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(AppTheme.Layout.spacingL)
            .background(
                ZStack {
                    // Glass background
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(level.opacity)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(level.tint)
                        )
                    
                    // Border gradient
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(level.borderGradient, lineWidth: AppTheme.Layout.glassBorderWidth)
                }
            )
            .shadow(
                color: AppTheme.Colors.cosmicCyan.opacity(0.1),
                radius: AppTheme.CosmicEffects.glowSubtleRadius,
                x: 0,
                y: 4
            )
    }
}


