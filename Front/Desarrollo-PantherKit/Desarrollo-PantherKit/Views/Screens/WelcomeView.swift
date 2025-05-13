import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var showAvatarSelection = false
    
    // Control de animaciones
    @State private var orbit = false
    @State private var planetPosition: CGFloat = 0
    @State private var cardOffset: CGFloat = UIScreen.main.bounds.height
    @State private var avatarSelectionOffset: CGFloat = UIScreen.main.bounds.height
    @State private var avatarSelectionHeight: CGFloat = UIScreen.main.bounds.height / 2
    
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
                
                Text("Fast & easy test.\nIt takes less than 5 minutes.\nFind your STEM Path")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                
                Button("Continuar") {
                    avatarSelectionOffset = UIScreen.main.bounds.height
                    showAvatarSelection = true
                }
                .buttonStyle(StyledButton())
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .background(Color.white)
            .frame(height: 500)
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
        .overlay(
            ZStack {
                // Semi-transparent background when avatar selection is shown
                Color.black
                    .opacity(showAvatarSelection ? 0.5 : 0)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.3), value: showAvatarSelection)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showAvatarSelection = false
                            avatarSelectionOffset = UIScreen.main.bounds.height
                        }
                    }
                
                // Avatar selection view that slides up
                if showAvatarSelection {
                    NavigationStack {
                        VStack(spacing: 0) {
                            // Rocket animation at the top
                            LottieView(filename: "rocket_landing", loopMode: .loop)
                                .frame(height: 120)
                                .padding(.top, 20)
                            
                            // Avatar selection content
                            AvatarSelectionView(viewModel: viewModel)
                                .transition(.move(edge: .bottom))
                                .navigationBarHidden(true)
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.75)
                    .background(AppTheme.Colors.background)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
                    .offset(y: avatarSelectionOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                if gesture.translation.height > 0 {
                                    avatarSelectionOffset = gesture.translation.height
                                }
                            }
                            .onEnded { gesture in
                                if gesture.translation.height > 100 {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        showAvatarSelection = false
                                        avatarSelectionOffset = UIScreen.main.bounds.height
                                    }
                                } else {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        avatarSelectionOffset = 0
                                    }
                                }
                            }
                    )
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            avatarSelectionOffset = 0
                        }
                    }
                }
            }
        )
    }
}

#if DEBUG
#Preview {
    WelcomeView(viewModel: VocationalTestViewModel())
}
#endif
