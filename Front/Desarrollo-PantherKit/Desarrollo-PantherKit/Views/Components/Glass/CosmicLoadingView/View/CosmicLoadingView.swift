import SwiftUI

// MARK: - Cosmic Loading View
struct CosmicLoadingView: View {
    let message: String
    let showParticles: Bool
    
    @State private var rotation = 0.0
    @State private var particleOffset = 0.0
    
    init(
        message: String = "Cargando...",
        showParticles: Bool = true
    ) {
        self.message = message
        self.showParticles = showParticles
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Layout.spacingXL) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(AppTheme.Glass.secondaryBorder, lineWidth: 3)
                    .frame(width: 80, height: 80)
                
                // Inner spinning element
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(
                        AppTheme.CosmicEffects.primaryButtonGradient,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(rotation))
                    .shadow(color: AppTheme.Colors.glowCyan, radius: 8, x: 0, y: 0)
                
                // Floating particles
                if showParticles {
                    ForEach(0..<6, id: \.self) { i in
                        Circle()
                            .fill(AppTheme.Colors.cosmicCyan.opacity(0.8))
                            .frame(width: 4, height: 4)
                            .offset(
                                x: cos(Double(i) * .pi / 3 + particleOffset) * 50,
                                y: sin(Double(i) * .pi / 3 + particleOffset) * 50
                            )
                            .opacity(sin(particleOffset + Double(i)) * 0.5 + 0.5)
                    }
                }
            }
            
            Text(message)
                .font(AppTheme.Typography.cosmicHeadline())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) { rotation = 360 }
            if showParticles {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) { particleOffset = 2 * .pi }
            }
        }
    }
}


