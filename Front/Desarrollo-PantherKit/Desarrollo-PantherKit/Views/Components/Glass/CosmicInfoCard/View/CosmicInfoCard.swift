import SwiftUI

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
                            .background(Circle().fill(iconColor.opacity(0.1)))
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
                .background(RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusM).fill(iconColor.opacity(0.05)))
        )
        .overlay(RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusM).stroke(AppTheme.Glass.secondaryBorder, lineWidth: AppTheme.Layout.glassBorderWidth))
        .shadow(color: iconColor.opacity(0.1), radius: AppTheme.CosmicEffects.glowSubtleRadius, x: 0, y: 4)
    }
}


