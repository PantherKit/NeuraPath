import SwiftUI

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
                    .onTapGesture { isFocused = true }
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


