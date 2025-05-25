//
//  ExplanationTransitionView.swift
//  TuAppSTEM
//
//  Vista de transición con nebulosas mejoradas
//

import SwiftUI

struct ExplanationTransitionView: View {
    let title: String
    let explanationText: String
    let iconName: String
    let duration: Double
    let onContinue: () -> Void
    
    @State private var isRotating = false
    @State private var isPulsing = false
    @State private var textOpacity = 0.0
    @State private var buttonOpacity = 0.0
    @State private var showNebulas = false
    @State private var showStars = false
    @State private var particlesScale = 0.5
    @State private var isTextAnimating = false
    
    // Colores definidos
    private let accentColor = Color(red: 0.25, green: 0.72, blue: 0.85)
    private let textColor = Color.white
    private let secondaryTextColor = Color(white: 0.8)
    
    var body: some View {
        ZStack {
            // Fondo espacial con nebulosas
            spaceBackground
            
            // Contenido principal con scroll si es necesario
            ScrollView {
                VStack(spacing: 30) {
                    // Icono animado
                    iconSection
                    
                    // Texto explicativo con frame fijo
                    textSection
                        .frame(maxWidth: .infinity, minHeight: 150) // Altura mínima garantizada
                    
                    Spacer()
                    
                    // Botón de continuar
                    continueButton
                }
                .padding(.horizontal, 30)
                .padding(.top, 50)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Componentes
    
    private var spaceBackground: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Estrellas
            if showStars {
                StarField()
            }
            
            // Nebulosas
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
            
            // Partículas flotantes
            ForEach(0..<15) { i in
                Circle()
                    .fill(accentColor.opacity(Double.random(in: 0.2...0.6)))
                    .frame(width: CGFloat.random(in: 2...5), height: CGFloat.random(in: 2...5))
                    .position(
                        x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0..<UIScreen.main.bounds.height)
                    )
                    .scaleEffect(particlesScale)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 1.5...3.0))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: particlesScale
                    )
            }
        }
    }
    
    private var iconSection: some View {
        ZStack {
            // Efecto de halo pulsante
            if isPulsing {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isPulsing ? 1.5 : 0.5)
                    .opacity(isPulsing ? 0 : 1)
                    .animation(
                        .easeOut(duration: 2.0).repeatForever(autoreverses: false),
                        value: isPulsing
                    )
            }
            
            // Icono principal con animaciones
            Image(systemName: iconName)
                .font(.system(size: 60, weight: .bold))
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(accentColor)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .scaleEffect(isPulsing ? 1.1 : 1.0)
                .shadow(color: accentColor.opacity(0.5), radius: 10, x: 0, y: 0)
        }
    }
    
    private var textSection: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
                .opacity(textOpacity)
                .shadow(color: accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
            
            Text(explanationText)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(secondaryTextColor)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .opacity(textOpacity)
                .scaleEffect(isTextAnimating ? 1.02 : 1.0)
                .padding(.horizontal, 20)
                .fixedSize(horizontal: false, vertical: true) // Asegura que el texto se ajuste verticalmente
        }
        .padding(.vertical, 24)
        .background(
            VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                .cornerRadius(20)
                .shadow(color: Color.white.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var continueButton: some View {
        Button(action: {
            withAnimation {
                onContinue()
            }
        }) {
            HStack(spacing: 10) {
                Text("Continuar")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.black)
            .padding(.vertical, 14)
            .padding(.horizontal, 30)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        accentColor,
                        Color(red: 0.2, green: 0.6, blue: 1.0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .cornerRadius(30)
                .shadow(color: accentColor.opacity(0.5), radius: 10, x: 0, y: 5)
            )
            .opacity(buttonOpacity)
        }
        .scaleEffect(isRotating ? 1.02 : 1.0) // Simular el ScaleButtonStyle
        .buttonStyle(ScaleButtonStyle())
        .padding(.bottom, 40)
    }
    
    // MARK: - Animaciones
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            showStars = true
            showNebulas = true
            particlesScale = 1.0
            textOpacity = 1.0
            isTextAnimating = true
        }
        
        // Animación de rotación continua del icono
        withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: false)) {
            isRotating = true
        }
        
        // Animación de pulso del icono
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            isPulsing = true
        }
        
        // Mostrar el botón después de la duración especificada
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.easeInOut(duration: 0.6)) {
                buttonOpacity = 1.0
            }
        }
    }
}

class ExplanationStar: Identifiable, ObservableObject {
    let id = UUID()
    let x = Float.random(in: 0...1)
    let y = Float.random(in: 0...1)
    let size = CGFloat.random(in: 1...3)
    @Published var opacity = Float.random(in: 0.1...0.5)
}


// Vista previa
struct ExplanationTransitionView_Previews: PreviewProvider {
    static var previews: some View {
        ExplanationTransitionView(
            title: "Analizando tus respuestas",
            explanationText: "Estamos procesando tus selecciones para determinar las áreas STEM que mejor se adaptan a tu perfil. Esto toma en cuenta tus intereses, habilidades y preferencias personales.",
            iconName: "brain.head.profile",
            duration: 3.0,
            onContinue: {}
        )
    }
}
