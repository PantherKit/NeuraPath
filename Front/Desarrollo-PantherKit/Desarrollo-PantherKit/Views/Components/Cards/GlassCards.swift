import SwiftUI

// MARK: - Magazine Glass Card
struct MagazineGlassCard: View {
    let onContinue: () -> Void
    @State private var showFeatures = false
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        VStack(spacing: 36) {
            // Welcome message with magazine typography
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
            
            // Magazine-style feature grid
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    MagazineFeatureCard(
                        icon: "brain.head.profile",
                        title: "Analysis",
                        color: AppTheme.Colors.cosmicCyan
                    )
                    
                    MagazineFeatureCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Prediction",
                        color: AppTheme.Colors.cosmicPurple
                    )
                }
                
                HStack(spacing: 16) {
                    MagazineFeatureCard(
                        icon: "graduationcap.fill",
                        title: "Careers",
                        color: AppTheme.Colors.cosmicBlue
                    )
                    
                    MagazineFeatureCard(
                        icon: "sparkles",
                        title: "Discovery",
                        color: AppTheme.Colors.cosmicPink
                    )
                }
            }
            .opacity(showFeatures ? 1.0 : 0)
            .offset(y: showFeatures ? 0 : 20)
            
            // Premium CTA button
            MagazineCosmicButton(
                title: "Begin Assessment",
                action: onContinue
            )
        }
        .padding(40)
        .background {
            // Authentic glass morphism
            ZStack {
                // Base glass layer
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .opacity(0.7)
                
                // Secondary glass layer for depth
                RoundedRectangle(cornerRadius: 28)
                    .fill(.thinMaterial)
                    .opacity(0.3)
                
                // Glass tint with cosmic colors
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.Colors.cosmicCyan.opacity(0.08),
                                AppTheme.Colors.cosmicBlue.opacity(0.04),
                                Color.clear,
                                AppTheme.Colors.cosmicPurple.opacity(0.02)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 400
                        )
                    )
                
                // Natural light reflection
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.08),
                                Color.clear,
                                Color.clear,
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Sophisticated border with refractions
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.05),
                                Color.clear,
                                AppTheme.Colors.cosmicCyan.opacity(0.15),
                                Color.white.opacity(0.18),
                                Color.clear,
                                Color.white.opacity(0.08)
                            ],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        lineWidth: 1.0
                    )
                
                // Natural organic shine
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        EllipticalGradient(
                            colors: [
                                Color.white.opacity(0.25),
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
                    .mask(RoundedRectangle(cornerRadius: 28))
                    .opacity(0.6)
                
                // Secondary organic shine
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        EllipticalGradient(
                            colors: [
                                AppTheme.Colors.cosmicCyan.opacity(0.15),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            center: UnitPoint(
                                x: 0.7 - (shimmerOffset / UIScreen.main.bounds.width) * 0.3,
                                y: 0.8
                            ),
                            startRadiusFraction: 0.05,
                            endRadiusFraction: 0.6
                        )
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
            withAnimation(.easeOut(duration: 1.0).delay(1.0)) {
                showFeatures = true
            }
            
            // Shimmer animation
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false).delay(2.0)) {
                shimmerOffset = UIScreen.main.bounds.width + 200
            }
        }
    }
}

// MARK: - Magazine Feature Card
struct MagazineFeatureCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with sophisticated glow
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 6)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(color)
                    .shadow(color: color.opacity(0.6), radius: 4, x: 0, y: 0)
            }
            
            // Title
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
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )
        }
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

// MARK: - Question Glass Card
struct QuestionGlassCard: View {
    let card: STEMCard
    let isActive: Bool
    let onSwipedAway: () -> Void
    let onShowDetails: () -> Void
    
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var isGone = false
    @State private var cardGlow = false
    @State private var shimmerOffset: CGFloat = -200
    @State private var titleGlow = false
    
