//
//  QuickDecisionView.swift
//  Desarrollo-PantherKit
//
//  Created on 5/12/25.
//

import SwiftUI

struct QuickDecisionView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var timeRemaining: Double = 5.0
    @State private var timer: Timer?
    @State private var currentQuestion = 0
    @State private var selectedOption: Int?
    @State private var showFeedback = false
    @State private var feedbackImage = "star.fill"
    @State private var feedbackColor = Color.yellow
    @State private var isAnimating = false
    @State private var progress: CGFloat = 0.0
    @State private var rocketPosition: CGFloat = 0.0
    @State private var rocketScale: CGFloat = 1.0
    @State private var showRocketBoost = false
    @State private var rocketRotation: Double = 0.0
    @State private var showProjectile = false
    @State private var projectilePosition: CGPoint = .zero
    @State private var projectileTarget: CGPoint = .zero
    @State private var gameCompleted = false
    @State private var rocketHoverOffset: CGFloat = 0.0
    @State private var rocketTrailOpacity: Double = 0.0
    @State private var rocketGlowOpacity: Double = 0.0
    @State private var rocketShake: CGFloat = 0.0
    let onContinue: () -> Void
    
    private let questions = [
        "¿Prefieres construir o programar?",
        "¿Trabajar solo o en equipo?",
        "¿Resolver problemas teóricos o prácticos?",
        "¿Diseñar o analizar?",
        "¿Innovar o perfeccionar?"
    ]
    
    private let options = [
        ["Construir", "Programar"],
        ["Solo", "En equipo"],
        ["Teóricos", "Prácticos"],
        ["Diseñar", "Analizar"],
        ["Innovar", "Perfeccionar"]
    ]
    
    private let optionIcons = [
        ["hammer.fill", "laptopcomputer"],
        ["person", "person.3"],
        ["brain", "wrench.and.screwdriver"],
        ["paintbrush.pointed", "chart.bar"],
        ["lightbulb", "gearshape.2"]
    ]
    
    private let traits = [
        [PersonalityTrait.practical, PersonalityTrait.analytical],
        [PersonalityTrait.detailOriented, PersonalityTrait.teamPlayer],
        [PersonalityTrait.bigPictureThinker, PersonalityTrait.problemSolver],
        [PersonalityTrait.creative, PersonalityTrait.analytical],
        [PersonalityTrait.creative, PersonalityTrait.detailOriented]
    ]
    
    private let fields = [
        [EngineeringField.mechanical, EngineeringField.computerScience],
        [EngineeringField.electrical, EngineeringField.industrial],
        [EngineeringField.computerScience, EngineeringField.mechatronics],
        [EngineeringField.biomedical, EngineeringField.industrial],
        [EngineeringField.robotics, EngineeringField.mechanical]
    ]
    
    var body: some View {
        ZStack {
            // Fondo espacial
            starfieldBackground
            
            VStack(spacing: AppTheme.Layout.spacingL) {
                // Header with progress
                HStack {
                    Text("Misión Espacial")
                        .font(.system(size: AppTheme.Typography.title1, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Timer display
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 4)
                            .opacity(0.3)
                            .foregroundColor(AppTheme.Colors.primary)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(timeRemaining / 5.0))
                            .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                            .foregroundColor(timeRemaining > 2 ? AppTheme.Colors.primary : AppTheme.Colors.warning)
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(.linear, value: timeRemaining)
                        
                        Text("\(Int(timeRemaining))")
                            .font(.system(size: AppTheme.Typography.headline, weight: .bold))
                            .foregroundColor(timeRemaining > 2 ? AppTheme.Colors.primary : AppTheme.Colors.warning)
                    }
                    .frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                
                // Rocket game area
                ZStack(alignment: .bottom) {
                    // Trayectoria del cohete (línea punteada)
                    rocketPathView
                    
                    // Estela del cohete
                    rocketTrailView
                        .offset(y: -rocketPosition + 50)
                        .opacity(rocketTrailOpacity)
                        .zIndex(1)
                    
                    // Cohete Lottie
                    LottieView(filename: "rocket_landing", loopMode: .loop)
                        .frame(width: 100, height: 100)
                        .scaleEffect(rocketScale)
                        .rotationEffect(.degrees(rocketRotation))
                        .offset(x: rocketShake, y: -rocketPosition + rocketHoverOffset)
                        .overlay(
                            showRocketBoost ? 
                                rocketBoostEffect
                                .offset(y: 50)
                                : nil
                        )
                        .overlay(
                            Circle()
                                .fill(AppTheme.Colors.primary.opacity(0.3))
                                .blur(radius: 15)
                                .frame(width: 80, height: 80)
                                .opacity(rocketGlowOpacity)
                        )
                        .zIndex(2)
                    
                    // Proyectil (cuando se dispara)
                    if showProjectile {
                        Circle()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: 15, height: 15)
                            .position(projectilePosition)
                            .zIndex(1)
                    }
                    
                    // Planetas/estaciones espaciales como objetivos
                    ForEach(0..<5) { index in
                        if index <= currentQuestion {
                            planetView(index: index)
                                .offset(x: index % 2 == 0 ? -100 : 100, y: -CGFloat(index + 1) * 80)
                        }
                    }
                }
                .frame(height: 300)
                .padding(.vertical)
                
                // Mission progress
                Text("Misión \(currentQuestion + 1) de 5")
                    .font(.system(size: AppTheme.Typography.subheadline))
                    .foregroundColor(.white)
                
                // Question
                Text(questions[currentQuestion])
                    .font(.system(size: AppTheme.Typography.title2, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimating)
                    .onAppear {
                        isAnimating = true
                    }
                
                // Options
                VStack(spacing: AppTheme.Layout.spacingM) {
                    ForEach(0..<2) { index in
                        Button(action: {
                            selectOption(index)
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusL)
                                    .fill(selectedOption == index ? AppTheme.Colors.primary : Color.black.opacity(0.6))
                                    .frame(height: 70)
                                    .shadow(radius: 5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusL)
                                            .stroke(AppTheme.Colors.primary, lineWidth: 2)
                                    )
                                
                                HStack {
                                    Image(systemName: optionIcons[currentQuestion][index])
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedOption == index ? .white : AppTheme.Colors.primary)
                                    
                                    Text(options[currentQuestion][index])
                                        .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(showFeedback || gameCompleted)
                        .scaleEffect(selectedOption == index && showFeedback ? 1.05 : 1.0)
                        .animation(.spring(), value: selectedOption)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, AppTheme.Layout.spacingL)
            .onAppear {
                startTimer()
                updateProgressBar()
                startHoverAnimation()
                
                // Iniciar con un brillo sutil
                withAnimation(.easeInOut(duration: 1.0)) {
                    rocketGlowOpacity = 0.3
                }
            }
            .onDisappear {
                timer?.invalidate()
            }
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .ignoresSafeArea(.all, edges: .bottom)
            
            // Feedback overlay
            if showFeedback {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack {
                    Image(systemName: feedbackImage)
                        .font(.system(size: 80))
                        .foregroundColor(feedbackColor)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
                }
            }
            
            // Animación de finalización
            if gameCompleted {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("¡Misión Completada!")
                        .font(.system(size: AppTheme.Typography.largeTitle, weight: .bold))
                        .foregroundColor(.white)
                    
                    LottieView(filename: "rocket_landing", loopMode: .playOnce)
                        .frame(width: 200, height: 200)
                    
                    Button(action: {
                        onContinue()
                    }) {
                        Text("Continuar")
                            .font(.system(size: AppTheme.Typography.headline, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(AppTheme.Layout.cornerRadiusL)
                    }
                }
            }
        }
        .onAppear {
            // Asegurarse de que la vista se muestra correctamente después de la transición
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Haptic feedback para indicar que la nueva vista está lista
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        }
    }
    
    // MARK: - Componentes de la UI
    
    private var starfieldBackground: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Estrellas pequeñas
            ForEach(0..<100, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.9)))
                    .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
            }
            
            // Estrellas medianas
            ForEach(0..<20, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.5...1.0)))
                    .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 2...4))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
            }
        }
    }
    
    private var rocketPathView: some View {
        Path { path in
            let width = UIScreen.main.bounds.width
            path.move(to: CGPoint(x: width/2, y: 300))
            
            // Crear una línea zigzag hacia arriba
            for i in 1...5 {
                let xOffset: CGFloat = i % 2 == 0 ? 50 : -50
                path.addLine(to: CGPoint(x: width/2 + xOffset, y: 300 - CGFloat(i) * 60))
            }
        }
        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
        .foregroundColor(.white.opacity(0.5))
    }
    
    private func planetView(index: Int) -> some View {
        ZStack {
            Circle()
                .fill(index == currentQuestion ? 
                      AppTheme.Colors.primary : 
                      Color.gray.opacity(0.7))
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            Text("\(index + 1)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private var rocketTrailView: some View {
        VStack(spacing: 0) {
            ForEach(0..<10) { i in
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0.7), .blue.opacity(0.5), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 20 - CGFloat(i), height: 20 - CGFloat(i))
                    .offset(y: CGFloat(i) * 5)
                    .opacity(1.0 - Double(i) * 0.1)
                    .blur(radius: CGFloat(i) * 0.5)
            }
        }
    }
    
    private var rocketBoostEffect: some View {
        ZStack {
            // Llamas del cohete - más dinámicas
            ForEach(0..<8) { i in
                let randomWidth = CGFloat.random(in: 10...25)
                let randomHeight = CGFloat.random(in: 20...40)
                let randomOffset = CGFloat.random(in: -12...12)
                
                let colors: [Color] = [.yellow, .orange, .red]
                let randomColors = [
                    colors[Int.random(in: 0..<colors.count)],
                    colors[Int.random(in: 0..<colors.count)]
                ]
                
                let shape = i % 3 == 0 ? AnyView(
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: randomColors),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                ) : AnyView(
                    Triangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: randomColors),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .rotationEffect(.degrees(180))
                )
                
                shape
                    .frame(width: randomWidth, height: randomHeight)
                    .offset(x: randomOffset, y: CGFloat.random(in: 0...20))
                    .opacity(Double.random(in: 0.6...1.0))
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 0.1...0.3))
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            
            // Partículas de chispas
            ForEach(0..<12) { i in
                Circle()
                    .fill(Color.white)
                    .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 2...4))
                    .offset(
                        x: CGFloat.random(in: -20...20),
                        y: CGFloat.random(in: 10...30)
                    )
                    .opacity(Double.random(in: 0.3...0.8))
                    .animation(
                        Animation.easeOut(duration: Double.random(in: 0.3...0.6))
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
        }
        .frame(width: 40, height: 40)
    }
    
    // Forma de triángulo para las llamas
    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
    
    // MARK: - Funciones
    
    private func startTimer() {
        timeRemaining = 5.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                // Time's up, auto-select if user hasn't chosen
                if selectedOption == nil {
                    selectOption(Int.random(in: 0...1))
                }
            }
        }
    }
     
    private func updateProgressBar() {
        withAnimation {
            progress = UIScreen.main.bounds.width - 32 * CGFloat(currentQuestion + 1) / 5.0
        }
    }
    
    private func selectOption(_ index: Int) {
        selectedOption = index
        timer?.invalidate()
        
        // Record the selection
        let selectedTrait = traits[currentQuestion][index]
        let selectedField = fields[currentQuestion][index]
        
        viewModel.updateTraitScore(selectedTrait, by: 0.8)
        viewModel.updateFieldScore(selectedField, by: 0.8)
        
        // Show feedback
        showFeedback = true
        
        // Set feedback style based on selection
        if index == 0 {
            feedbackImage = "star.fill"
            feedbackColor = .yellow
            animateRocketAdvance()
        } else {
            feedbackImage = "bolt.fill"
            feedbackColor = .blue
            animateRocketShoot()
        }
        
        // Move to next question or finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showFeedback = false
            
            if currentQuestion < questions.count - 1 {
                currentQuestion += 1
                selectedOption = nil
                updateProgressBar()
                startTimer()
            } else {
                // All questions answered, show completion animation
                withAnimation(.easeInOut(duration: 1.0)) {
                    gameCompleted = true
                }
            }
        }
    }
    
    private func animateRocketAdvance() {
        // Calcular la nueva posición del cohete
        let newPosition = rocketPosition + 60
        
        // Preparar el cohete para el movimiento
        withAnimation(.easeIn(duration: 0.2)) {
            // Pequeña sacudida inicial
            rocketShake = currentQuestion % 2 == 0 ? -3 : 3
        }
        
        // Activar el efecto de propulsión con un breve retraso
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeIn(duration: 0.2)) {
                showRocketBoost = true
                rocketScale = 1.1
                rocketTrailOpacity = 0.8
                rocketGlowOpacity = 0.7
                // Restablecer la sacudida
                rocketShake = 0
            }
            
            // Animar el movimiento del cohete con efecto de spring para más fluidez
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0.5)) {
                rocketPosition = newPosition
                rocketRotation = currentQuestion % 2 == 0 ? 15 : -15
            }
            
            // Desactivar el efecto de propulsión después de un tiempo
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showRocketBoost = false
                    rocketScale = 1.0
                    rocketTrailOpacity = 0.0
                }
                
                // Estabilizar el cohete con un efecto de rebote suave
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    rocketRotation = 0
                    rocketGlowOpacity = 0.3
                }
                
                // Iniciar animación de hover
                startHoverAnimation()
            }
        }
        
        // Feedback háptico
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func startHoverAnimation() {
        // Animación sutil de flotación para el cohete cuando está estacionario
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
        ) {
            rocketHoverOffset = 5
        }
    }
    
    private func animateRocketShoot() {
        // Posición inicial del proyectil (desde el cohete)
        let screenWidth = UIScreen.main.bounds.width
        let rocketX = screenWidth / 2
        let rocketY = 300 - rocketPosition
        
        projectilePosition = CGPoint(x: rocketX, y: rocketY)
        
        // Posición objetivo (planeta actual)
        let targetX = rocketX + (currentQuestion % 2 == 0 ? -100 : 100)
        let targetY = 300 - CGFloat(currentQuestion + 1) * 80
        projectileTarget = CGPoint(x: targetX, y: targetY)
        
        // Efecto de sacudida del cohete al disparar
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            rocketShake = currentQuestion % 2 == 0 ? 5 : -5
            rocketGlowOpacity = 0.8
        }
        
        // Mostrar el proyectil con un breve retraso
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showProjectile = true
            
            // Animar el disparo con una trayectoria curva
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                projectilePosition = projectileTarget
            }
            
            // Ocultar el proyectil después de llegar al objetivo
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showProjectile = false
                
                // Efecto visual en el objetivo
                withAnimation(.easeInOut(duration: 0.3)) {
                    // Aquí podríamos añadir un efecto de impacto en el planeta
                }
            }
        }
        
        // Restablecer la posición del cohete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                rocketShake = 0
                rocketGlowOpacity = 0.3
            }
        }
        
        // Feedback háptico
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }
}

struct QuickDecisionView_Previews: PreviewProvider {
    static var previews: some View {
        QuickDecisionView(viewModel: VocationalTestViewModel(), onContinue: {})
    }
}
