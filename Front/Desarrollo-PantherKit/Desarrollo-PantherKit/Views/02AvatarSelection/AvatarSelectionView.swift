import SwiftUI
import Foundation

struct AvatarSelectionView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    let onContinue: () -> Void
    
    // Enhanced animation states
    @State private var showContent = false
    @State private var showHeader = false
    @State private var showAvatars = false
    @State private var showButton = false
    @State private var sparkleAnimation = false
    @State private var showConstellation = false
    @State private var selectedAvatarGlow = false
    
    var body: some View {
        ZStack {
            // Magazine-style cosmic background
            MagazineCosmicBackground()
            
            // Dynamic Constellation in upper area
            if showConstellation {
                DynamicConstellation()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 80)
            }
            
            // Main content with magazine layout
            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height * 0.25) // Responsive spacing
                    
                    // Editorial header section
                    AvatarSelectionHeader()
                        .opacity(showHeader ? 1.0 : 0)
                        .offset(y: showHeader ? 0 : -40)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Magazine-style avatar grid
                    AvatarSelectionGrid(
                        viewModel: viewModel,
                        selectedAvatarGlow: $selectedAvatarGlow
                    )
                    .opacity(showAvatars ? 1.0 : 0)
                    .offset(y: showAvatars ? 0 : 50)
                    
                    Spacer()
                        .frame(height: 60)
                    
                    // Premium CTA button
                    MagazineCosmicButton(
                        title: "Continue Journey",
                        action: onContinue
                    )
                    .disabled(viewModel.selectedAvatar == nil)
                    .opacity(viewModel.selectedAvatar == nil ? 0.6 : 1.0)
                    .opacity(showButton ? 1.0 : 0)
                    .offset(y: showButton ? 0 : 30)
                    
                    Spacer()
                        .frame(height: 80)
                }
            }
            .scrollIndicators(.hidden)
            
            // Floating sparkles
            if sparkleAnimation {
                ForEach(0..<12, id: \.self) { i in
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
        // Elegant entrance sequence
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
            showContent = true
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6)) {
            showHeader = true
        }
        
        withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(1.0)) {
            showAvatars = true
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.5)) {
            showButton = true
        }
        
        // Sparkles appear after main content
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            sparkleAnimation = true
        }
        
        // Constellation appears elegantly
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 1.5)) {
                showConstellation = true
            }
        }
    }
}

// MARK: - Avatar Selection Header
struct AvatarSelectionHeader: View {
    @State private var titleGlow = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Main title with editorial typography
            VStack(spacing: 16) {
                Text("Choose Your\nCosmic Identity")
                    .font(.custom("ZonaPro-Bold", size: 42))
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .tracking(0.5)
                    .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.3), radius: 15, x: 0, y: 5)
                
                // Elegant subtitle
                Text("Select the personality that resonates\nwith your inner explorer")
                    .font(.custom("ZonaPro-Light", size: 18))
                    .fontWeight(.light)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .tracking(0.5)
            }
            
            // Magazine-style metrics
            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("12")
                        .font(.custom("ZonaPro-Bold", size: 28))
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .tracking(-1)
                    
                    Text("Personalities")
                        .font(.custom("ZonaPro-Light", size: 14))
                        .fontWeight(.regular)
                        .foregroundColor(.white.opacity(0.65))
                        .tracking(0.5)
                }
                
                // Divider
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 8) {
                    Text("100%")
                        .font(.custom("ZonaPro-Bold", size: 28))
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .tracking(-1)
                    
                    Text("Match Rate")
                        .font(.custom("ZonaPro-Light", size: 14))
                        .fontWeight(.regular)
                        .foregroundColor(.white.opacity(0.65))
                        .tracking(0.5)
                }
            }
        }
        .padding(32)
        .background {
            // Authentic glass morphism
            ZStack {
                // Base glass layer
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.6)
                
                // Secondary glass layer for depth
                RoundedRectangle(cornerRadius: 24)
                    .fill(.thinMaterial)
                    .opacity(0.3)
                
                // Glass tint with cosmic colors
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.Colors.cosmicCyan.opacity(0.06),
                                AppTheme.Colors.cosmicBlue.opacity(0.03),
                                Color.clear,
                                AppTheme.Colors.cosmicPurple.opacity(0.02)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 300
                        )
                    )
                
                // Natural light reflection
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.06),
                                Color.clear,
                                Color.clear,
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Sophisticated border
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
            .shadow(color: Color.black.opacity(0.3), radius: 25, x: 0, y: 12)
            .shadow(color: AppTheme.Colors.cosmicBlue.opacity(0.15), radius: 35, x: 0, y: 18)
        }
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(1.0)) {
                titleGlow = true
            }
        }
    }
}

