import SwiftUI

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
                
                Button(action: { withAnimation(AppTheme.Animation.quickAnimation) { isShowing = false } }) {
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
            .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: .move(edge: .top).combined(with: .opacity)))
        }
    }
}