    private let swipeThreshold: CGFloat = 100
    private let maxRotation: Double = 15
    private let toastManager = ToastManager.shared
    
    var rotationAngle: Double {
        Double(dragOffset.width / swipeThreshold) * maxRotation
    }
    
    var body: some View {
        ZStack {
            // Authentic glass morphism card background
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .opacity(0.9)
                .background {
                    // Secondary glass layer for depth
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.thinMaterial)
                        .opacity(0.6)
                }
                .overlay {
                    // Glass tint with cosmic colors
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppTheme.Colors.cosmicCyan.opacity(0.15),
                                    AppTheme.Colors.cosmicBlue.opacity(0.08),
                                    Color.clear,
                                    AppTheme.Colors.cosmicPurple.opacity(0.05)
                                ],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 400
                            )
                        )
                    
                    // Natural light reflection
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.12),
                                    Color.clear,
                                    Color.clear,
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Sophisticated border
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.0
                        )
                    
                    // Shimmer effect
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            EllipticalGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.15),
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
                        .mask(RoundedRectangle(cornerRadius: 28))
                        .opacity(0.6)
                }
                .shadow(color: Color.black.opacity(0.3), radius: 25, x: 0, y: 12)
                .shadow(color: AppTheme.Colors.cosmicBlue.opacity(0.15), radius: 35, x: 0, y: 18)
            
            // Magazine-style editorial content
            VStack(spacing: 0) {
                // Editorial header section
                VStack(spacing: 20) {
                    // Category badge
                    HStack {
                        Text("STEM CAREER")
                            .font(.custom("ZonaPro-Bold", size: 10))
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.Colors.cosmicCyan)
                            .tracking(2)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                AppTheme.Colors.cosmicCyan.opacity(0.2),
                                                AppTheme.Colors.cosmicBlue.opacity(0.1)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(
                                                AppTheme.Colors.cosmicCyan.opacity(0.3),
                                                lineWidth: 1
                                            )
                                    )
                            }
                        
                        Spacer()
                        
                        // Issue number (simulated)
                        Text("ISSUE #\(Int.random(in: 1...99))")
                            .font(.custom("ZonaPro-Light", size: 10))
                            .fontWeight(.light)
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(1)
                    }
                    
                    // Main headline with editorial typography
                    Text(card.title)
                        .font(.custom("ZonaPro-Bold", size: 28))
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                        .tracking(0.5)
                        .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.3), radius: 10, x: 0, y: 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)
                
                // Editorial divider
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.cosmicCyan.opacity(0.4),
                                AppTheme.Colors.cosmicBlue.opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 20)
                
                // Key insights section (scientific journal style)
                VStack(spacing: 24) {
                    ForEach(card.details.prefix(3), id: \.title) { detail in
                        HStack(alignment: .top, spacing: 20) {
                            // Scientific icon with cosmic background
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                AppTheme.Colors.cosmicCyan.opacity(0.25),
                                                AppTheme.Colors.cosmicBlue.opacity(0.15),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 25
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: detail.icon)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.cosmicCyan)
                                    .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.6), radius: 6, x: 0, y: 0)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(detail.description)
                                    .font(.custom("ZonaPro-Bold", size: 18))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .tracking(0.3)
                                
                                Text(detail.title)
                                    .font(.custom("ZonaPro-Light", size: 15))
                                    .fontWeight(.light)
                                    .foregroundColor(.white.opacity(0.75))
                                    .lineSpacing(4)
                                    .tracking(0.2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 28)
                
                Spacer()
                
            }
            
            // Enhanced swipe feedback indicators
            if isDragging {
                VStack {
                    if dragOffset.width > 0 {
                        VStack(spacing: 16) {
                            // Enhanced icon with glow effect
                            ZStack {
                                // Outer glow
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 90, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.cosmicCyan.opacity(0.3))
                                    .blur(radius: 8)
                                    .scaleEffect(1.2)
                                
                                // Main icon
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 80, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.cosmicCyan)
                                    .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.8), radius: 20, x: 0, y: 0)
                            }
                            
                            // Enhanced text with glow
                            Text("Interested")
                                .font(.custom("ZonaPro-Bold", size: 22))
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.Colors.cosmicCyan)
                                .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.6), radius: 8, x: 0, y: 2)
                                .scaleEffect(1.1)
                        }
                        .opacity(Double(min(dragOffset.width / swipeThreshold, 1)))
                        .scaleEffect(0.8 + Double(min(dragOffset.width / swipeThreshold, 1)) * 0.4)
                    } else if dragOffset.width < 0 {
                        VStack(spacing: 16) {
                            // Enhanced icon with glow effect
                            ZStack {
                                // Outer glow
                                Image(systemName: "arrow.left.circle.fill")
                                    .font(.system(size: 90, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.cosmicPurple.opacity(0.3))
                                    .blur(radius: 8)
                                    .scaleEffect(1.2)
                                
                                // Main icon
                                Image(systemName: "arrow.left.circle.fill")
                                    .font(.system(size: 80, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.cosmicPurple)
                                    .shadow(color: AppTheme.Colors.cosmicPurple.opacity(0.8), radius: 20, x: 0, y: 0)
                            }
                            
                            // Enhanced text with glow
                            Text("Not for me")
                                .font(.custom("ZonaPro-Bold", size: 22))
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.Colors.cosmicPurple)
                                .shadow(color: AppTheme.Colors.cosmicPurple.opacity(0.6), radius: 8, x: 0, y: 2)
                                .scaleEffect(1.1)
                        }
                        .opacity(Double(min(-dragOffset.width / swipeThreshold, 1)))
                        .scaleEffect(0.8 + Double(min(-dragOffset.width / swipeThreshold, 1)) * 0.4)
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: dragOffset.width)
            }
        }
        .rotationEffect(.degrees(rotationAngle))
        .offset(dragOffset)
        .opacity(isGone ? 0 : 1)
        .scaleEffect(isActive ? 1.0 : 0.9)
        .offset(y: isActive ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isActive)
        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    if isActive {
                        withAnimation(.interactiveSpring()) {
                            isDragging = true
                            dragOffset = value.translation
                        }
                    }
                }
                .onEnded { value in
                    if isActive && abs(value.translation.width) > swipeThreshold {
                        let direction: CGFloat = value.translation.width > 0 ? 1 : -1
                        
                        // Enhanced animation sequence with better timing
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isDragging = false
                            dragOffset = CGSize(width: direction * 300, height: 0) // Reduced distance for better visibility
                        }
                        
                        // Show feedback for longer duration
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                dragOffset = CGSize(width: direction * 800, height: 0)
                                isGone = true
                            }
                            
                            // Chance to show a motivational toast when swiping a card
                            let showToastChance = Bool.random()
                            if showToastChance {
                                toastManager.showRandomToast()
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                onSwipedAway()
                            }
                        }
                    } else {
                        withAnimation(.spring()) {
                            dragOffset = .zero
                            isDragging = false
                        }
                    }
                }
        )
        .onAppear {
            // Start shimmer animation
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false).delay(1.0)) {
                shimmerOffset = UIScreen.main.bounds.width + 200
            }
            
            // Start title glow animation
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(1.0)) {
                titleGlow = true
            }
            
            // Pequeña probabilidad de mostrar un toast al aparecer la tarjeta
            if Bool.random() && isActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if Double.random(in: 0...1) < 0.3 {
                        toastManager.showRandomToast()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        MagazineGlassCard(onContinue: {})
        
        AvatarGlassCard(
            avatar: Avatar.allAvatars[0],
            isSelected: true,
            onSelect: {}
        )
        
        QuestionGlassCard(
            card: STEMCard.sampleData[0],
            isActive: true,
            onSwipedAway: {},
            onShowDetails: {}
        )
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
} 