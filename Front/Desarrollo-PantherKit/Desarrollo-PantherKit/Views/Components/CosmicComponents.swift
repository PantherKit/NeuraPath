//
//  CosmicComponents.swift
//  Desarrollo-PantherKit - Cosmic Specialized Components
//
//  Created on 5/11/25.
//

import SwiftUI

// MARK: - Cosmic Background
struct CosmicBackground: View {
    let showNebulas: Bool
    let showStars: Bool
    let intensity: Double
    
    @State private var nebulaAnimation = false
    
    init(
        showNebulas: Bool = true,
        showStars: Bool = true,
        intensity: Double = 1.0
    ) {
        self.showNebulas = showNebulas
        self.showStars = showStars
        self.intensity = intensity
    }
    
    var body: some View {
        ZStack {
            // Base space gradient
            AppTheme.CosmicEffects.spaceGradient
                .ignoresSafeArea()
            
            // Animated star field
            if showStars {
                StarField()
                    .opacity(intensity)
            }
            
            // Floating nebulas
            if showNebulas {
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(nebulaGradient(for: i))
                        .frame(width: 300 + CGFloat(i * 50), height: 300 + CGFloat(i * 50))
                        .position(nebulaPosition(for: i))
                        .blur(radius: 60 + CGFloat(i * 20))
                        .opacity(intensity * 0.7)
                        .scaleEffect(nebulaAnimation ? 1.1 : 0.9)
                        .animation(
                            Animation.easeInOut(duration: Double(4 + i))
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.5),
                            value: nebulaAnimation
                        )
                }
            }
        }
        .onAppear {
            nebulaAnimation = true
        }
    }
    
    private func nebulaGradient(for index: Int) -> RadialGradient {
        let colors: [[Color]] = [
            [AppTheme.Colors.cosmicCyan, AppTheme.Colors.cosmicBlue],
            [AppTheme.Colors.cosmicPurple, AppTheme.Colors.cosmicPink],
            [AppTheme.Colors.cosmicBlue, AppTheme.Colors.cosmicIndigo],
            [AppTheme.Colors.cosmicPink, AppTheme.Colors.cosmicCyan]
        ]
        
        let colorPair = colors[index % colors.count]
        return RadialGradient(
            colors: [colorPair[0].opacity(0.3), colorPair[1].opacity(0.1), Color.clear],
            center: .center,
            startRadius: 0,
            endRadius: 200
        )
    }
    
    private func nebulaPosition(for index: Int) -> CGPoint {
        let positions: [CGPoint] = [
            CGPoint(x: UIScreen.main.bounds.width * 0.2, y: UIScreen.main.bounds.height * 0.3),
            CGPoint(x: UIScreen.main.bounds.width * 0.8, y: UIScreen.main.bounds.height * 0.7),
            CGPoint(x: UIScreen.main.bounds.width * 0.7, y: UIScreen.main.bounds.height * 0.2),
            CGPoint(x: UIScreen.main.bounds.width * 0.3, y: UIScreen.main.bounds.height * 0.8)
        ]
        return positions[index % positions.count]
    }
}

// MARK: - Cosmic Toast Notification
struct CosmicToast: View {
    let message: String
    let icon: String
    let type: ToastType
    @Binding var isShowing: Bool
    
    enum ToastType {
        case success, warning, error, info
        
        var color: Color {
            switch self {
            case .success: return AppTheme.Colors.success
            case .warning: return AppTheme.Colors.warning
            case .error: return AppTheme.Colors.error
            case .info: return AppTheme.Colors.cosmicCyan
            }
        }
        
        var defaultIcon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    var body: some View {
        if isShowing {
            HStack(spacing: AppTheme.Layout.spacingM) {
                Image(systemName: icon.isEmpty ? type.defaultIcon : icon)
                    .font(.system(size: AppTheme.Typography.title3, weight: .semibold))
                    .foregroundColor(type.color)
                
                Text(message)
                    .font(AppTheme.Typography.cosmicBody())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button(action: {
                    withAnimation(AppTheme.Animation.quickAnimation) {
                        isShowing = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: AppTheme.Typography.footnote, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.glassLight)
                }
            }
            .padding(AppTheme.Layout.spacingL)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusM)
                    .fill(.ultraThinMaterial)
                    .opacity(AppTheme.Glass.opacityMedium)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusM)
                            .fill(type.color.opacity(0.1))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusM)
                    .stroke(
                        LinearGradient(
                            colors: [type.color.opacity(0.6), type.color.opacity(0.2), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: AppTheme.Layout.glassBorderWidth
                    )
            )
            .shadow(color: type.color.opacity(0.3), radius: AppTheme.CosmicEffects.glowSubtleRadius, x: 0, y: 4)
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
        }
    }
}

