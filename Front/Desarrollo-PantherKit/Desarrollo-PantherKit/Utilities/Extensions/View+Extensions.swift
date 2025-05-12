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
    
    // MARK: - Card Styles
    
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
    
    // MARK: - Button Styles
    
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
    
    // MARK: - Animation
    
    func withDefaultAnimation() -> some View {
        self.animation(AppTheme.Animation.defaultAnimation, value: UUID())
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
}
