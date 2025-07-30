//
//  GlassComponents.swift
//  Desarrollo-PantherKit - Cosmic Glassmorphism System
//
//  Created on 5/11/25.
//

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
                withAnimation(AppTheme.Animation.buttonPress) {
                    action()
                }
                // Haptic feedback
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }) {
            HStack(spacing: AppTheme.Layout.spacingS) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.fontSize * 0.9, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: size.fontSize, weight: .semibold, design: .rounded))
            }
            .padding(size.padding)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(backgroundForStyle)
            .foregroundColor(textColorForStyle)
            .cornerRadius(size.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(borderForStyle, lineWidth: AppTheme.Layout.glassBorderWidth)
            )
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
                Color.clear
                    .background(.ultraThinMaterial)
                    .opacity(AppTheme.Glass.opacityMedium)
            case .minimal:
                Color.clear
                    .background(.ultraThinMaterial)
                    .opacity(AppTheme.Glass.opacityLight)
            case .destructive:
                LinearGradient(
                    colors: [Color.red.opacity(0.8), Color.pink.opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
    }
    
    private var textColorForStyle: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary, .minimal:
            return AppTheme.Colors.cosmicCyan
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
            return LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.6), Color.pink.opacity(0.3), Color.clear]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var shadowColorForStyle: Color {
        switch style {
        case .primary:
            return AppTheme.Colors.glowCyan
        case .secondary:
            return AppTheme.Colors.glowBlue.opacity(0.3)
        case .minimal:
            return AppTheme.Colors.glowWhite.opacity(0.2)
        case .destructive:
            return Color.red.opacity(0.4)
        }
    }
    
    private var shadowRadiusForStyle: CGFloat {
        switch style {
        case .primary:
            return AppTheme.CosmicEffects.glowMediumRadius
        case .secondary:
            return AppTheme.CosmicEffects.glowSubtleRadius
        case .minimal:
            return 4
        case .destructive:
            return AppTheme.CosmicEffects.glowSubtleRadius
        }
    }
}

// MARK: - Glass Text Field
struct CosmicGlassTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String?
    
    @State private var isFocused = false
    
    init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        icon: String? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.spacingS) {
            if !title.isEmpty {
                Text(title)
                    .font(AppTheme.Typography.cosmicHeadline(AppTheme.Typography.subheadline))
                    .foregroundColor(AppTheme.Colors.cosmicCyan)
            }
            
            HStack(spacing: AppTheme.Layout.spacingM) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: AppTheme.Typography.body, weight: .medium))
                        .foregroundColor(isFocused ? AppTheme.Colors.cosmicCyan : AppTheme.Colors.glassLight)
                        .animation(AppTheme.Animation.quickAnimation, value: isFocused)
                }
                
                TextField(placeholder, text: $text)
                    .font(AppTheme.Typography.cosmicBody())
                    .foregroundColor(.white)
                    .accentColor(AppTheme.Colors.cosmicCyan)
                    .onTapGesture {
                        isFocused = true
                    }
            }
            .padding(AppTheme.Layout.spacingM)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusM)
                    .fill(.ultraThinMaterial)
                    .opacity(AppTheme.Glass.opacityLight)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusM)
                            .fill(AppTheme.Colors.cosmicCyan.opacity(isFocused ? 0.1 : 0.05))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusM)
                    .stroke(
                        isFocused ? AppTheme.Glass.primaryBorder : AppTheme.Glass.secondaryBorder,
                        lineWidth: isFocused ? AppTheme.Layout.glassBorderWidthThick : AppTheme.Layout.glassBorderWidth
                    )
                    .animation(AppTheme.Animation.quickAnimation, value: isFocused)
            )
            .shadow(
                color: isFocused ? AppTheme.Colors.glowCyan.opacity(0.3) : Color.clear,
                radius: AppTheme.CosmicEffects.glowSubtleRadius,
                x: 0,
                y: 2
            )
        }
    }
}

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
        .onAppear {
            if showParticles {
                animateParticles = true
            }
        }
    }
}

 