// MARK: - Avatar Selection Grid
struct AvatarSelectionGrid: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @Binding var selectedAvatarGlow: Bool
    
    private let columns = [
        GridItem(.adaptive(minimum: 140, maximum: 160), spacing: 20)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 24) {
            ForEach(Avatar.allAvatars) { avatar in
                AvatarGlassCard(
                    avatar: avatar,
                    isSelected: viewModel.selectedAvatar?.id == avatar.id,
                    onSelect: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.selectedAvatar = avatar
                        }
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                )
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Avatar Glass Card
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
                // Avatar icon with sophisticated effects
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(
                            isSelected ? 
                            LinearGradient(
                                colors: [
                                    AppTheme.Colors.cosmicCyan.opacity(0.8),
                                    AppTheme.Colors.cosmicBlue.opacity(0.6),
                                    AppTheme.Colors.cosmicPurple.opacity(0.4),
                                    AppTheme.Colors.cosmicCyan.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 2.5 : 1.0
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(cardGlow ? 1.1 : 1.0)
                        .opacity(cardGlow ? 0.9 : 0.6)
                    
                    // Inner background
                    Circle()
                        .fill(
                            isSelected ?
                            RadialGradient(
                                colors: [
                                    AppTheme.Colors.cosmicCyan.opacity(0.3),
                                    AppTheme.Colors.cosmicBlue.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 35
                            ) :
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 35
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    // Avatar icon
                    Image(systemName: avatar.imageName)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(
                            isSelected ? 
                            AppTheme.Colors.cosmicCyan : 
                            Color.white.opacity(0.9)
                        )
                        .symbolRenderingMode(.hierarchical)
                        .scaleEffect(iconPulse ? 1.1 : 1.0)
                        .shadow(
                            color: isSelected ? 
                            AppTheme.Colors.cosmicCyan.opacity(0.6) : 
                            Color.clear,
                            radius: 8, x: 0, y: 0
                        )
                }
                
                // Avatar name
                Text(avatar.name)
                    .font(.custom("ZonaPro-SemiBold", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(
                        isSelected ? 
                        AppTheme.Colors.cosmicCyan : 
                        Color.white.opacity(0.9)
                    )
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .tracking(0.3)
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .background {
                // Authentic glass morphism
                ZStack {
                    // Base glass layer
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .opacity(0.7)
                    
                    // Secondary glass layer
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.thinMaterial)
                        .opacity(0.3)
                    
                    // Glass tint
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            RadialGradient(
                                colors: [
                                    isSelected ? 
                                    AppTheme.Colors.cosmicCyan.opacity(0.08) : 
                                    Color.white.opacity(0.03),
                                    Color.clear
                                ],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                    
                    // Natural light reflection
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.06),
                                    Color.clear,
                                    Color.clear,
                                    Color.white.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    isSelected ? 
                                    AppTheme.Colors.cosmicCyan.opacity(0.4) : 
                                    Color.white.opacity(0.2),
                                    isSelected ? 
                                    AppTheme.Colors.cosmicBlue.opacity(0.2) : 
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 1.5 : 0.8
                        )
                    
                    // Shimmer effect
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            EllipticalGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.08),
                                    Color.clear
                                ],
                                center: UnitPoint(
                                    x: 0.3 + (shimmerOffset / UIScreen.main.bounds.width) * 0.4,
                                    y: 0.2
                                ),
                                startRadiusFraction: 0.1,
                                endRadiusFraction: 0.8
                            )
                        )
                        .mask(RoundedRectangle(cornerRadius: 20))
                        .opacity(0.4)
                }
                .shadow(
                    color: isSelected ? 
                    AppTheme.Colors.cosmicCyan.opacity(0.3) : 
                    Color.black.opacity(0.2),
                    radius: isSelected ? 20 : 15, x: 0, y: 8
                )
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
        .onAppear {
            if isSelected {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    cardGlow = true
                }
                
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) {
                    iconPulse = true
                }
            }
            
            // Shimmer animation
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false).delay(1.0)) {
                shimmerOffset = UIScreen.main.bounds.width + 200
            }
        }
        .onChange(of: isSelected) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    cardGlow = true
                }
                
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) {
                    iconPulse = true
                }
            } else {
                cardGlow = false
                iconPulse = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AvatarSelectionView(viewModel: VocationalTestViewModel(), onContinue: {})
        .preferredColorScheme(.dark)
}
