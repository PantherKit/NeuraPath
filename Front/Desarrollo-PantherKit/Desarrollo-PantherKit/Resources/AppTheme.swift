//
//  AppTheme.swift
//  Desarrollo-PantherKit
//
//  Created on 5/11/25.
//

import SwiftUI

enum ZonaProWeight: String {
    case bold = "ZonaPro-Bold"
    case light = "ZonaPro-Light"
    case thin = "ZonaPro-Thin"
    case blackItalic = "ZonaPro-BlackItalic"
}

/// Main theme for the application - Cosmic Glassmorphism Design System
struct AppTheme {
    // MARK: - Colors
    struct Colors {
        // Primary colors
        static let primary = Color("PrimaryPink", bundle: nil)
        static let secondary = Color("SkyBlue", bundle: nil)
        static let accent = Color("SoftIndigo", bundle: nil)
        static let highlight = Color("MangoOrange")
        
        // Cosmic Glassmorphism Palette
        static let cosmicCyan = Color(red: 0.25, green: 0.72, blue: 0.85) // #40B8D9
        static let cosmicBlue = Color(red: 0.2, green: 0.6, blue: 1.0)    // #3399FF
        static let cosmicPurple = Color(red: 0.5, green: 0.2, blue: 0.8)  // #8033CC
        static let cosmicPink = Color(red: 0.8, green: 0.3, blue: 0.6)    // #CC4D99
        static let cosmicIndigo = Color(red: 0.3, green: 0.4, blue: 0.9)  // #4D66E6
        
        // Glass Colors
        static let glassLight = Color.white.opacity(0.1)
        static let glassMedium = Color.white.opacity(0.05)
        static let glassDark = Color.white.opacity(0.02)
        
        // Glow Colors
        static let glowCyan = cosmicCyan.opacity(0.6)
        static let glowBlue = cosmicBlue.opacity(0.6)
        static let glowPurple = cosmicPurple.opacity(0.6)
        static let glowWhite = Color.white.opacity(0.3)
        
        // Space Background Colors
        static let spaceBlack = Color.black
        static let spaceNavy = Color(red: 0.05, green: 0.1, blue: 0.2)
        static let spaceMidnight = Color(red: 0.1, green: 0.1, blue: 0.3)
        
        // Background colors
        static let background = Color("BackgroundColor", bundle: nil)
        static let secondaryBackground = Color("SecondaryBackgroundColor", bundle: nil)
        
        // Text colors
        static let text = Color("TextColor", bundle: nil)
        static let secondaryText = Color("SecondaryTextColor", bundle: nil)
        
        // Status colors
        static let success = Color("SuccessColor", bundle: nil)
        static let warning = Color("WarningColor", bundle: nil)
        static let error = Color("ErrorColor", bundle: nil)
        
        // Default system colors - fallbacks
        static let defaultPrimary = Color.blue
        static let defaultSecondary = Color.purple
        static let defaultAccent = Color.orange
        static let defaultBackground = Color(UIColor.systemBackground)
        static let defaultSecondaryBackground = Color(UIColor.secondarySystemBackground)
        static let defaultText = Color(UIColor.label)
        static let defaultSecondaryText = Color(UIColor.secondaryLabel)
        static let defaultSuccess = Color.green
        static let defaultWarning = Color.yellow
        static let defaultError = Color.red
    }
    
    // MARK: - Glassmorphism System
    struct Glass {
        // Glass Materials
        static let heavy = Material.thickMaterial
        static let medium = Material.regularMaterial  
        static let light = Material.thinMaterial
        static let ultraLight = Material.ultraThinMaterial
        
        // Glass Opacity Levels
        static let opacityHeavy: Double = 0.95
        static let opacityMedium: Double = 0.8
        static let opacityLight: Double = 0.6
        static let opacityUltraLight: Double = 0.4
        
