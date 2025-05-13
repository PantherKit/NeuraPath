import SwiftUI

struct WelcomeView: View {
    // Control de animaciones
    @State private var orbit = false
    @State private var showPlanet = false
    @State private var showCard = false
    
    var body: some View {
        ZStack {
            StarField()
            
            // Card blanca para el contenido
            VStack(spacing: 0) {
                // Espacio para la animación
                ZStack {
                    if showPlanet {
                        Text("🌍")
                            .font(.system(size: 140))
                            .scaleEffect(showPlanet ? 1 : 0.5)
                            .animation(.interactiveSpring(response: 0.8, dampingFraction: 0.6, blendDuration: 0.5).delay(0.2), value: showPlanet)
                    }
                    
                    if showPlanet {
                        Text("🚀")
                            .font(.system(size: 60))
                            .offset(y: -100)
                            .rotationEffect(.degrees(orbit ? 360 : 0))
                            .animation(
                                .linear(duration: 8)
                                    .repeatForever(autoreverses: false),
                                value: orbit
                            )
                            .scaleEffect(showPlanet ? 1 : 0)
                            .animation(.interpolatingSpring(stiffness: 100, damping: 10).delay(0.4), value: showPlanet)
                    }
                }
                .frame(height: 240)
                .frame(maxWidth: .infinity)
                
                // Contenido dentro de la card blanca
                if showCard {
                    VStack(spacing: 32) {
                        Text("¡Bienvenido al STEM Quiz!")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding(.top, 40)
                        
                        Text("Fast & easy test.\nIt takes less than 5 minutes.\nFind your STEM Path")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        Button("Continuar") {
                            // Acción: navegar al quiz
                        }
                        .buttonStyle(StyledButton())
                        .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                    .background(Color.white)
                    .frame(height: 600)
                    .cornerRadius(70, corners: [.topLeft, .topRight])
                    .offset(y: showCard ? 0 : 600) // Posición inicial fuera de pantalla
                    .animation(.easeOut(duration: 0.8), value: showCard)
                }
            }
        }
        .background(Color.black)
        .onAppear {
            // Secuencia de animaciones
            withAnimation(.spring()) {
                showPlanet = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    orbit = true
                }
            }
            
            // Espera 1 segundo después de que el cohete empiece a orbitar
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                withAnimation(.easeOut(duration: 0.8)) {
                    showCard = true
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    WelcomeView()
}
#endif
