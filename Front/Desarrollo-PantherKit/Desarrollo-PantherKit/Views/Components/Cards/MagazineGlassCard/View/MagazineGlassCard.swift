import SwiftUI

struct MagazineGlassCard: View {
    let onContinue: () -> Void
    @State private var showFeatures = false
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        VStack(spacing: 36) {
            VStack(spacing: 24) {
                Text("Explore the Vastness\nof Your Potential")
                    .font(.custom("ZonaPro-Bold", size: 36))
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .tracking(0)
                
                Text("Science, Technology, Engineering & Mathematics")
                    .font(.custom("ZonaPro-Light", size: 16))
                    .fontWeight(.light)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .tracking(1)
            }
            
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    MagazineFeatureCard(icon: "brain.head.profile", title: "Analysis", color: AppTheme.Colors.cosmicCyan)
                    MagazineFeatureCard(icon: "chart.line.uptrend.xyaxis", title: "Prediction", color: AppTheme.Colors.cosmicPurple)
                }
                HStack(spacing: 16) {
                    MagazineFeatureCard(icon: "graduationcap.fill", title: "Careers", color: AppTheme.Colors.cosmicBlue)
                    MagazineFeatureCard(icon: "sparkles", title: "Discovery", color: AppTheme.Colors.cosmicPink)
                }
            }
            .opacity(showFeatures ? 1.0 : 0)
            .offset(y: showFeatures ? 0 : 20)
            
            MagazineCosmicButton(title: "Begin Assessment", action: onContinue)
        }
        .padding(40)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 28).fill(.ultraThinMaterial).opacity(0.7)
                RoundedRectangle(cornerRadius: 28).fill(.thinMaterial).opacity(0.3)
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        RadialGradient(colors: [
                            AppTheme.Colors.cosmicCyan.opacity(0.08),
                            AppTheme.Colors.cosmicBlue.opacity(0.04),
                            Color.clear,
                            AppTheme.Colors.cosmicPurple.opacity(0.02)
                        ], center: .topLeading, startRadius: 0, endRadius: 400)
                    )
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.08),
                            Color.clear,
                            Color.clear,
                            Color.white.opacity(0.05)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        AngularGradient(colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.05),
                            Color.clear,
                            AppTheme.Colors.cosmicCyan.opacity(0.15),
                            Color.white.opacity(0.18),
                            Color.clear,
                            Color.white.opacity(0.08)
                        ], center: .center),
                        lineWidth: 1.0
                    )
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        EllipticalGradient(colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.08),
                            Color.clear
                        ], center: UnitPoint(x: 0.3 + (shimmerOffset / UIScreen.main.bounds.width) * 0.4, y: 0.2), startRadiusFraction: 0.1, endRadiusFraction: 0.8)
                    )
                    .mask(RoundedRectangle(cornerRadius: 28))
                    .opacity(0.6)
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        EllipticalGradient(colors: [
                            AppTheme.Colors.cosmicCyan.opacity(0.15),
                            Color.white.opacity(0.05),
                            Color.clear
                        ], center: UnitPoint(x: 0.7 - (shimmerOffset / UIScreen.main.bounds.width) * 0.3, y: 0.8), startRadiusFraction: 0.05, endRadiusFraction: 0.6)
                    )
                    .mask(RoundedRectangle(cornerRadius: 28))
                    .opacity(0.4)
            }
            .shadow(color: Color.black.opacity(0.4), radius: 35, x: 0, y: 18)
            .shadow(color: Color.black.opacity(0.2), radius: 60, x: 0, y: 30)
            .shadow(color: AppTheme.Colors.cosmicBlue.opacity(0.2), radius: 45, x: 0, y: 25)
        }
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(1.0)) { showFeatures = true }
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false).delay(2.0)) {
                shimmerOffset = UIScreen.main.bounds.width + 200
            }
        }
    }
}

struct MagazineFeatureCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 56, height: 56)
                    .overlay(Circle().stroke(color.opacity(0.3), lineWidth: 1))
                    .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 6)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(color)
                    .shadow(color: color.opacity(0.6), radius: 4, x: 0, y: 0)
            }
            Text(title)
                .font(.custom("ZonaPro-Light", size: 14))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .tracking(0.5)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.06)))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.05)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 0.8
                        )
                )
        }
    }
}


