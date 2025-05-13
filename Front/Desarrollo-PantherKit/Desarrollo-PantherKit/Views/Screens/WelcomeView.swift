import SwiftUI

struct WelcomeView: View {
    // Control de animaciones
    @State private var orbit = false
    @State private var showPlanet = false
    @State private var showCard = false
    
    var body: some View {
        ZStack {
            // Fondo estelar
            StarField()
            
            // Contenido principal
            VStack(spacing: 0) {
                // Animación del planeta y cohete
                ZStack {
                    if showPlanet {
                        Text("🌍")
                            .font(.system(size: 140))
                            .scaleEffect(showPlanet ? 1 : 0.8)
                            .animation(.easeOut(duration: 0.5), value: showPlanet)
                        
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
                }
                .frame(height: 240)
                .frame(maxWidth: .infinity)
                
                // Card blanca (aparece después)
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
                    .transition(.move(edge: .bottom))
                    .animation(.easeOut(duration: 0.8), value: showCard)
                }
            }
        }
        .background(Color.black)
        .onAppear {
            // Animación del planeta
            withAnimation(.easeOut(duration: 0.5)) {
                showPlanet = true
            }
            
            // Comienza la órbita después de un pequeño delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                orbit = true
            }
            
            // Muestra la card después de 1 segundo
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