// MARK: - Cosmic Modal
struct CosmicModal<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String
    let showCloseButton: Bool
    let content: () -> Content
    
    init(
        isPresented: Binding<Bool>,
        title: String = "",
        showCloseButton: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.title = title
        self.showCloseButton = showCloseButton
        self.content = content
    }
    
    var body: some View {
        if isPresented {
            ZStack {
                // Backdrop
                CosmicBackground(intensity: 0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(AppTheme.Animation.cosmicSpring) {
                            isPresented = false
                        }
                    }
                
                // Modal content
                VStack(spacing: AppTheme.Layout.spacingL) {
                    // Header
                    if !title.isEmpty || showCloseButton {
                        HStack {
                            if !title.isEmpty {
                                Text(title)
                                    .font(AppTheme.Typography.cosmicTitle(AppTheme.Typography.title2))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            if showCloseButton {
                                Button(action: {
                                    withAnimation(AppTheme.Animation.cosmicSpring) {
                                        isPresented = false
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: AppTheme.Typography.title3, weight: .medium))
                                        .foregroundColor(AppTheme.Colors.glassLight)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.Layout.spacingL)
                        .padding(.top, AppTheme.Layout.spacingL)
                    }
                    
                    // Content
                    content()
                        .padding(.horizontal, AppTheme.Layout.spacingL)
                        .padding(.bottom, AppTheme.Layout.spacingL)
                }
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusL)
                        .fill(.regularMaterial)
                        .opacity(AppTheme.Glass.opacityHeavy)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusL)
                                .fill(AppTheme.Colors.cosmicCyan.opacity(0.05))
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusL)
                        .stroke(AppTheme.Glass.primaryBorder, lineWidth: AppTheme.Layout.glassBorderWidthThick)
                )
                .shadow(
                    color: AppTheme.Colors.glowCyan.opacity(0.2),
                    radius: AppTheme.CosmicEffects.glowMediumRadius,
                    x: 0,
                    y: 8
                )
                .padding(AppTheme.Layout.spacingXL)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
            }
        }
    }
}

// MARK: - Cosmic Loading View
struct CosmicLoadingView: View {
    let message: String
    let showParticles: Bool
    
    @State private var rotation = 0.0
    @State private var particleOffset = 0.0
    
    init(
        message: String = "Cargando...",
        showParticles: Bool = true
    ) {
        self.message = message
        self.showParticles = showParticles
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Layout.spacingXL) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(AppTheme.Glass.secondaryBorder, lineWidth: 3)
                    .frame(width: 80, height: 80)
                
                // Inner spinning element
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(
                        AppTheme.CosmicEffects.primaryButtonGradient,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(rotation))
                    .shadow(color: AppTheme.Colors.glowCyan, radius: 8, x: 0, y: 0)
                
                // Floating particles
                if showParticles {
                    ForEach(0..<6, id: \.self) { i in
                        Circle()
                            .fill(AppTheme.Colors.cosmicCyan.opacity(0.8))
                            .frame(width: 4, height: 4)
                            .offset(
                                x: cos(Double(i) * .pi / 3 + particleOffset) * 50,
                                y: sin(Double(i) * .pi / 3 + particleOffset) * 50
                            )
                            .opacity(sin(particleOffset + Double(i)) * 0.5 + 0.5)
                    }
                }
            }
            
            Text(message)
                .font(AppTheme.Typography.cosmicHeadline())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            if showParticles {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    particleOffset = 2 * .pi
                }
            }
        }
    }
}

// MARK: - Cosmic Info Card
struct CosmicInfoCard: View {
    let title: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    let action: (() -> Void)?
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color = AppTheme.Colors.cosmicCyan,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            HStack(spacing: AppTheme.Layout.spacingL) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: AppTheme.Typography.title2, weight: .semibold))
                    .foregroundColor(iconColor)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .opacity(AppTheme.Glass.opacityLight)
                            .background(
                                Circle()
                                    .fill(iconColor.opacity(0.1))
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [iconColor.opacity(0.6), iconColor.opacity(0.2)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                // Text content
                VStack(alignment: .leading, spacing: AppTheme.Layout.spacingXS) {
                    Text(title)
                        .font(AppTheme.Typography.cosmicHeadline())
                        .foregroundColor(.white)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(AppTheme.Typography.cosmicBody(AppTheme.Typography.subheadline))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
                
                Spacer()
                
                // Chevron (if actionable)
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: AppTheme.Typography.body, weight: .medium))
                        .foregroundColor(AppTheme.Colors.glassLight)
                }
            }
            .padding(AppTheme.Layout.spacingL)
        }
        .disabled(action == nil)
        .buttonStyle(ScaleButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusM)
                .fill(.ultraThinMaterial)
                .opacity(AppTheme.Glass.opacityMedium)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusM)
                        .fill(iconColor.opacity(0.05))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusM)
                .stroke(AppTheme.Glass.secondaryBorder, lineWidth: AppTheme.Layout.glassBorderWidth)
        )
        .shadow(
            color: iconColor.opacity(0.1),
            radius: AppTheme.CosmicEffects.glowSubtleRadius,
            x: 0,
            y: 4
        )
    }
} 