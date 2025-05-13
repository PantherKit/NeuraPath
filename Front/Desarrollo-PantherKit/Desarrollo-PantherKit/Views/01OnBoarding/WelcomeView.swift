import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var orbit = false
    @State private var planetPosition: CGFloat = 0
    @State private var cardOffset: CGFloat = UIScreen.main.bounds.height
    let onContinue: () -> Void
    @State private var cardExpanded = false
    
    // Posiciones ajustadas
    private let planetCenterPosition: CGFloat = 0
    private let planetTopPosition: CGFloat = -UIScreen.main.bounds.height/3.5 // Sube 1/3 de la pantalla
    
    var body: some View {
        ZStack {
            // 1. Fondo estelar
            StarField()
                .ignoresSafeArea()
            
            ForEach(0..<8) { i in
                let colors: [Color] = [
                    Color(red: 0.5, green: 0.2, blue: 0.8),  // Púrpura intenso
                    Color(red: 0.1, green: 0.4, blue: 0.9),   // Azul profundo
                    Color(red: 0.3, green: 0.8, blue: 0.9),   // Cian brillante
                    Color(red: 0.8, green: 0.3, blue: 0.6),   // Rosa neón
                    Color(red: 0.9, green: 0.5, blue: 0.1)    // Naranja cósmico
                ]
                
                let size = CGFloat.random(in: 200...400)
                let opacity = Double.random(in: 0.15...0.3)
                let blurRadius = CGFloat.random(in: 50...100)
                
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                colors[i % colors.count].opacity(opacity),
                                colors[i % colors.count].opacity(0)
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
            
            // 4. Nebulosas secundarias más sutiles
            ForEach(0..<5) { i in
                let pastelColors: [Color] = [
                    Color.purple.opacity(0.2),
                    Color.blue.opacity(0.2),
                    Color.cyan.opacity(0.2),
                    Color.pink.opacity(0.2),
                    Color.indigo.opacity(0.2)
                ]
                
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                pastelColors[i % pastelColors.count],
                                pastelColors[i % pastelColors.count].opacity(0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .position(
                        x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0..<UIScreen.main.bounds.height)
                    )
                    .blur(radius: 80)
            }
            
            // 2. Planeta y cohete con movimiento
            VStack {
                Spacer()
                
                ZStack {
                    Text("🌍")
                        .font(.system(size: 140))
                        .scaleEffect(1.0)
                    
                    Text("🚀")
                        .font(.system(size: 60))
                        .offset(y: -100)
                        .rotationEffect(.degrees(orbit ? 360 : 0))
                        .animation(
                            .linear(duration: 8)
                                .repeatForever(autoreverses: false),
                            value: orbit
                        )
                }
                .offset(y: planetPosition)
                .animation(.easeInOut(duration: 0.8), value: planetPosition)
                
                Spacer()
            }
            
            // 3. Card blanca con animación independiente
            VStack(spacing: 32) {
                Text("¡Bienvenido al STEM Quiz!")
                    .font(AppTheme.Typography.zonaPro(.bold, size: AppTheme.Typography.largeTitle))
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.Colors.text)
                    .padding(.top, 40)
                    .opacity(cardExpanded ? 0 : 1)
                    .animation(.spring(response: 2, dampingFraction: 0.8), value: cardOffset)
                
                Text("Fast & easy test.\nIt takes less than 5 minutes.\nFind your STEM Path")
                    .font(AppTheme.Typography.zonaPro(.bold, size: AppTheme.Typography.headline))
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.Colors.text)
                    .padding(.horizontal)
                    .opacity(cardExpanded ? 0 : 1)
                    .animation(.spring(response: 2.4, dampingFraction: 0.8), value: cardOffset)
                
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
                .animation(AppTheme.Animation.defaultAnimation, value: cardExpanded)
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
            .animation(.spring(response: 0.7, dampingFraction: 0.6), value: cardOffset)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
        .background(Color.black)
        .onAppear {
            // Secuencia completa:
            // 1. Planeta comienza centrado (posición inicial)
            
            // 2. Espera 1 segundo
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // 3. Sube el planeta más (nueva posición ajustada)
                withAnimation(.easeInOut(duration: 0.8)) {
                    planetPosition = planetTopPosition
                }
                
                // 4. Inicia órbita
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    orbit = true
                }
                
                // 5. Espera 1 segundo adicional
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // 6. Sube la card con bonito rebote
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                        cardOffset = 0
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    WelcomeView(viewModel: VocationalTestViewModel(), onContinue: { })
}
#endif
