import SwiftUI

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
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .tracking(0.3)
            }
            .padding()
            .frame(height: 60)
            .background(optionBackground(isSelected: isSelected))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(isSelected ? Color.white : AppTheme.Colors.cosmicCyan.opacity(0.6), lineWidth: 1.5))
            .shadow(color: isSelected ? AppTheme.Colors.cosmicCyan.opacity(0.6) : Color.white.opacity(0.1), radius: 15, x: 0, y: 8)
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(), value: isSelected)
    }
    
    private func optionBackground(isSelected: Bool) -> some View {
        Group {
            if isSelected {
                LinearGradient(gradient: Gradient(colors: [AppTheme.Colors.cosmicCyan, AppTheme.Colors.cosmicBlue, AppTheme.Colors.cosmicPurple]), startPoint: .topLeading, endPoint: .bottomTrailing)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.thinMaterial).opacity(0.3))
                    .overlay(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.05), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)))
            }
        }
    }
}


