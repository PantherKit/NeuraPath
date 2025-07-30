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
                    
                    // Glass overlay
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                        .opacity(0.4)
                    
                    // Border glow
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
                .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.5), radius: 20, x: 0, y: 10)
                .shadow(color: AppTheme.Colors.cosmicBlue.opacity(0.3), radius: 30, x: 0, y: 15)
            }
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                energyPulse = true
            }
        }
    }
}

// MARK: - Cosmic Option Button
struct CosmicOptionButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.cosmicCyan)
                
                Text(title)
                    .font(.custom("ZonaPro-SemiBold", size: 18))
                    .foregroundColor(isSelected ? .white : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .tracking(0.3)
            }
            .padding()
            .frame(height: 60)
            .background(optionBackground(isSelected: isSelected))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.white : AppTheme.Colors.cosmicCyan.opacity(0.6), lineWidth: 1.5)
            )
            .shadow(color: isSelected ? AppTheme.Colors.cosmicCyan.opacity(0.6) : Color.white.opacity(0.1), radius: 15, x: 0, y: 8)
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(), value: isSelected)
    }
    
    private func optionBackground(isSelected: Bool) -> some View {
        Group {
            if isSelected {
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppTheme.Colors.cosmicCyan,
                        AppTheme.Colors.cosmicBlue,
                        AppTheme.Colors.cosmicPurple
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.thinMaterial)
                            .opacity(0.3)
                    }
                    .overlay {
                        // Efecto de brillo sutil
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.05),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        MagazineCosmicButton(title: "Begin Assessment") {
            print("Button tapped")
        }
        
        CosmicOptionButton(
            icon: "brain.head.profile",
            title: "Option A",
            isSelected: true
        ) {
            print("Option A selected")
        }
        
        CosmicOptionButton(
            icon: "chart.bar.fill",
            title: "Option B",
            isSelected: false
        ) {
            print("Option B selected")
        }
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
} 