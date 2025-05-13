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

/// Main theme for the application - easily modifiable for the hackathon theme
struct AppTheme {
    // MARK: - Colors
    struct Colors {
        // Primary colors
        static let primary = Color("PrimaryPink", bundle: nil)
        static let secondary = Color("SkyBlue", bundle: nil)
        static let accent = Color("SoftIndigo", bundle: nil)
        static let highlight = Color("MangoOrange")
        
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
        
        // Corner radius
        static let cornerRadiusS: CGFloat = 4
        static let cornerRadiusM: CGFloat = 8
        static let cornerRadiusL: CGFloat = 16
        static let cornerRadiusXL: CGFloat = 24
        
        // Icon sizes
        static let iconSizeS: CGFloat = 16
        static let iconSizeM: CGFloat = 24
        static let iconSizeL: CGFloat = 32
        static let iconSizeXL: CGFloat = 48
    }
    
    // MARK: - Animation
    struct Animation {
        static let defaultAnimation = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let quickAnimation = SwiftUI.Animation.easeInOut(duration: 0.15)
        static let slowAnimation = SwiftUI.Animation.easeInOut(duration: 0.6)
    }
}
