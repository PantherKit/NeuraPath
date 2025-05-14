import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var orbit = false
    @State private var planetPosition: CGFloat = 0
    @State private var cardOffset: CGFloat = UIScreen.main.bounds.height
    let onContinue: () -> Void
    @State private var cardExpanded = false
    
    // Estados de animación
    @State private var showNebulas = false
    @State private var showPlanet = false
    @State private var showRocket = false
    
    // Posiciones
    private let planetCenterPosition: CGFloat = 0
    private let planetTopPosition: CGFloat = -UIScreen.main.bounds.height/3.5
    
    var body: some View {
        ZStack {
            // 1. Fondo estelar (aparece primero)
            StarField()
                .ignoresSafeArea()
                .opacity(showNebulas ? 1 : 0)
                .animation(.easeIn(duration: 1.5), value: showNebulas)
            
            // 2. Nebulosas (aparecen con fade-in)
            if showNebulas {
                ForEach(0..<8) { i in
                    NebulaView(index: i, intense: true)
                }
                
                ForEach(0..<5) { i in
                    NebulaView(index: i, intense: false)
                }
            }
            
            // 3. Planeta y cohete
            VStack {
                Spacer()
                
                ZStack {
                    // Planeta (aparece con escala)
                    if showPlanet {
                        Text("🌍")
                            .font(.system(size: 140))
                            .scaleEffect(showPlanet ? 1.0 : 0.5)
                            .opacity(showPlanet ? 1 : 0)
                            .animation(
                                .interpolatingSpring(stiffness: 100, damping: 10)
                                .delay(0.5),
                                value: showPlanet
                            )
                    }
                    
                    // Cohete (aparece después)
                    if showRocket {
                        Text("🚀")
                            .font(.system(size: 60))
                            .offset(y: -100)
                            .rotationEffect(.degrees(orbit ? 360 : 0))
                            .opacity(showRocket ? 1 : 0)
                            .animation(
                                .linear(duration: 8)
                                    .repeatForever(autoreverses: false),
                                value: orbit
                            )
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .offset(y: planetPosition)
                .animation(.easeInOut(duration: 0.8), value: planetPosition)
                
                Spacer()
            }
            
            // 4. Card (aparece última)
            WelcomeCard(
                cardExpanded: $cardExpanded,
                cardOffset: $cardOffset,
                onContinue: onContinue
            )
        }
        .ignoresSafeArea()
        .background(Color.black)
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Secuencia de animaciones:
        // 1. Fondo estelar aparece
        withAnimation {
            showNebulas = true
        }
        
        // 2. Planeta aparece (después de 0.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                showPlanet = true
            }
            
            // 3. Cohete aparece (después de 0.3s más)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showRocket = true
                    orbit = true
                }
                
                // 4. Planeta sube (después de 0.5s más)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        planetPosition = planetTopPosition
                    }
                    
                    // 5. Card aparece (después de 0.8s más)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                            cardOffset = 0
                        }
                    }
                }
            }
        }
    }
}

// Componente de Nebula (extraído para mejor organización)
struct NebulaView: View {
    let index: Int
    let intense: Bool
    
    private var colors: [Color] {
        intense ? [
            Color(red: 0.5, green: 0.2, blue: 0.8),
            Color(red: 0.1, green: 0.4, blue: 0.9),
            Color(red: 0.3, green: 0.8, blue: 0.9),
            Color(red: 0.8, green: 0.3, blue: 0.6),
            Color(red: 0.9, green: 0.5, blue: 0.1)
        ] : [
            Color.purple.opacity(0.2),
            Color.blue.opacity(0.2),
            Color.cyan.opacity(0.2),
            Color.pink.opacity(0.2),
            Color.indigo.opacity(0.2)
        ]
    }
    
    var body: some View {
        let size = intense ? CGFloat.random(in: 200...400) : 300
        let opacity = intense ? Double.random(in: 0.15...0.3) : 0.2
        let blurRadius = intense ? CGFloat.random(in: 50...100) : 80
        
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        colors[index % colors.count].opacity(opacity),
                        colors[index % colors.count].opacity(0)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size/2
                )
            )
            .frame(width: size, height: size)
            .position(
                x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0..<UIScreen.main.bounds.height)
            )
            .blur(radius: blurRadius)
            .opacity(0.8)
    }
}

// Componente de Card (extraído para mejor organización)
struct WelcomeCard: View {
    @Binding var cardExpanded: Bool
    @Binding var cardOffset: CGFloat
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Text("¡Bienvenido a NeuraPath!")
                .font(AppTheme.Typography.zonaPro(.bold, size: AppTheme.Typography.largeTitle * 1.4))
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.Colors.text)
                .padding(.top, 40)
                .opacity(cardExpanded ? 0 : 1)
            
            Text("El futuro necesita tu talento. Vamos a descubrirlo.")
                .font(AppTheme.Typography.zonaPro(.bold, size: AppTheme.Typography.headline * 1.2))
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.Colors.text)
                .padding(.horizontal)
                .opacity(cardExpanded ? 0 : 1)
            
            Spacer()
            
            Button("Continuar") {
                withAnimation(.easeInOut(duration: 0.5)) {
                    cardExpanded = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onContinue()
                }
            }
            .buttonStyle(StyledButton())
            .font(AppTheme.Typography.zonaPro(.bold, size: AppTheme.Typography.body))
            .padding(.vertical, AppTheme.Layout.spacingM)
            .padding(.horizontal, AppTheme.Layout.spacingXL)
            .background(AppTheme.Colors.accent)
            .cornerRadius(AppTheme.Layout.cornerRadiusM)
            .padding(.horizontal, 40)
            .opacity(cardExpanded ? 0 : 1)
            
            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.91, green: 0.95, blue: 0.98),
                    Color(red: 0.98, green: 0.94, blue: 0.93),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .frame(height: cardExpanded ? UIScreen.main.bounds.height : AppTheme.Layout.spacingXXL * 10)
        .ignoresSafeArea()
        .offset(y: cardOffset)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

#if DEBUG
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(viewModel: VocationalTestViewModel(), onContinue: {})
    }
}
#endif
