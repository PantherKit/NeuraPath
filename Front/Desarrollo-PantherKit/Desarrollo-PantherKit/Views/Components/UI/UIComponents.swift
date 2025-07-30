import SwiftUI

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

// MARK: - MBTI Swipe Instructions
struct MBTISwipeInstructions: View {
    var body: some View {
        HStack(spacing: 60) {
            VStack(spacing: 8) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 24, weight: .medium))
                Text("Opción B")
                    .font(.custom("ZonaPro-Light", size: 14))
                    .fontWeight(.medium)
            }
            .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 24, weight: .medium))
                Text("Opción A")
                    .font(.custom("ZonaPro-Light", size: 14))
                    .fontWeight(.medium)
            }
            .foregroundColor(.green)
        }
        .padding(.bottom, 40)
    }
}

// MARK: - Swipe Indicators
struct SwipeIndicators: View {
    let dragOffset: CGSize
    let swipeThreshold: CGFloat
    
    var body: some View {
        Group {
            // Right swipe indicator
            VStack {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Opción A")
                    .font(.custom("ZonaPro-Bold", size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
            }
            .opacity(dragOffset.width > 0 ? Double(min(dragOffset.width / swipeThreshold, 1)) : 0)
            .position(x: UIScreen.main.bounds.width * 0.75, y: 100)
            
            // Left swipe indicator
            VStack {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Opción B")
                    .font(.custom("ZonaPro-Bold", size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
            }
            .opacity(dragOffset.width < 0 ? Double(min(-dragOffset.width / swipeThreshold, 1)) : 0)
            .position(x: UIScreen.main.bounds.width * 0.25, y: 100)
        }
    }
}

// MARK: - Rocket Game Components
struct RocketGameComponents {
    
    // MARK: - Rocket Path
    static func rocketPath() -> Path {
        Path { path in
            let width = UIScreen.main.bounds.width
            path.move(to: CGPoint(x: width/2, y: 280))
            
            // Trayectoria mejorada para 8 preguntas + destino final
            for i in 1...8 {
                let xOffset: CGFloat = i % 2 == 0 ? 50 : -50
                let yStep: CGFloat = 240 / 9  // Ajustado para incluir el destino final
                path.addLine(to: CGPoint(x: width/2 + xOffset, y: 280 - CGFloat(i) * yStep))
            }
            
            // Punto final (destino final)
            path.addLine(to: CGPoint(x: width/2, y: 0))
        }
    }
    
    // MARK: - Rocket Trail View
    static func rocketTrailView(accentColor: Color) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<10) { i in
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0.7), accentColor.opacity(0.5), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 20 - CGFloat(i), height: 20 - CGFloat(i))
                    .offset(y: CGFloat(i) * 5)
                    .opacity(1.0 - Double(i) * 0.1)
                    .blur(radius: 0.5)
            }
        }
    }
    
    // MARK: - Rocket Boost View
    static func rocketBoostView() -> some View {
        VStack(spacing: 0) {
            ForEach(0..<7) { i in
                let size = 20 - CGFloat(i) * 2
                let opacity = 1.0 - Double(i) * 0.15
                
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.yellow, .orange, .red]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: size, height: size)
                    .offset(y: CGFloat(i) * 5 + 10)
                    .opacity(opacity)
                    .blur(radius: 1)
            }
        }
    }
    
    // MARK: - Final Destination View
    static func finalDestinationView(isAnimating: Bool) -> some View {
        ZStack {
            // Aura de luz de destino
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.7),
                            Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            
            // Planeta dorado representando el destino (carrera y sueños)
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.9, blue: 0.5),
                            Color(red: 0.9, green: 0.7, blue: 0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 70, height: 70)
                .overlay(
                    // Detalles del planeta
                    ZStack {
                        // Edificios/Estructuras representando carreras
                        Image(systemName: "building.columns")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                            .offset(x: -10, y: 5)
                        
                        // Símbolo de estrella representando sueños
                        Image(systemName: "star.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .offset(x: 15, y: -10)
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                    }
                )
            
            // Texto "Tu Futuro"
            Text("Tu Futuro")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
                .offset(y: 50)
        }
    }
    
    // MARK: - Planet View
    static func planetView(index: Int, planetColors: [Color], planetGlowIntensity: [Double], currentQuestion: Int) -> some View {
        ZStack {
            // Aura del planeta
            Circle()
                .fill(planetColors[index].opacity(0.3))
                .frame(width: 50, height: 50)
                .blur(radius: 10)
                .opacity(planetGlowIntensity[index])
            
            // Planeta
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            planetColors[index],
                            planetColors[index].opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: planetColors[index].opacity(0.5), radius: 5, x: 0, y: 0)
                .overlay(
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                )
        }
        .scaleEffect(currentQuestion == index ? 1.1 : 1.0)
    }
}

// MARK: - Space Background
struct SpaceBackground: View {

    let showNebulas: Bool
    let accentColor: Color
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            WelcomeCosmicBackground()
            
            // Nébulas - versión mejorada
            if showNebulas {
                ForEach(0..<5, id: \.self) { i in
                    let colors: [Color] = [
                        Color(red: 0.5, green: 0.2, blue: 0.8),
                        Color(red: 0.1, green: 0.4, blue: 0.9),
                        Color(red: 0.3, green: 0.8, blue: 0.9)
                    ]
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    colors[i % colors.count].opacity(0.2),
                                    colors[i % colors.count].opacity(0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 300, height: 300)
                        .position(
                            x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0..<UIScreen.main.bounds.height)
                        )
                        .blur(radius: 60)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        MBTISwipeInstructions()
        
        SwipeIndicators(
            dragOffset: CGSize(width: 50, height: 0),
            swipeThreshold: 100
        )
        
        SpaceBackground(
            showNebulas: true,
            accentColor: AppTheme.Colors.cosmicCyan
        )
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
} 