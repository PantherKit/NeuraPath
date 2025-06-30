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
            MagazineCosmicBackground()
            
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

// MARK: - Magazine Cosmic Background
struct MagazineCosmicBackground: View {
    @State private var nebulaeRotation: Double = 0
    @State private var starsShimmer = false
    
    var body: some View {
        ZStack {
            // Deep space gradient
            RadialGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color.black,
                    Color(red: 0.05, green: 0.02, blue: 0.15)
                ],
                center: .center,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height
            )
            
            // Sophisticated nebulae layers
            ZStack {
                // Primary nebula
                EllipticalGradient(
                    colors: [
                        AppTheme.Colors.cosmicBlue.opacity(0.08),
                        AppTheme.Colors.cosmicCyan.opacity(0.04),
                        Color.clear
                    ],
                    center: .topTrailing,
                    startRadiusFraction: 0.1,
                    endRadiusFraction: 0.8
                )
                .blur(radius: 30)
                .rotationEffect(.degrees(nebulaeRotation))
                
                // Secondary nebula
                EllipticalGradient(
                    colors: [
                        AppTheme.Colors.cosmicPurple.opacity(0.06),
                        AppTheme.Colors.cosmicPink.opacity(0.03),
                        Color.clear
                    ],
                    center: .bottomLeading,
                    startRadiusFraction: 0.2,
                    endRadiusFraction: 0.9
                )
                .blur(radius: 40)
                .rotationEffect(.degrees(-nebulaeRotation * 0.7))
            }
            
            // Refined star field
            ForEach(0..<25, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.4...0.9)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 20...UIScreen.main.bounds.width - 20),
                        y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 100)
                    )
                    .scaleEffect(starsShimmer ? Double.random(in: 0.8...1.4) : 1.0)
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...3)),
                        value: starsShimmer
                    )
            }
        }
        .onAppear {
            starsShimmer = true
            
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                nebulaeRotation = 360
            }
        }
    }
}

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

// MARK: - Sparkle Particle
struct SparkleParticle: View {
    let index: Int
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: CGFloat.random(in: 8...16), weight: .light))
            .foregroundColor(
                [AppTheme.Colors.cosmicCyan, AppTheme.Colors.cosmicBlue, AppTheme.Colors.cosmicPink].randomElement() ?? AppTheme.Colors.cosmicCyan
            )
            .opacity(opacity)
            .scaleEffect(scale)
            .position(
                x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                y: CGFloat.random(in: 200...UIScreen.main.bounds.height - 300)
            )
            .offset(x: offsetX, y: offsetY)
            .onAppear {
                let duration = Double.random(in: 3...6)
                let delay = Double.random(in: 0...2)
                
                withAnimation(.easeInOut(duration: 1.0).delay(delay)) {
                    opacity = Double.random(in: 0.4...0.8)
                    scale = 1.0
                }
                
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true).delay(delay)) {
                    offsetY = CGFloat.random(in: -30...30)
                    offsetX = CGFloat.random(in: -20...20)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                    withAnimation(.easeOut(duration: 1.0)) {
                        opacity = 0
                        scale = 0
                    }
                }
            }
    }
}

// MARK: - Dynamic Constellation
struct DynamicConstellation: View {
    @State private var connectionOpacity: Double = 0
    @State private var constellationRotation: Double = 0
    @State private var activeConnections: Set<Int> = []
    
    // Constellation star positions (relative to view)
    private let starPositions: [(CGFloat, CGFloat)] = [
        (0.2, 0.3), (0.4, 0.2), (0.6, 0.35), (0.8, 0.25),
        (0.3, 0.5), (0.7, 0.6), (0.5, 0.45),
        (0.25, 0.7), (0.6, 0.8), (0.75, 0.75)
    ]
    
    // Connection pairs that form meaningful paths
    private let connectionPairs: [(Int, Int)] = [
        (0, 1), (1, 2), (2, 3), // Top path
        (0, 4), (4, 6), (6, 5), // Left to center to right
        (2, 6), (6, 8), // Center connections
        (4, 7), (7, 8), (8, 9), (9, 5) // Lower path
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Connection lines
                ForEach(connectionPairs.indices, id: \.self) { index in
                    let pair = connectionPairs[index]
                    let startPos = starPositions[pair.0]
                    let endPos = starPositions[pair.1]
                    
                    Path { path in
                        path.move(to: CGPoint(
                            x: startPos.0 * geometry.size.width,
                            y: startPos.1 * geometry.size.height
                        ))
                        path.addLine(to: CGPoint(
                            x: endPos.0 * geometry.size.width,
                            y: endPos.1 * geometry.size.height
                        ))
                    }
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.cosmicCyan.opacity(0.4),
                                AppTheme.Colors.cosmicBlue.opacity(0.2),
                                AppTheme.Colors.cosmicCyan.opacity(0.4)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.2
                    )
                    .opacity(activeConnections.contains(index) ? connectionOpacity : 0.1)
                    .animation(
                        .easeInOut(duration: 2.0)
                        .delay(Double(index) * 0.3),
                        value: activeConnections
                    )
                }
                
                // Constellation stars
                ForEach(starPositions.indices, id: \.self) { index in
                    let position = starPositions[index]
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    AppTheme.Colors.cosmicCyan.opacity(0.6),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 4
                            )
                        )
                        .frame(width: 6, height: 6)
                        .position(
                            x: position.0 * geometry.size.width,
                            y: position.1 * geometry.size.height
                        )
                        .scaleEffect(connectionOpacity > 0.5 ? 1.2 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .delay(Double(index) * 0.1),
                            value: connectionOpacity
                        )
                }
            }
        }
        .frame(height: 250)
        .rotationEffect(.degrees(constellationRotation))
        .onAppear {
            startConstellationAnimation()
        }
    }
    
    private func startConstellationAnimation() {
        // Initial connection reveal
        withAnimation(.easeOut(duration: 2.0).delay(0.5)) {
            connectionOpacity = 0.8
        }
        
        // Gradual connection activation
        for i in 0..<connectionPairs.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4 + 1.0) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    _ = activeConnections.insert(i)
                }
            }
        }
        
        // Subtle rotation
        withAnimation(.linear(duration: 120).repeatForever(autoreverses: false).delay(3.0)) {
            constellationRotation = 360
        }
        
        // Dynamic connection cycling
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            cycleDynamicConnections()
        }
    }
    
    private func cycleDynamicConnections() {
        withAnimation(.easeInOut(duration: 1.5)) {
            // Fade some connections
            let connectionsToFade = Array(activeConnections.prefix(3))
            for connection in connectionsToFade {
                activeConnections.remove(connection)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 1.5)) {
                // Reactivate different connections
                let newConnections = connectionPairs.indices.shuffled().prefix(5)
                for connection in newConnections {
                    _ = activeConnections.insert(connection)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    WelcomeView(viewModel: VocationalTestViewModel(), onContinue: {})
        .preferredColorScheme(.dark)
}
