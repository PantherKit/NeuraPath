import SwiftUI
import Foundation

struct WelcomeView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    let onContinue: () -> Void
    
    // Enhanced animation states
    @State private var showContent = false
    @State private var logoGlow = false
    @State private var numberCounter: Double = 0
    @State private var sparkleAnimation = false
    @State private var glassShimmer = false
    @State private var showConstellation = false
    
    var body: some View {
        ZStack {
            // Magazine-style cosmic background
            WelcomeCosmicBackground()
            
            // Dynamic Constellation in upper area
            if showConstellation {
                DynamicConstellation()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 100)
            }
            
            
            // Main content with magazine layout
            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height * 0.4) // Responsive - hero starts at bottom third
                    
                    // Hero section with elegant spacing
                    VStack(spacing: 32) {
                    // Refined logo with sophisticated glow
                    VStack(spacing: 40) {
                        // Logo with multiple concentric rings
                        HStack {
                            ZStack {
                                // Outer glow ring
                                Circle()
                                    .stroke(
                                        AngularGradient(
                                            colors: [
                                                AppTheme.Colors.cosmicCyan.opacity(0.8),
                                                AppTheme.Colors.cosmicBlue.opacity(0.6),
                                                AppTheme.Colors.cosmicPurple.opacity(0.4),
                                                AppTheme.Colors.cosmicCyan.opacity(0.8)
                                            ],
                                            center: .center
                                        ),
                                        lineWidth: 2
                                    )
                                    .frame(width: 120, height: 120)
                                    .scaleEffect(logoGlow ? 1.08 : 1.0)
                                    .opacity(logoGlow ? 0.9 : 0.6)
                                
                                // Inner ring
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.4),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                                    .frame(width: 85, height: 85)
                                    .scaleEffect(logoGlow ? 0.95 : 1.0)
                                
                                // Brain emoji with holographic effect
                                ZStack {
                                    // Holographic layers
                                    Text("🧠")
                                        .font(.system(size: 55))
                                        .offset(x: -1, y: -1)
                                        .foregroundColor(.red.opacity(0.3))
                                    
                                    Text("🧠")
                                        .font(.system(size: 55))
                                        .offset(x: 1, y: 1)
                                        .foregroundColor(.cyan.opacity(0.3))
                                    
                                    Text("🧠")
                                        .font(.system(size: 55))
                                        .scaleEffect(showContent ? 1.0 : 0.5)
                                }
                                .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.5), radius: 20, x: 0, y: 0)
                            }
                            
                            Spacer()
                        }
                        .padding(.leading, 36)
                        
                        // Magazine-style title
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Neura\nPath")
                                .font(.custom("ZonaPro-Bold", size: 72))
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .tracking(1)
                                .multilineTextAlignment(.leading)
                            
                            // Elegant subtitle
                            Text("Discover the Future\nof STEM Careers")
                                .font(.custom("ZonaPro-Light", size: 18))
                                .fontWeight(.light)
                                .foregroundColor(.white.opacity(0.75))
                                .multilineTextAlignment(.leading)
                                .lineSpacing(4)
                                .tracking(0.5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 36)
                    }
                    .opacity(showContent ? 1.0 : 0)
                    .offset(y: showContent ? 0 : -30)
                    
                    // Magazine-style metrics section
                    VStack(spacing: 24) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Available Paths")
                                    .font(.custom("ZonaPro-Light", size: 12))
                                    .fontWeight(.regular)
                                    .foregroundColor(.white.opacity(0.65))
                                    .tracking(0.5)
                                
                                // Animated counter
                                Text("\(Int(numberCounter))")
                                    .font(.custom("ZonaPro-Bold", size: 24))
                                    .fontWeight(.heavy)
                                    .foregroundColor(.white)
                                    .tracking(-2)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("Match Rate")
                                    .font(.custom("ZonaPro-Light", size: 14))
                                    .fontWeight(.regular)
                                    .foregroundColor(.white.opacity(0.65))
                                    .tracking(0.5)
                                
                                Text("94.7%")
                                    .font(.custom("ZonaPro-Bold", size: 32))
                                    .fontWeight(.heavy)
                                    .foregroundColor(.white)
                                    .tracking(-2)
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        // Divider line with shimmer
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 1)
                            .padding(.horizontal, 32)
                            .scaleEffect(x: glassShimmer ? 1.0 : 0.0, anchor: .leading)
                    }
                    .opacity(showContent ? 1.0 : 0)
                    .offset(y: showContent ? 0 : 30)
                                }
                
                Spacer()
                    .frame(height: 200) // More space to push glass card off-screen
                
                // Magazine-style glass card
                MagazineGlassCard(onContinue: onContinue)
                    .opacity(showContent ? 1.0 : 0)
                    .offset(y: showContent ? 0 : 50)
                
                Spacer()
                    .frame(height: 60)
                }
            }
            .scrollIndicators(.hidden)
            
            // Floating sparkles
            if sparkleAnimation {
                ForEach(0..<8, id: \.self) { i in
                    SparkleParticle(index: i)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startMagazineAnimation()
        }
    }
    
    private func startMagazineAnimation() {
        // Elegant entrance
        withAnimation(.easeOut(duration: 1.5).delay(0.4)) {
            showContent = true
        }
        
        // Logo glow pulse
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(1.0)) {
            logoGlow = true
        }
        
        // Number counter animation
        withAnimation(.easeOut(duration: 2.0).delay(1.2)) {
            numberCounter = 180
        }
        
        // Shimmer effect
        withAnimation(.linear(duration: 2.0).delay(1.5)) {
            glassShimmer = true
        }
        
        // Sparkles
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            sparkleAnimation = true
        }
        
        // Constellation appears elegantly after main content
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 1.5)) {
                showConstellation = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    WelcomeView(viewModel: VocationalTestViewModel(), onContinue: {})
        .preferredColorScheme(.dark)
}
