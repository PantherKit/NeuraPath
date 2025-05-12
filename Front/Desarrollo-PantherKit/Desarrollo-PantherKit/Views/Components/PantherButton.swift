//
//  PantherButton.swift
//  Desarrollo-PantherKit
//
//  Created on 5/11/25.
//

import SwiftUI

struct PantherButton: View {
    enum ButtonStyle {
        case primary
        case secondary
        case outline
        case destructive
        case custom(backgroundColor: Color, textColor: Color)
    }
    
    enum ButtonSize {
        case small
        case medium
        case large
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: return AppTheme.Layout.spacingM
            case .medium: return AppTheme.Layout.spacingL
            case .large: return AppTheme.Layout.spacingXL
            }
        }
        
        var verticalPadding: CGFloat {
            switch self {
            case .small: return AppTheme.Layout.spacingS
            case .medium: return AppTheme.Layout.spacingM
            case .large: return AppTheme.Layout.spacingL
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return AppTheme.Typography.subheadline
            case .medium: return AppTheme.Typography.body
            case .large: return AppTheme.Typography.title3
            }
        }
    }
    
    let title: String
    let icon: String?
    let style: ButtonStyle
    let size: ButtonSize
    let isFullWidth: Bool
    let isDisabled: Bool
    let action: () -> Void
    
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
                action()
            }
        }) {
            HStack(spacing: AppTheme.Layout.spacingS) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                
                Text(title)
                    .font(.system(size: size.fontSize, weight: .semibold))
            }
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(AppTheme.Layout.cornerRadiusM)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusM)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .opacity(isDisabled ? 0.6 : 1.0)
            .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
        }
        .disabled(isDisabled)
    }
    
    // MARK: - Styling Properties
    
    private var backgroundColor: Color {
        if isDisabled {
            return Color.gray.opacity(0.3)
        }
        
        switch style {
        case .primary:
            return AppTheme.Colors.primary
        case .secondary:
            return AppTheme.Colors.secondary
        case .outline:
            return Color.clear
        case .destructive:
            return Color.red
        case .custom(let backgroundColor, _):
            return backgroundColor
        }
    }
    
    private var textColor: Color {
        if isDisabled {
            return Color.gray
        }
        
        switch style {
        case .primary, .secondary, .destructive:
            return Color.white
        case .outline:
            return AppTheme.Colors.primary
        case .custom(_, let textColor):
            return textColor
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .outline:
            return isDisabled ? Color.gray : AppTheme.Colors.primary
        default:
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .outline:
            return 1
        default:
            return 0
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return AppTheme.Colors.primary.opacity(0.3)
        case .secondary:
            return AppTheme.Colors.secondary.opacity(0.3)
        case .destructive:
            return Color.red.opacity(0.3)
        case .outline:
            return Color.clear
        case .custom(let backgroundColor, _):
            return backgroundColor.opacity(0.3)
        }
    }
}

// MARK: - Preview
struct PantherButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PantherButton(
                title: "Primary Button",
                icon: "star.fill",
                action: {}
            )
            
            PantherButton(
                title: "Secondary Button",
                style: .secondary,
                action: {}
            )
            
            PantherButton(
                title: "Outline Button",
                style: .outline,
                action: {}
            )
            
            PantherButton(
                title: "Destructive Button",
                icon: "trash",
                style: .destructive,
                action: {}
            )
            
            PantherButton(
                title: "Custom Button",
                style: .custom(backgroundColor: .purple, textColor: .white),
                action: {}
            )
            
            PantherButton(
                title: "Full Width Button",
                isFullWidth: true,
                action: {}
            )
            
            PantherButton(
                title: "Disabled Button",
                isDisabled: true,
                action: {}
            )
            
            HStack {
                PantherButton(
                    title: "Small",
                    size: .small,
                    action: {}
                )
                
                PantherButton(
                    title: "Medium",
                    size: .medium,
                    action: {}
                )
                
                PantherButton(
                    title: "Large",
                    size: .large,
                    action: {}
                )
            }
        }
        .padding()
    }
}
