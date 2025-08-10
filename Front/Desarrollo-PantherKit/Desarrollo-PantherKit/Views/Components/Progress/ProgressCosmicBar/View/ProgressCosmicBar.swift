import SwiftUI

// MARK: - Progress Cosmic Bar
struct ProgressCosmicBar: View {
    let progress: Double
    @Binding var progressGlow: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 8)
                .overlay(
                    HStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppTheme.Colors.cosmicCyan.opacity(0.8),
                                        AppTheme.Colors.cosmicBlue.opacity(0.6)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: UIScreen.main.bounds.width * 0.6 * progress)
                            .scaleEffect(x: progress, anchor: .leading)
                            .shadow(
                                color: progressGlow ? AppTheme.Colors.cosmicCyan.opacity(0.6) : AppTheme.Colors.cosmicCyan.opacity(0.3),
                                radius: progressGlow ? 8 : 4, x: 0, y: 0
                            )
                        Spacer()
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                )
        }
    }
}


