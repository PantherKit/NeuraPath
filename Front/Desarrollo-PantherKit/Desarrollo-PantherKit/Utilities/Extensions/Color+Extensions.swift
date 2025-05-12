//
//  Color+Extensions.swift
//  Desarrollo-PantherKit
//
//  Created on 5/11/25.
//

import SwiftUI

extension Color {
    // Convenience initializer for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Function to get a color that will be visible on top of this color
    func contrastingTextColor() -> Color {
        // Convert to UIColor to access components
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate luminance using the formula for relative luminance
        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        
        // Return white for dark backgrounds, black for light backgrounds
        return luminance < 0.5 ? .white : .black
    }
    
    // Function to get a slightly darker version of this color
    func darker(by percentage: CGFloat = 0.2) -> Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(
            red: max(red - percentage, 0),
            green: max(green - percentage, 0),
            blue: max(blue - percentage, 0),
            opacity: alpha
        )
    }
    
    // Function to get a slightly lighter version of this color
    func lighter(by percentage: CGFloat = 0.2) -> Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(
            red: min(red + percentage, 1),
            green: min(green + percentage, 1),
            blue: min(blue + percentage, 1),
            opacity: alpha
        )
    }
}
