import SwiftUI

struct AvatarSelectionView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var animateTitle = false
    @State private var animateSubtitle = false
    @State private var animateAvatars = false
    @State private var animateButton = false
    @State private var showBackgroundElements = false
    let onContinue: () -> Void
    
    // Colores definidos directamente
    private let accentColor = Color(red: 0.25, green: 0.72, blue: 0.85) // Azul-cian brillante
    private let textColor = Color.white
    private let secondaryTextColor = Color(white: 0.8)
    
    var body: some View {
        ZStack {
            // Fondo espacial oscuro
            Color.black.ignoresSafeArea()
            
            // Elementos de fondo (nébulas y estrellas)
            backgroundElements
            
            // Contenido principal
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Selección de avatares
                avatarGridSection
                
                Spacer()
                
                // Botón de acción
                startButton
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            startAnimations()
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    // MARK: - Componentes
    
    private var backgroundElements: some View {
        ZStack {
            // Campo de estrellas
            StarField()
                .opacity(showBackgroundElements ? 1 : 0)
            
            // Nébulas coloreadas
            if showBackgroundElements {
                ForEach(0..<5) { i in
                    let colors: [Color] = [
                        Color(red: 0.5, green: 0.2, blue: 0.8),  // Púrpura
                        Color(red: 0.1, green: 0.4, blue: 0.9),   // Azul
                        Color(red: 0.3, green: 0.8, blue: 0.9)    // Cian
                    ]
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    colors[i % colors.count].opacity(0.25),
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
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Choose Your STEM Avatar")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(textColor)
                .opacity(animateTitle ? 1 : 0)
                .offset(y: animateTitle ? 0 : -30)
                .shadow(color: accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text("Your digital companion for this engineering journey")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(secondaryTextColor)
                .multilineTextAlignment(.center)
                .opacity(animateSubtitle ? 1 : 0)
                .offset(y: animateSubtitle ? 0 : -20)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 32)
        .background(
            // Efecto vidrio con transparencia
            VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                .cornerRadius(20)
                .shadow(color: Color.white.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.top, 40)
    }
    
    private var avatarGridSection: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 110, maximum: 130), spacing: 20)],
                spacing: 24
            ) {
                ForEach(Avatar.allAvatars) { avatar in
                    AvatarSelectionItemView(
                        avatar: avatar,
                        isSelected: viewModel.selectedAvatar?.id == avatar.id,
                        accentColor: accentColor,
                        textColor: textColor,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.selectedAvatar = avatar
                            }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    )
                }
            }
            .padding(.vertical, 24)
        }
        .background(
            VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                .cornerRadius(20)
        )
        .opacity(animateAvatars ? 1 : 0)
        .offset(y: animateAvatars ? 0 : 50)
    }
    
    private var startButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                onContinue()
            }
        }) {
            HStack(spacing: 12) {
                Text("Launch Journey")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.black.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(
                // Gradiente mejorado para el botón
                LinearGradient(
                    gradient: Gradient(colors: [
                        accentColor,
                        Color(red: 0.2, green: 0.6, blue: 1.0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            )
            .cornerRadius(30)
            .shadow(color: accentColor.opacity(0.5), radius: 15, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(viewModel.selectedAvatar == nil)
        .opacity(viewModel.selectedAvatar == nil ? 0.6 : 1.0)
        .opacity(animateButton ? 1 : 0)
        .offset(y: animateButton ? 0 : 30)
    }
    
    // MARK: - Animaciones
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            showBackgroundElements = true
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
            animateTitle = true
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
            animateSubtitle = true
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.8)) {
            animateAvatars = true
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.2)) {
            animateButton = true
        }
    }
}

struct AvatarSelectionItemView: View {
    let avatar: Avatar
    let isSelected: Bool
    let accentColor: Color
    let textColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Anillo de selección con efecto de luz
                    Circle()
                        .stroke(
                            isSelected ? accentColor : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 3 : 1
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: isSelected ? accentColor.opacity(0.5) : .clear, radius: 10, x: 0, y: 0)
                    
                    // Fondo del avatar
                    Circle()
                        .fill(isSelected ? accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    // Ícono del avatar
                    Image(systemName: avatar.imageName)
                        .font(.system(size: 34, weight: .medium))
                        .foregroundColor(isSelected ? accentColor : textColor.opacity(0.8))
                        .symbolRenderingMode(.hierarchical)
                }
                .padding(4)
                
                Text(avatar.name)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? accentColor : textColor.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// Vista de efecto de desenfoque para iOS
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

#Preview {
    AvatarSelectionView(viewModel: VocationalTestViewModel(), onContinue: {})
}