        // Border Gradients
        static let primaryBorder = LinearGradient(
            colors: [Colors.cosmicCyan.opacity(0.6), Colors.cosmicBlue.opacity(0.3), Color.clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let secondaryBorder = LinearGradient(
            colors: [Color.white.opacity(0.3), Color.white.opacity(0.1), Color.clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let glowBorder = LinearGradient(
            colors: [Colors.cosmicCyan, Colors.cosmicBlue, Colors.cosmicPurple],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        // Glass Backgrounds
        static func background(_ level: GlassLevel) -> some View {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(level.opacity)
                .background(level.tint)
        }
    }
    
    enum GlassLevel {
        case primary, secondary, tertiary, minimal
        
        var opacity: Double {
            switch self {
            case .primary: return Glass.opacityHeavy
            case .secondary: return Glass.opacityMedium  
            case .tertiary: return Glass.opacityLight
            case .minimal: return Glass.opacityUltraLight
            }
        }
        
        var tint: Color {
            switch self {
            case .primary: return Colors.cosmicCyan.opacity(0.1)
            case .secondary: return Colors.cosmicBlue.opacity(0.05)
            case .tertiary: return Colors.glassLight
            case .minimal: return Colors.glassMedium
            }
        }
        
        var borderGradient: LinearGradient {
            switch self {
            case .primary: return Glass.primaryBorder
            case .secondary: return Glass.secondaryBorder
            case .tertiary, .minimal: return Glass.secondaryBorder
            }
        }
    }
    
    // MARK: - Cosmic Effects
    struct CosmicEffects {
        // Glow intensities
        static let glowIntenseRadius: CGFloat = 20
        static let glowMediumRadius: CGFloat = 12
        static let glowSubtleRadius: CGFloat = 6
        
        // Nebula gradients
        static let nebulaPrimary = RadialGradient(
            colors: [Colors.cosmicCyan.opacity(0.3), Colors.cosmicBlue.opacity(0.1), Color.clear],
            center: .center,
            startRadius: 0,
            endRadius: 200
        )
        
        static let nebulaSecondary = RadialGradient(
            colors: [Colors.cosmicPurple.opacity(0.25), Colors.cosmicPink.opacity(0.1), Color.clear],
            center: .center,
            startRadius: 0,
            endRadius: 250
        )
        
        // Button gradients
        static let primaryButtonGradient = LinearGradient(
            colors: [Colors.cosmicCyan, Colors.cosmicBlue],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let secondaryButtonGradient = LinearGradient(
            colors: [Colors.cosmicBlue.opacity(0.8), Colors.cosmicIndigo.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        // Space backgrounds
        static let spaceGradient = LinearGradient(
            colors: [Colors.spaceBlack, Colors.spaceNavy, Colors.spaceMidnight, Colors.spaceBlack],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Typography
    struct Typography {
        // Font sizes
        static let largeTitle: CGFloat = 34
        static let title1: CGFloat = 28
        static let title2: CGFloat = 22
        static let title3: CGFloat = 20
        static let headline: CGFloat = 17
        static let body: CGFloat = 17
        static let callout: CGFloat = 16
        static let subheadline: CGFloat = 15
        static let footnote: CGFloat = 13
        static let caption1: CGFloat = 12
        static let caption2: CGFloat = 11
        
        // Font weights
        static let light = Font.Weight.light
        static let regular = Font.Weight.regular
        static let medium = Font.Weight.medium
        static let semibold = Font.Weight.semibold
        static let bold = Font.Weight.bold
        static let heavy = Font.Weight.heavy
        
        // Cosmic Typography Styles
        static func cosmicTitle(_ size: CGFloat = title1) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
        
        static func cosmicHeadline(_ size: CGFloat = headline) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }
        
        static func cosmicBody(_ size: CGFloat = body) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }
        
        static func zonaPro(_ weight: ZonaProWeight, size: CGFloat) -> Font {
            .custom(weight.rawValue, size: size)
        }
    }
    
    // MARK: - Layout
    struct Layout {
        // Spacing
        static let spacingXS: CGFloat = 4
        static let spacingS: CGFloat = 8
        static let spacingM: CGFloat = 16
        static let spacingL: CGFloat = 24
        static let spacingXL: CGFloat = 32
        static let spacingXXL: CGFloat = 48
        
        // Glass corner radius
        static let glassRadiusS: CGFloat = 12
        static let glassRadiusM: CGFloat = 20
        static let glassRadiusL: CGFloat = 25
        static let glassRadiusXL: CGFloat = 30
        
        // Traditional corner radius
        static let cornerRadiusS: CGFloat = 4
        static let cornerRadiusM: CGFloat = 8
        static let cornerRadiusL: CGFloat = 16
        static let cornerRadiusXL: CGFloat = 24
        
        // Icon sizes
        static let iconSizeS: CGFloat = 16
        static let iconSizeM: CGFloat = 24
        static let iconSizeL: CGFloat = 32
        static let iconSizeXL: CGFloat = 48
        
        // Glass border width
        static let glassBorderWidth: CGFloat = 1
        static let glassBorderWidthThick: CGFloat = 1.5
    }
    
    // MARK: - Animation
    struct Animation {
        static let defaultAnimation = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let quickAnimation = SwiftUI.Animation.easeInOut(duration: 0.15)
        static let slowAnimation = SwiftUI.Animation.easeInOut(duration: 0.6)
        
        // Cosmic Animations
        static let glowPulse = SwiftUI.Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
        static let gentleFloat = SwiftUI.Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)
        static let cosmicSpring = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.7)
        static let buttonPress = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)
    }
}
