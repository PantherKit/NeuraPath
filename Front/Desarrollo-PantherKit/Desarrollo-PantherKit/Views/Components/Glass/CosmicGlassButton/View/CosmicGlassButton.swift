import SwiftUI

// MARK: - Cosmic Glass Button
struct CosmicGlassButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let size: ButtonSize
    let isFullWidth: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    enum ButtonStyle {
        case primary      // Filled with cosmic gradient
        case secondary    // Glass with border
        case minimal      // Just glass, no strong border
        case destructive  // Red tinted glass
    }
    
    enum ButtonSize {
        case small, medium, large
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            case .medium: return EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
            case .large: return EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return AppTheme.Typography.footnote
            case .medium: return AppTheme.Typography.body
            case .large: return AppTheme.Typography.headline
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return AppTheme.Layout.glassRadiusS
            case .medium: return AppTheme.Layout.glassRadiusM
            case .large: return AppTheme.Layout.glassRadiusL
            }
        }
    }
    
    init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        isFullWidth: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isFullWidth = isFullWidth
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if !isDisabled {
                withAnimation(AppTheme.Animation.buttonPress) { action() }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }) {
            HStack(spacing: AppTheme.Layout.spacingS) {
                if let icon = icon { Image(systemName: icon).font(.system(size: size.fontSize * 0.9, weight: .semibold)) }
                Text(title).font(.system(size: size.fontSize, weight: .semibold, design: .rounded))
            }
            .padding(size.padding)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(backgroundForStyle)
            .foregroundColor(textColorForStyle)
            .cornerRadius(size.cornerRadius)
            .overlay(RoundedRectangle(cornerRadius: size.cornerRadius).stroke(borderForStyle, lineWidth: AppTheme.Layout.glassBorderWidth))
            .shadow(color: shadowColorForStyle, radius: shadowRadiusForStyle, x: 0, y: 4)
            .opacity(isDisabled ? 0.6 : 1.0)
            .scaleEffect(isDisabled ? 0.95 : 1.0)
        }
        .disabled(isDisabled)
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Style Properties
    private var backgroundForStyle: some View {
        Group {
            switch style {
            case .primary:
                AppTheme.CosmicEffects.primaryButtonGradient
            case .secondary:
                Color.clear.background(.ultraThinMaterial).opacity(AppTheme.Glass.opacityMedium)
            case .minimal:
                Color.clear.background(.ultraThinMaterial).opacity(AppTheme.Glass.opacityLight)
            case .destructive:
                LinearGradient(colors: [Color.red.opacity(0.8), Color.pink.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
            }
        }
    }
    
    private var textColorForStyle: Color {
        switch style {
        case .primary, .destructive: return .white
        case .secondary, .minimal: return AppTheme.Colors.cosmicCyan
        }
    }
    
    private var borderForStyle: LinearGradient {
        switch style {
        case .primary:
            return LinearGradient(gradient: Gradient(colors: [Color.clear]), startPoint: .leading, endPoint: .trailing)
        case .secondary:
            return AppTheme.Glass.primaryBorder
        case .minimal:
            return AppTheme.Glass.secondaryBorder
        case .destructive:
            return LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.6), Color.pink.opacity(0.3), Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    private var shadowColorForStyle: Color {
        switch style {
        case .primary: return AppTheme.Colors.glowCyan
        case .secondary: return AppTheme.Colors.glowBlue.opacity(0.3)
        case .minimal: return AppTheme.Colors.glowWhite.opacity(0.2)
        case .destructive: return Color.red.opacity(0.4)
        }
    }
    
    private var shadowRadiusForStyle: CGFloat {
        switch style {
        case .primary: return AppTheme.CosmicEffects.glowMediumRadius
        case .secondary: return AppTheme.CosmicEffects.glowSubtleRadius
        case .minimal: return 4
        case .destructive: return AppTheme.CosmicEffects.glowSubtleRadius
        }
    }
}


