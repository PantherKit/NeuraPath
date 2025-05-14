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
    @State private var planetGlowIntensity: [Double] = Array(repeating: 0.0, count: 8)
    @State private var finalDestinationOpacity: Double = 0.0
    @State private var finalDestinationScale: CGFloat = 0.3
    @State private var rocketScale: CGFloat = 1.0
    @State private var showRocketParticles: Bool = false
    @State private var pathProgress: CGFloat = 0.0
    @State private var rocketPositionX: CGFloat = 0.0
    @State private var rocketTargetPoints: [CGPoint] = []
    @State private var currentPathPoint: Int = 0
    @State private var rocketMoving: Bool = false
    
    let onContinue: () -> Void
    
    // Colores definidos directamente
    private let accentColor = Color(red: 0.25, green: 0.72, blue: 0.85)
    private let secondaryColor = Color(red: 0.2, green: 0.6, blue: 1.0)
    private let warningColor = Color(red: 1.0, green: 0.4, blue: 0.4)
    private let planetColors: [Color] = [
        Color(red: 0.4, green: 0.2, blue: 0.9),  // Morado
        Color(red: 0.9, green: 0.3, blue: 0.3),  // Rojo
        Color(red: 0.2, green: 0.7, blue: 0.5),  // Verde
        Color(red: 0.9, green: 0.6, blue: 0.1),  // Naranja
        Color(red: 0.2, green: 0.4, blue: 0.9),  // Azul
        Color(red: 0.8, green: 0.3, blue: 0.8),  // Rosa
        Color(red: 0.3, green: 0.8, blue: 0.8),  // Turquesa
        Color(red: 0.9, green: 0.8, blue: 0.2),  // Amarillo
    ]
    
    // Nuevas preguntas basadas en inteligencias múltiples
    private let questions = [
        "¿Prefieres escribir una historia o resolver un acertijo?",
        "¿Te atrae más un rompecabezas lógico o una redacción creativa?",
        "¿Visualizar objetos 3D o entender teorías abstractas?",
        "¿Construir con tus manos o planear el proceso primero?",
        "¿Prefieres trabajar con música o en completo silencio?",
        "¿Resolver un problema en grupo o tú solo?",
        "¿Conoces bien tus fortalezas o prefieres descubrirlas en la práctica?",
        "¿Observar la naturaleza o analizar datos de laboratorio?"
    ]
    
    // Cada pareja de opciones corresponde a una pregunta
    private let options = [
        ["Escribir historia", "Resolver acertijo"],         // Lingüística vs otra
        ["Rompecabezas lógico", "Redacción creativa"],      // Lógico-Matemática vs otra
        ["Visualizar objetos 3D", "Entender teorías"],      // Espacial vs otra
        ["Construir con manos", "Planear proceso"],         // Corporal-Kinestésica vs otra
        ["Con música", "En silencio"],                      // Musical vs otra
        ["En grupo", "Solo"],                              // Interpersonal vs otra
        ["Conozco mis fortalezas", "Descubrir en práctica"], // Intrapersonal vs otra
        ["Observar naturaleza", "Analizar datos"]           // Naturalista vs otra
    ]
    
    // Íconos que representan cada opción
    private let optionIcons = [
        ["pencil.and.outline", "puzzle"],                // Lingüística
        ["number", "text.book.closed"],                  // Lógico-Matemática
        ["cube", "brain"],                               // Espacial
        ["hand.raised", "doc.plaintext"],                // Corporal-Kinestésica
        ["music.note", "ear.slash"],                     // Musical
        ["person.3", "person"],                          // Interpersonal
        ["person.fill.questionmark", "person.fill.checkmark"], // Intrapersonal
        ["leaf", "chart.bar"]                            // Naturalista
    ]
    
    // Inteligencias asociadas a cada opción (A, B)
    private let intelligenceTypes = [
        ["Lin", "LogMath"],      // Lingüística vs Lógica
        ["LogMath", "Lin"],      // Lógica vs Lingüística
        ["Spa", "LogMath"],      // Espacial vs Lógica
        ["BodKin", "LogMath"],   // Corporal vs Lógica
        ["Mus", "LogMath"],      // Musical vs Lógica
        ["Inter", "Intra"],      // Interpersonal vs Intrapersonal
        ["Intra", "BodKin"],     // Intrapersonal vs Corporal
        ["Nat", "LogMath"]       // Naturalista vs Lógica
    ]
    
    // Toast manager
    private let toastManager = ToastManager.shared
    
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
            
            // Iniciar animación de brillo del primer planeta
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                planetGlowIntensity[0] = 1.0
            }
            
            // Calcular puntos de trayectoria del cohete
            calculateRocketPathPoints()
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
            
            // Nébulas - versión mejorada
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
            rocketPath
                .trim(from: 0, to: pathProgress)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                .foregroundColor(.white.opacity(0.5))
                .animation(.easeInOut(duration: 0.8), value: pathProgress)
            
            // Estela del cohete
            if rocketTrailOpacity > 0 {
                rocketTrailView
                    .offset(x: rocketPositionX, y: -rocketPosition + 40)
                    .opacity(rocketTrailOpacity)
            }
            
            // Destino final (solo visible cuando se está acercando al final)
            finalDestinationView
                .opacity(finalDestinationOpacity)
                .scaleEffect(finalDestinationScale)
                .offset(y: -280)

            // Cohete
            rocketView
                .offset(x: rocketPositionX)

            // Planetas para cada pregunta
            ForEach(0..<8) { index in
                if index <= currentQuestion {
                    planetView(index: index)
                        .offset(
                            x: index % 2 == 0 ? -80 : 80,
                            y: -CGFloat(index + 1) * (220 / 8)
                        )
                        .scaleEffect(planetGlowIntensity[index] > 0.5 ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0), value: planetGlowIntensity[index])
                }
            }
            
            // Partículas espaciales para el cohete
            if showRocketParticles {
                ForEach(0..<15) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.3...0.7)))
                        .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                        .offset(
                            x: rocketPositionX + CGFloat.random(in: -20...20),
                            y: -rocketPosition + CGFloat.random(in: 30...60)
                        )
                        .animation(
                            Animation.easeOut(duration: Double.random(in: 0.5...1.5))
                                .repeatForever(autoreverses: false)
                                .delay(Double.random(in: 0...1)),
                            value: showRocketParticles
                        )
                }
            }
        }
        .frame(height: 280)
        .padding(.vertical)
    }
    
    private var rocketPath: Path {
        Path { path in
            let width = UIScreen.main.bounds.width
            path.move(to: CGPoint(x: width/2, y: 280))
            
            // Trayectoria mejorada para 8 preguntas + destino final
            for i in 1...8 {
                let xOffset: CGFloat = i % 2 == 0 ? 50 : -50
                let yStep: CGFloat = 240 / 9  // Ajustado para incluir el destino final
                path.addLine(to: CGPoint(x: width/2 + xOffset, y: 280 - CGFloat(i) * yStep))
            }
            
            // Punto final (destino final)
            path.addLine(to: CGPoint(x: width/2, y: 0))
        }
    }
    
    private var rocketTrailView: some View {
        VStack(spacing: 0) {
            ForEach(0..<10) { i in
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0.7), accentColor.opacity(0.5), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 20 - CGFloat(i), height: 20 - CGFloat(i))
                    .offset(y: CGFloat(i) * 5)
                    .opacity(1.0 - Double(i) * 0.1)
                    .blur(radius: 0.5)
            }
        }
    }
    
    private var rocketView: some View {
        Text("🚀")
            .font(.system(size: 60))
            .rotationEffect(.degrees(rocketRotation))
            .offset(y: -rocketPosition + rocketHoverOffset)
            .scaleEffect(rocketScale)
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
    
    private var finalDestinationView: some View {
        ZStack {
            // Aura de luz de destino
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.7),
                            Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            
            // Planeta dorado representando el destino (carrera y sueños)
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.9, blue: 0.5),
                            Color(red: 0.9, green: 0.7, blue: 0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 70, height: 70)
                .overlay(
                    // Detalles del planeta
                    ZStack {
                        // Edificios/Estructuras representando carreras
                        Image(systemName: "building.columns")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                            .offset(x: -10, y: 5)
                        
                        // Símbolo de estrella representando sueños
                        Image(systemName: "star.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .offset(x: 15, y: -10)
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                    }
                )
            
            // Texto "Tu Futuro"
            Text("Tu Futuro")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
                .offset(y: 50)
        }
    }
    
    private var rocketBoostView: some View {
        VStack(spacing: 0) {
            ForEach(0..<7) { i in
                let size = 20 - CGFloat(i) * 2
                let opacity = 1.0 - Double(i) * 0.15
                
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
        ZStack {
            // Aura del planeta
            Circle()
                .fill(planetColors[index].opacity(0.3))
                .frame(width: 50, height: 50)
                .blur(radius: 10)
                .opacity(planetGlowIntensity[index])
            
            // Planeta
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            planetColors[index],
                            planetColors[index].opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: planetColors[index].opacity(0.5), radius: 5, x: 0, y: 0)
                .overlay(
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                )
        }
        .scaleEffect(currentQuestion == index ? 1.1 : 1.0)
    }
    
    private var questionSection: some View {
        VStack(spacing: 10) {
            Text("Pregunta \(currentQuestion + 1)/8")
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
                    
                    VStack(spacing: 5) {
                        Text("🚀")
                            .font(.system(size: 80))
                        
                        Text("¡Has llegado a tu destino!")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Text("Descubre tu carrera ideal")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.4))
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                            .scaleEffect(isAnimating ? 1.05 : 1.0)
                            .animation(
                                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [accentColor, secondaryColor]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
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
                Text("Explorar mi futuro")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.black)
            .padding()
            .frame(width: 250)
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
            showRocketParticles = true
        }
        
        // Animación de flotación del cohete
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            rocketHoverOffset = 10
        }
        
        // Posibilidad de mostrar un toast motivacional al iniciar
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if Double.random(in: 0...1) < 0.4 {
                toastManager.showRandomToast()
            }
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
        
        // Actualizar la visualización del progreso del camino
        pathProgress = min(1.0, (CGFloat(currentQuestion) + 1) / 8.0)
        
        // Obtener los tipos de inteligencia para la opción seleccionada
        let intelligenceType = intelligenceTypes[currentQuestion][index]
        
        // Actualizar puntuaciones según el tipo de inteligencia seleccionada
        let fieldMapping: [String: EngineeringField] = [
            "Lin": .computerScience,       // Lingüística -> Computer Science
            "LogMath": .electrical,        // Lógico-Matemática -> Electrical
            "Spa": .mechanical,           // Espacial -> Mechanical
            "BodKin": .mechatronics,      // Corporal-Kinestésica -> Mechatronics
            "Mus": .biomedical,           // Musical -> Biomedical
            "Inter": .industrial,         // Interpersonal -> Industrial
            "Intra": .robotics,           // Intrapersonal -> Robotics
            "Nat": .environmental         // Naturalista -> Environmental
        ]
        
        let traitMapping: [String: PersonalityTrait] = [
            "Lin": .communicator,         // Lingüística -> Comunicador
            "LogMath": .analytical,       // Lógico-Matemática -> Analítico
            "Spa": .creative,             // Espacial -> Creativo
            "BodKin": .practical,         // Corporal-Kinestésica -> Práctico
            "Mus": .detailOriented,       // Musical -> Orientado a detalles
            "Inter": .teamPlayer,         // Interpersonal -> Trabajo en equipo
            "Intra": .bigPictureThinker,  // Intrapersonal -> Visión global
            "Nat": .problemSolver         // Naturalista -> Solucionador de problemas
        ]
        
        // Aplicar la puntuación principal basada en el tipo de inteligencia
        if let field = fieldMapping[intelligenceType] {
            viewModel.updateFieldScore(field, by: 0.2)
        }
        
        // Aplicar la puntuación del rasgo correspondiente
        if let trait = traitMapping[intelligenceType] {
            viewModel.updateTraitScore(trait, by: 0.2)
        }
        
        // Añadir pequeña puntuación secundaria a un campo complementario
        if let secondaryField = fieldMapping[intelligenceTypes[currentQuestion][1 - index]] {
            viewModel.updateFieldScore(secondaryField, by: 0.05)
        }
        
        // Añadir pequeña puntuación secundaria a un rasgo complementario
        if let secondaryTrait = traitMapping[intelligenceTypes[currentQuestion][1 - index]] {
            viewModel.updateTraitScore(secondaryTrait, by: 0.05)
        }
        
        // Animación del cohete
        animateRocketMovement()
        
        // Posibilidad de mostrar toast motivacional específico según la selección
        if Double.random(in: 0...1) < 0.3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                toastManager.showRandomToast()
            }
        }
        
        // Mover a la siguiente pregunta o completar
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showFeedback = false
            
            if currentQuestion < questions.count - 1 {
                currentQuestion += 1
                selectedOption = nil
                startTimer()
                
                // Actualizar animación de brillo de planetas
                for i in 0..<8 {
                    withAnimation {
                        planetGlowIntensity[i] = i == currentQuestion ? 1.0 : 0.0
                    }
                }
                
                // Mostrar destino final al acercarse a las últimas preguntas
                if currentQuestion >= 5 {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        finalDestinationOpacity = (Double(currentQuestion) - 5.0) / 3.0
                        finalDestinationScale = 0.3 + CGFloat(currentQuestion - 5) * 0.2
                    }
                }
                
            } else {
                // Animar el cohete al destino final
                finalRocketAnimation()
            }
        }
    }
    
    private func calculateRocketPathPoints() {
        let width = UIScreen.main.bounds.width
        rocketTargetPoints = []
        
        // Punto inicial
        rocketTargetPoints.append(CGPoint(x: 0, y: 0))
        
        // Puntos intermedios (planetas)
        for i in 1...8 {
            let xOffset: CGFloat = i % 2 == 0 ? 50 : -50
            let yPos: CGFloat = CGFloat(i) * (220 / 8)
            rocketTargetPoints.append(CGPoint(x: xOffset, y: yPos))
        }
        
        // Punto final (destino)
        rocketTargetPoints.append(CGPoint(x: 0, y: 280))
    }
    
    private func calculateRocketRotation(from: CGPoint, to: CGPoint) -> Double {
        // Calcula el ángulo en función de la dirección del movimiento
        let deltaX = to.x - from.x
        let deltaY = to.y - from.y
        
        // Ajustar rotación según dirección
        if abs(deltaX) < 0.1 {
            // Movimiento casi vertical
            return 0
        } else if deltaX > 0 {
            // Movimiento a la derecha
            return 15
        } else {
            // Movimiento a la izquierda
            return -15
        }
    }
    
    private func animateRocketMovement() {
        // Punto actual y siguiente
        let currentIndex = min(currentQuestion, rocketTargetPoints.count - 2)
        let nextIndex = currentIndex + 1
        
        // Posición vertical del cohete
        let newPosition = CGFloat(currentQuestion + 1) * (220 / 8)
        
        // Posición horizontal del cohete
        let nextXOffset = rocketTargetPoints[nextIndex].x
        
        // Calcular rotación basada en la dirección
        let newRotation = calculateRocketRotation(
            from: CGPoint(x: rocketPositionX, y: rocketPosition),
            to: CGPoint(x: nextXOffset, y: newPosition)
        )
        
        rocketMoving = true
        
        // Efecto de impulso mejorado
        withAnimation(.easeInOut(duration: 0.3)) {
            showRocketBoost = true
            rocketTrailOpacity = 0.9
            // Rotar según dirección
            rocketRotation = newRotation
        }
        
        // Movimiento del cohete con mejor animación
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            rocketPosition = newPosition
            rocketPositionX = nextXOffset
        }
        
        // Finalizar efectos
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showRocketBoost = false
                rocketTrailOpacity = 0.2
                rocketRotation = 0
                rocketMoving = false
            }
        }
        
        // Feedback háptico
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    private func finalRocketAnimation() {
        // Mostrar completamente el destino final
        withAnimation(.easeInOut(duration: 1.0)) {
            finalDestinationOpacity = 1.0
            finalDestinationScale = 1.0
            pathProgress = 1.0
        }
        
        // Animar el movimiento hacia el destino con una trayectoria suave
        let duration: Double = 2.0
        let steps = 30
        
        // Comenzar animación con intensidad
        withAnimation(.easeIn(duration: 0.5)) {
            showRocketBoost = true
            rocketTrailOpacity = 1.0
            rocketRotation = 0
        }
        
        // Animar el movimiento paso a paso
        for i in 1...steps {
            let stepDuration = duration / Double(steps)
            let stepDelay = stepDuration * Double(i - 1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDelay) {
                let progress = Double(i) / Double(steps)
                
                withAnimation(.easeInOut(duration: stepDuration)) {
                    // Mover el cohete hacia arriba con aceleración
                    rocketPosition = 280 * CGFloat(progress)
                    
                    // Ajustar posición horizontal para un movimiento suave
                    rocketPositionX = sin(progress * .pi) * 20
                    
                    // Si está a mitad de camino, enderezar el cohete
                    if progress > 0.5 {
                        rocketRotation = 0
                    }
                    
                    // Reducir tamaño gradualmente para simular alejamiento
                    if progress > 0.7 {
                        rocketScale = 1.0 - CGFloat(progress - 0.7) * 1.5
                    }
                }
            }
        }
        
        // Después de llegar al destino, mostrar pantalla de finalización
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                gameCompleted = true
            }
        }
        
        // Mostrar un toast motivacional al finalizar con alta probabilidad
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if Double.random(in: 0...1) < 0.7 {
                toastManager.showRandomToast()
            }
        }
    }
}

#Preview {
    QuickDecisionView(
        viewModel: VocationalTestViewModel(), 
        onContinue: {}
    )
}
