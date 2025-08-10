import SwiftUI

struct AvatarGlassCard: View {
    let avatar: Avatar
    let isSelected: Bool
    let onSelect: () -> Void
    
    @State private var cardGlow = false
    @State private var iconPulse = false
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? 
                            LinearGradient(colors: [
                                AppTheme.Colors.cosmicCyan.opacity(0.8),
                                AppTheme.Colors.cosmicBlue.opacity(0.6),
                                AppTheme.Colors.cosmicPurple.opacity(0.4),
                                AppTheme.Colors.cosmicCyan.opacity(0.8)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: isSelected ? 2.5 : 1.0
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(cardGlow ? 1.1 : 1.0)
                        .opacity(cardGlow ? 0.9 : 0.6)
                    Circle()
                        .fill(
                            isSelected ?
                            RadialGradient(colors: [
                                AppTheme.Colors.cosmicCyan.opacity(0.3),
                                AppTheme.Colors.cosmicBlue.opacity(0.1),
                                Color.clear
                            ], center: .center, startRadius: 0, endRadius: 35) :
                            RadialGradient(colors: [Color.white.opacity(0.1), Color.clear], center: .center, startRadius: 0, endRadius: 35)
                        )
                        .frame(width: 70, height: 70)
                    Image(systemName: avatar.imageName)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(isSelected ? AppTheme.Colors.cosmicCyan : Color.white.opacity(0.9))
                        .symbolRenderingMode(.hierarchical)
                        .scaleEffect(iconPulse ? 1.1 : 1.0)
                        .shadow(color: isSelected ? AppTheme.Colors.cosmicCyan.opacity(0.6) : Color.clear, radius: 8, x: 0, y: 0)
                }
                Text(avatar.name)
                    .font(.custom("ZonaPro-SemiBold", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? AppTheme.Colors.cosmicCyan : Color.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .tracking(0.3)
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial).opacity(0.7)
                    RoundedRectangle(cornerRadius: 20).fill(.thinMaterial).opacity(0.3)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            RadialGradient(colors: [
                                isSelected ? AppTheme.Colors.cosmicCyan.opacity(0.08) : Color.white.opacity(0.03),
                                Color.clear
                            ], center: .topLeading, startRadius: 0, endRadius: 200)
                        )
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.06),
                                Color.clear,
                                Color.clear,
                                Color.white.opacity(0.04)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(colors: [
                                isSelected ? AppTheme.Colors.cosmicCyan.opacity(0.4) : Color.white.opacity(0.2),
                                isSelected ? AppTheme.Colors.cosmicBlue.opacity(0.2) : Color.white.opacity(0.05)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: isSelected ? 1.5 : 0.8
                        )
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            EllipticalGradient(colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.08),
                                Color.clear
                            ], center: UnitPoint(x: 0.3 + (shimmerOffset / UIScreen.main.bounds.width) * 0.4, y: 0.2), startRadiusFraction: 0.1, endRadiusFraction: 0.8)
                        )
                        .mask(RoundedRectangle(cornerRadius: 20))
                        .opacity(0.4)
                }
                .shadow(color: isSelected ? AppTheme.Colors.cosmicCyan.opacity(0.3) : Color.black.opacity(0.2), radius: isSelected ? 20 : 15, x: 0, y: 8)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
        .onAppear {
            if isSelected {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { cardGlow = true }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) { iconPulse = true }
            }
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false).delay(1.0)) {
                shimmerOffset = UIScreen.main.bounds.width + 200
            }
        }
        .onChange(of: isSelected) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { cardGlow = true }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) { iconPulse = true }
            } else {
                cardGlow = false; iconPulse = false
            }
        }
    }
}


