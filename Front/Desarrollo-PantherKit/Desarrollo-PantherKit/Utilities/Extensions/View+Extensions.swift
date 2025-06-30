//
//  View+Extensions.swift
//  Desarrollo-PantherKit
//
//  Created on 5/11/25.
//

import SwiftUI

extension View {
    // MARK: - Text Styles
    
    func titleStyle() -> some View {
        self.font(.system(size: AppTheme.Typography.title1, weight: AppTheme.Typography.bold))
            .foregroundColor(AppTheme.Colors.text)
    }
    
    func subtitleStyle() -> some View {
        self.font(.system(size: AppTheme.Typography.title3, weight: AppTheme.Typography.semibold))
            .foregroundColor(AppTheme.Colors.text)
    }
    
    func bodyStyle() -> some View {
        self.font(.system(size: AppTheme.Typography.body))
            .foregroundColor(AppTheme.Colors.text)
    }
    
    func captionStyle() -> some View {
        self.font(.system(size: AppTheme.Typography.caption1))
            .foregroundColor(AppTheme.Colors.secondaryText)
    }
    
    // MARK: - Cosmic Text Styles
    
    func cosmicTitle(_ size: CGFloat = AppTheme.Typography.title1) -> some View {
        self.font(AppTheme.Typography.cosmicTitle(size))
            .foregroundColor(.white)
            .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    func cosmicHeadline(_ size: CGFloat = AppTheme.Typography.headline) -> some View {
        self.font(AppTheme.Typography.cosmicHeadline(size))
            .foregroundColor(.white)
    }
    
    func cosmicBody(_ size: CGFloat = AppTheme.Typography.body) -> some View {
        self.font(AppTheme.Typography.cosmicBody(size))
            .foregroundColor(.white.opacity(0.9))
    }
    
    func cosmicCaption() -> some View {
        self.font(AppTheme.Typography.cosmicBody(AppTheme.Typography.caption1))
            .foregroundColor(AppTheme.Colors.secondaryText)
    }
    
    // MARK: - Legacy Card Styles (kept for backward compatibility)
    
    func cardStyle() -> some View {
        self.padding(AppTheme.Layout.spacingM)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(AppTheme.Layout.cornerRadiusM)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    func primaryCardStyle() -> some View {
        self.padding(AppTheme.Layout.spacingM)
            .background(AppTheme.Colors.primary.opacity(0.1))
            .cornerRadius(AppTheme.Layout.cornerRadiusM)
            .shadow(color: AppTheme.Colors.primary.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Glass Card Styles
    
    func glassCard(
        level: AppTheme.GlassLevel = .secondary,
        cornerRadius: CGFloat = AppTheme.Layout.glassRadiusM,
        padding: CGFloat = AppTheme.Layout.spacingL
    ) -> some View {
        self.padding(padding)
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
    
    func primaryGlassCard() -> some View {
        self.glassCard(
            level: .primary,
            cornerRadius: AppTheme.Layout.glassRadiusL,
            padding: AppTheme.Layout.spacingXL
        )
    }
    
    func secondaryGlassCard() -> some View {
        self.glassCard(
            level: .secondary,
            cornerRadius: AppTheme.Layout.glassRadiusM,
            padding: AppTheme.Layout.spacingL
        )
    }
    
    func tertiaryGlassCard() -> some View {
        self.glassCard(
            level: .tertiary,
            cornerRadius: AppTheme.Layout.glassRadiusS,
            padding: AppTheme.Layout.spacingM
        )
    }
    
    // MARK: - Glass Background Modifiers
    
    func cosmicBackground(intensity: Double = 1.0) -> some View {
        self.background(
            CosmicBackground(intensity: intensity)
        )
    }
    
    func spaceBackground() -> some View {
        self.background(
            AppTheme.CosmicEffects.spaceGradient
                .ignoresSafeArea()
        )
    }
    
    // MARK: - Glow Effects
    
    func cosmicGlow(
        color: Color = AppTheme.Colors.cosmicCyan,
        radius: CGFloat = AppTheme.CosmicEffects.glowMediumRadius
    ) -> some View {
        self.shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
    }
    
    func intensiveGlow(
        color: Color = AppTheme.Colors.cosmicCyan
    ) -> some View {
        self.cosmicGlow(color: color, radius: AppTheme.CosmicEffects.glowIntenseRadius)
    }
    
    func subtleGlow(
        color: Color = AppTheme.Colors.cosmicCyan
    ) -> some View {
        self.cosmicGlow(color: color, radius: AppTheme.CosmicEffects.glowSubtleRadius)
    }
    
    // MARK: - Legacy Button Styles (kept for backward compatibility)
    
    func primaryButtonStyle() -> some View {
        self.padding(.horizontal, AppTheme.Layout.spacingL)
            .padding(.vertical, AppTheme.Layout.spacingM)
            .background(AppTheme.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(AppTheme.Layout.cornerRadiusM)
            .shadow(color: AppTheme.Colors.primary.opacity(0.4), radius: 5, x: 0, y: 2)
    }
    
    func secondaryButtonStyle() -> some View {
        self.padding(.horizontal, AppTheme.Layout.spacingL)
            .padding(.vertical, AppTheme.Layout.spacingM)
            .background(AppTheme.Colors.secondary)
            .foregroundColor(.white)
            .cornerRadius(AppTheme.Layout.cornerRadiusM)
    }
    
    func outlineButtonStyle() -> some View {
        self.padding(.horizontal, AppTheme.Layout.spacingL)
            .padding(.vertical, AppTheme.Layout.spacingM)
            .background(Color.clear)
            .foregroundColor(AppTheme.Colors.primary)
            .cornerRadius(AppTheme.Layout.cornerRadiusM)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusM)
                    .stroke(AppTheme.Colors.primary, lineWidth: 1)
            )
    }
    
    // MARK: - Cosmic Button Styles
    
    func cosmicPrimaryButton(
        cornerRadius: CGFloat = AppTheme.Layout.glassRadiusM
    ) -> some View {
        self.padding(.horizontal, AppTheme.Layout.spacingL)
            .padding(.vertical, AppTheme.Layout.spacingM)
            .background(AppTheme.CosmicEffects.primaryButtonGradient)
            .foregroundColor(.white)
            .cornerRadius(cornerRadius)
            .shadow(
                color: AppTheme.Colors.glowCyan,
                radius: AppTheme.CosmicEffects.glowMediumRadius,
                x: 0,
                y: 4
            )
    }
    
    func cosmicSecondaryButton(
        cornerRadius: CGFloat = AppTheme.Layout.glassRadiusM
    ) -> some View {
        self.padding(.horizontal, AppTheme.Layout.spacingL)
            .padding(.vertical, AppTheme.Layout.spacingM)
            .background(.ultraThinMaterial.opacity(AppTheme.Glass.opacityMedium))
            .foregroundColor(AppTheme.Colors.cosmicCyan)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppTheme.Glass.primaryBorder, lineWidth: AppTheme.Layout.glassBorderWidth)
            )
            .shadow(
                color: AppTheme.Colors.glowBlue.opacity(0.3),
                radius: AppTheme.CosmicEffects.glowSubtleRadius,
                x: 0,
                y: 4
            )
    }
    
    func cosmicGlassButton(
        cornerRadius: CGFloat = AppTheme.Layout.glassRadiusM
    ) -> some View {
        self.padding(.horizontal, AppTheme.Layout.spacingL)
            .padding(.vertical, AppTheme.Layout.spacingM)
            .background(.ultraThinMaterial.opacity(AppTheme.Glass.opacityLight))
            .foregroundColor(.white)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppTheme.Glass.secondaryBorder, lineWidth: AppTheme.Layout.glassBorderWidth)
            )
            .shadow(
                color: AppTheme.Colors.glowWhite.opacity(0.2),
                radius: 4,
                x: 0,
                y: 4
            )
    }
    
