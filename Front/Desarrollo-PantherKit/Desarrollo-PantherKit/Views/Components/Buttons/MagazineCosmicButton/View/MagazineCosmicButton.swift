import SwiftUI

// MARK: - Magazine Cosmic Button
struct MagazineCosmicButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    @State private var energyPulse = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .medium))
                    .rotationEffect(.degrees(energyPulse ? 5 : 0))
                
                Text(title)
                    .font(.custom("ZonaPro-Bold", size: 18))
                    .fontWeight(.semibold)
                    .tracking(0.5)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.Colors.cosmicCyan.opacity(0.9),
                                    AppTheme.Colors.cosmicBlue.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial).opacity(0.4)
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                }
                .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.5), radius: 20, x: 0, y: 10)
                .shadow(color: AppTheme.Colors.cosmicBlue.opacity(0.3), radius: 30, x: 0, y: 15)
            }
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) { isPressed = pressing }
        }, perform: {})
        .onAppear { withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { energyPulse = true } }
    }
}


