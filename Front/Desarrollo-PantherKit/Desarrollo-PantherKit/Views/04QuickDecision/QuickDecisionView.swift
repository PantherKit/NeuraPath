import SwiftUI

struct QuickDecisionView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var timeRemaining: Double = 5.0
    @State private var timer: Timer?
    @State private var currentQuestion = 0
    @State private var selectedOption: Int?
    @State private var showFeedback = false
    @State private var feedbackImage = "star.fill"
    @State private var feedbackColor = Color(red: 1.0, green: 0.84, blue: 0.25)
    @State private var isAnimating = false
    @State private var rocketPosition: CGFloat = 0.0
    @State private var showRocketBoost = false
    @State private var rocketRotation: Double = 0.0
    @State private var gameCompleted = false
    @State private var rocketHoverOffset: CGFloat = 0.0
    @State private var rocketTrailOpacity: Double = 0.0
    @State private var showNebulas = false
    @State private var showStars = false
    
    let onContinue: () -> Void
    
    // Colores definidos directamente
    private let accentColor = Color(red: 0.25, green: 0.72, blue: 0.85)
    private let secondaryColor = Color(red: 0.2, green: 0.6, blue: 1.0)
    private let warningColor = Color(red: 1.0, green: 0.4, blue: 0.4)
    
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
    
    var body: some View {
        ZStack {
            // Fondo espacial con estrellas y nébulas
            spaceBackground
            
            // Contenido principal
            VStack(spacing: 20) {
                // Header con temporizador
                headerSection
                
                // Área del cohete y progreso
                rocketGameArea
                
                // Pregunta actual
                questionSection
                
                // Opciones de respuesta
                optionsSection
            }
            .padding()
            
            // Feedback overlay
            if showFeedback {
                feedbackOverlay
            }
            
            // Pantalla de finalización
            if gameCompleted {
                completionOverlay
            }
        }
        .onAppear {
            startAnimations()
            startTimer()
            
            // Asegurarse de que el avatar esté seleccionado
            if viewModel.selectedAvatar == nil {
                viewModel.selectedAvatar = Avatar.allAvatars.first
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Componentes de la UI
    
    private var spaceBackground: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Estrellas
            if showStars {
                StarField()
            }
            
            // Nébulas - versión corregida
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
                        // Eliminamos la animación de opacity y transition aquí
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text("Decisión Rápida")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            // Temporizador circular
            ZStack {
                Circle()
                    .stroke(lineWidth: 4)
                    .opacity(0.3)
                    .foregroundColor(accentColor)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(timeRemaining / 5.0))
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .foregroundColor(timeRemaining > 2 ? accentColor : warningColor)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: timeRemaining)
                
                Text("\(Int(timeRemaining))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(timeRemaining > 2 ? accentColor : warningColor)
            }
            .frame(width: 40, height: 40)
        }
        .padding(.horizontal)
    }
    
    private var rocketGameArea: some View {
        ZStack(alignment: .bottom) {
            // Trayectoria del cohete
            Path { path in
                let width = UIScreen.main.bounds.width
                path.move(to: CGPoint(x: width/2, y: 250))
                
                // Línea zigzag
                for i in 1...5 {
                    let xOffset: CGFloat = i % 2 == 0 ? 50 : -50
                    path.addLine(to: CGPoint(x: width/2 + xOffset, y: 250 - CGFloat(i) * 50))
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
            .foregroundColor(.white.opacity(0.3))
            
            // Estela del cohete
            if rocketTrailOpacity > 0 {
                rocketTrailView
                    .offset(y: -rocketPosition + 40)
                    .opacity(rocketTrailOpacity)
            }
            
            // Cohete
            rocketView
            
            // Planetas/objetivos
            ForEach(0..<5) { index in
                if index <= currentQuestion {
                    planetView(index: index)
                        .offset(
                            x: index % 2 == 0 ? -80 : 80,
                            y: -CGFloat(index + 1) * 50
                        )
                }
            }
        }
        .frame(height: 250)
        .padding(.vertical)
    }
    
    private var rocketTrailView: some View {
        VStack(spacing: 0) {
            ForEach(0..<8) { i in
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0.7), accentColor.opacity(0.5), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 20 - CGFloat(i), height: 20 - CGFloat(i))
                    .offset(y: CGFloat(i) * 5)
                    .opacity(1.0 - Double(i) * 0.1)
            }
        }
    }
    
    private var rocketView: some View {
        Text("🚀")
            .font(.system(size: 60))
            .rotationEffect(.degrees(rocketRotation))
            .offset(y: -rocketPosition + rocketHoverOffset)
            .shadow(color: accentColor.opacity(0.5), radius: 10, x: 0, y: 0)
            .overlay(
                Group {
                    if showRocketBoost {
                        rocketBoostView
                            .offset(y: 30)
                    }
                }
            )
    }
    
    private var rocketBoostView: some View {
        VStack(spacing: 0) {
            ForEach(0..<5) { i in
                let size = 20 - CGFloat(i) * 2
                let opacity = 1.0 - Double(i) * 0.2
                
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
    
    private func planetView(index: Int) -> some View {
        Circle()
            .fill(index == currentQuestion ? accentColor : Color.gray.opacity(0.5))
            .frame(width: 30, height: 30)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .overlay(
                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            )
    }
    
    private var questionSection: some View {
        VStack(spacing: 10) {
            Text("Pregunta \(currentQuestion + 1)/5")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            
            Text(questions[currentQuestion])
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .scaleEffect(isAnimating ? 1.02 : 1.0)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
    }
    
    private var optionsSection: some View {
        VStack(spacing: 15) {
            ForEach(0..<2) { index in
                optionButton(index: index)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func optionButton(index: Int) -> some View {
        Button(action: {
            selectOption(index)
        }) {
            HStack(spacing: 12) {
                Image(systemName: optionIcons[currentQuestion][index])
                    .font(.system(size: 24))
                    .foregroundColor(selectedOption == index ? .white : accentColor)
                
                Text(options[currentQuestion][index])
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(selectedOption == index ? .white : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(height: 60)
            .background(optionBackground(isSelected: selectedOption == index))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(selectedOption == index ? Color.white : accentColor, lineWidth: 2)
            )
            .shadow(color: selectedOption == index ? accentColor.opacity(0.5) : .clear, radius: 10, x: 0, y: 5)
        }
        .disabled(showFeedback || gameCompleted)
        .scaleEffect(selectedOption == index ? 1.03 : 1.0)
        .animation(.spring(), value: selectedOption)
    }
    
    private func optionBackground(isSelected: Bool) -> some View {
        Group {
            if isSelected {
                LinearGradient(
                    gradient: Gradient(colors: [accentColor, secondaryColor]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            } else {
                Color.white.opacity(0.1)
            }
        }
    }
    
    private var feedbackOverlay: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .overlay(
                Image(systemName: feedbackImage)
                    .font(.system(size: 80))
                    .foregroundColor(feedbackColor)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
            )
    }
    
    private var completionOverlay: some View {
        Color.black.opacity(0.8)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 30) {
                    Text("¡Misión Completada!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: accentColor, radius: 10, x: 0, y: 0)
                    
                    Text("🚀")
                        .font(.system(size: 100))
                        .rotationEffect(.degrees(rocketRotation))
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    continueButton
                }
                .padding()
            )
    }
    
    private var continueButton: some View {
        Button(action: {
            // Asegurarse de que el resultado del test esté disponible antes de continuar
            if viewModel.testResult == nil {
                // Crear un avatar por defecto si no hay uno seleccionado
                let defaultAvatar = viewModel.selectedAvatar ?? Avatar.allAvatars.first!
                
                // Inicializar puntuaciones vacías para campos
                var fieldScores: [EngineeringField: Double] = [:]
                for field in EngineeringField.allCases {
                    fieldScores[field] = 0.0
                }
                
                // Asignar puntuaciones basadas en las respuestas
                for i in 0..<questions.count {
                    if let option = selectedOption {
                        // Asignar puntuaciones según la opción seleccionada
                        if option == 0 {
                            fieldScores[.mechanical, default: 0.0] += 0.2
                            fieldScores[.industrial, default: 0.0] += 0.1
                        } else {
                            fieldScores[.computerScience, default: 0.0] += 0.2
                            fieldScores[.electrical, default: 0.0] += 0.1
                        }
                    }
                }
                
                // Inicializar puntuaciones vacías para rasgos
                var traitScores: [PersonalityTrait: Double] = [:]
                for trait in PersonalityTrait.allCases {
                    traitScores[trait] = 0.0
                }
                
                // Asignar puntuaciones de rasgos según la opción seleccionada
                if let option = selectedOption {
                    if option == 0 {
                        traitScores[.practical, default: 0.0] += 0.2
                        traitScores[.detailOriented, default: 0.0] += 0.1
                    } else {
                        traitScores[.analytical, default: 0.0] += 0.2
                        traitScores[.creative, default: 0.0] += 0.1
                    }
                }
                
                // Crear el resultado del test
                viewModel.testResult = TestResult(
                    avatar: defaultAvatar,
                    fieldScores: fieldScores,
                    traitScores: traitScores
                )
            }
            
            onContinue()
        }) {
            HStack(spacing: 12) {
                Text("Continuar")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.black)
            .padding()
            .frame(width: 200)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [accentColor, secondaryColor]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: accentColor.opacity(0.5), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Funciones
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            showStars = true
            showNebulas = true
            isAnimating = true
        }
        
        // Animación de flotación del cohete
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            rocketHoverOffset = 10
        }
    }
    
    private func startTimer() {
        timeRemaining = 5.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else if selectedOption == nil {
                selectOption(Int.random(in: 0...1))
            }
        }
    }
    
    private func selectOption(_ index: Int) {
        selectedOption = index
        timer?.invalidate()
        showFeedback = true
        
        // Configurar feedback visual
        feedbackImage = index == 0 ? "star.fill" : "bolt.fill"
        feedbackColor = index == 0 ? Color(red: 1.0, green: 0.84, blue: 0.25) : accentColor
        
        // Actualizar el viewModel con la opción seleccionada
        let fieldToUpdate: EngineeringField = index == 0 ? .mechanical : .computerScience
        viewModel.updateFieldScore(fieldToUpdate, by: 0.2)
        
        let secondaryField: EngineeringField = index == 0 ? .industrial : .electrical
        viewModel.updateFieldScore(secondaryField, by: 0.1)
        
        let traitToUpdate: PersonalityTrait = index == 0 ? .practical : .analytical
        viewModel.updateTraitScore(traitToUpdate, by: 0.2)
        
        let secondaryTrait: PersonalityTrait = index == 0 ? .detailOriented : .creative
        viewModel.updateTraitScore(secondaryTrait, by: 0.1)
        
        // Animación del cohete
        animateRocketMovement()
        
        // Mover a la siguiente pregunta o completar
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showFeedback = false
            
            if currentQuestion < questions.count - 1 {
                currentQuestion += 1
                selectedOption = nil
                startTimer()
            } else {
                withAnimation(.easeInOut(duration: 0.5)) {
                    gameCompleted = true
                }
            }
        }
    }
    
    private func animateRocketMovement() {
        let newPosition = rocketPosition + 50
        
        // Efecto de impulso
        withAnimation(.easeInOut(duration: 0.3)) {
            showRocketBoost = true
            rocketTrailOpacity = 0.8
            rocketRotation = currentQuestion % 2 == 0 ? 15 : -15
        }
        
        // Movimiento del cohete
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            rocketPosition = newPosition
        }
        
        // Finalizar efectos
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showRocketBoost = false
                rocketTrailOpacity = 0.0
                rocketRotation = 0
            }
        }
        
        // Feedback háptico
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
