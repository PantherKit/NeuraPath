//
//  CardView.swift
//  Desarrollo-PantherKit
//
//  Created on 5/11/25.
//

import SwiftUI

struct CardView<Content: View>: View {
    enum CardStyle {
        case standard
        case primary
        case custom(backgroundColor: Color, shadowColor: Color)
    }
    
    private let content: Content
    private let style: CardStyle
    private let cornerRadius: CGFloat
    private let padding: CGFloat
    private let shadowRadius: CGFloat
    private let onTap: (() -> Void)?
    
    init(
        style: CardStyle = .standard,
        cornerRadius: CGFloat = AppTheme.Layout.cornerRadiusM,
        padding: CGFloat = AppTheme.Layout.spacingM,
        shadowRadius: CGFloat = 5,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.shadowRadius = shadowRadius
        self.onTap = onTap
        self.content = content()
    }
    
    var body: some View {
        let (backgroundColor, shadowColor) = getColors()
        
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 2)
            .if(onTap != nil) { view in
                view.onTapGesture {
                    onTap?()
                }
            }
    }
    
    private func getColors() -> (backgroundColor: Color, shadowColor: Color) {
        switch style {
        case .standard:
            return (AppTheme.Colors.secondaryBackground, Color.black.opacity(0.1))
        case .primary:
            return (AppTheme.Colors.primary.opacity(0.1), AppTheme.Colors.primary.opacity(0.2))
        case .custom(let backgroundColor, let shadowColor):
            return (backgroundColor, shadowColor)
        }
    }
}

// MARK: - Preview
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CardView {
                Text("Standard Card")
                    .padding()
            }
            
            CardView(style: .primary) {
                Text("Primary Card")
                    .padding()
            }
            
            CardView(
                style: .custom(backgroundColor: .purple.opacity(0.2), shadowColor: .purple.opacity(0.3)),
                onTap: {
                    print("Custom card tapped")
                }
            ) {
                Text("Custom Card (Tappable)")
                    .padding()
            }
        }
        .padding()
    }
}