    // MARK: - Animation Helpers
    
    func cosmicSpring() -> some View {
        self.animation(AppTheme.Animation.cosmicSpring, value: UUID())
    }
    
    func gentleFloat() -> some View {
        self.animation(AppTheme.Animation.gentleFloat, value: UUID())
    }
    
    func glowPulse() -> some View {
        self.animation(AppTheme.Animation.glowPulse, value: UUID())
    }
    
    // MARK: - Layout Helpers
    
    func fillWidth() -> some View {
        self.frame(maxWidth: .infinity)
    }
    
    func fillHeight() -> some View {
        self.frame(maxHeight: .infinity)
    }
    
    func fillScreen() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Legacy Animation (kept for backward compatibility)
    
    func withDefaultAnimation() -> some View {
        self.animation(AppTheme.Animation.defaultAnimation, value: UUID())
    }
    
    // MARK: - Interaction Helpers
    
    func cosmicTapScale() -> some View {
        self.scaleEffect(1.0)
            .onTapGesture {
                withAnimation(AppTheme.Animation.buttonPress) {
                    // Scale animation handled by button style
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
    }
    
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
    
    // MARK: - Conditional Modifiers
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        ifTrue: (Self) -> TrueContent,
        ifFalse: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTrue(self)
        } else {
            ifFalse(self)
        }
    }
    
    // MARK: - Accessibility Helpers
    
    func cosmicAccessibility(
        label: String,
        hint: String? = nil,
        value: String? = nil
    ) -> some View {
        self.accessibilityLabel(label)
            .if(hint != nil) { view in
                view.accessibilityHint(hint!)
            }
            .if(value != nil) { view in
                view.accessibilityValue(value!)
            }
    }
}
