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
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.top, 40)
                    .opacity(cardExpanded ? 0 : 1)
                
                Text("Fast & easy test.\nIt takes less than 5 minutes.\nFind your STEM Path")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .opacity(cardExpanded ? 0 : 1)
                
                Button("Continuar") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        cardExpanded = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onContinue()
                    }
                }
                .buttonStyle(StyledButton())
                .padding(.horizontal, 40)
                .opacity(cardExpanded ? 0 : 1)
                
                Spacer()
            }
            .background(Color.white)
            .frame(height: cardExpanded ? UIScreen.main.bounds.height : 500)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea()
            .cornerRadius(70, corners: [.topLeft, .topRight])
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
