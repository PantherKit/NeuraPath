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
    @State private var selectedIndices: [Int] = []
    @State private var completionPulse = false
    @State private var completionBadgeRotation = false
    // Estados para envío de respuestas
    @State private var isSendingResponses: Bool = false
    @State private var sendingProgress: CGFloat = 0.0
    @State private var hasResponseError: Bool = false
    @State private var responseErrorMessage: String = ""
    @State private var retryCount: Int = 0
    
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
                CompletionView()
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
    
    // MARK: - Vista de completado
    @ViewBuilder
    private func CompletionView() -> some View {
        ZStack {
            AnimatedStarField(numberOfStars: 200, starSpeed: 0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer(minLength: 0)
                
                Text("¡Misión Cumplida!")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .blue.opacity(0.6), radius: 8)
                
                Text("Hemos recopilado información valiosa para conocer tus habilidades y perfil.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                missionBadge
                
                HStack(spacing: 16) {
                    insightPill(title: "Habilidades", value: "12 señales clave")
                    insightPill(title: "Perfil", value: "3 rutas ideales")
                }
                
                Button(action: {
                    // Mostrar la vista de análisis antes de continuar
                    withAnimation {
                        isSendingResponses = true
                    }
                }) {
                    Text("Continuar")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(32)
                        .shadow(color: .blue.opacity(0.6), radius: 12, x: 0, y: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.top, 8)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .transition(.opacity)
            
            // Vista de análisis de respuestas
            if isSendingResponses {
                AnalyzeResponsesView {
                    // Cuando el análisis se completa, llamar al onContinue
                    onContinue()
                }
                .transition(.opacity)
            }
        }
    }
    
    private var missionBadge: some View {
        let orbitOffsets: [CGSize] = [
            CGSize(width: -100, height: -80),
            CGSize(width: 110, height: -40),
            CGSize(width: 80, height: 90)
        ]
        
        return ZStack {
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.95), Color.blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.purple.opacity(0.5), radius: 20, x: 0, y: 15)
            
            ForEach(Array(orbitOffsets.enumerated()), id: \.offset) { index, offset in
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: CGFloat(40 + (index * 15)), height: CGFloat(40 + (index * 15)))
                    .blur(radius: 12)
                    .offset(offset)
            }
            
            VStack(spacing: 8) {
                Text("Perfil STEM Analizado")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .textCase(.uppercase)
                    .kerning(1.2)
                
                Text("113 datos procesados")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Listo para desbloquear tus próximos pasos.")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 190)
    }
    
    private func insightPill(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
                .kerning(1)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.08))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
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
    
    private func selectOption(_ option: Int) {
        // Seleccionar la opción
        selectedOption = option
        
        // Guardar la selección actual en el índice correspondiente
        if currentQuestion < questions.count {
            // Si esta es una nueva pregunta, agregar a la lista
            if selectedIndices.count <= currentQuestion {
                selectedIndices.append(option)
            } 
            // Si ya existe una respuesta para esta pregunta, actualizarla
            else if currentQuestion < selectedIndices.count {
                selectedIndices[currentQuestion] = option
            }
        }
        
        // Mostrar retroalimentación
        withAnimation {
            showFeedback = true
        }
        
        // Después de un breve momento, ocultar la retroalimentación y pasar a la siguiente pregunta
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                showFeedback = false
            }
            
            // Pasar a la siguiente pregunta o finalizar
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if currentQuestion < questions.count - 1 {
                    withAnimation {
                        currentQuestion += 1
                        selectedOption = nil
                        resetTimer()
                    }
                } else {
                    // Terminar la fase de preguntas e iniciar la animación del cohete
                    withAnimation {
                        showStars = true
                        withAnimation(.easeInOut(duration: 2.0)) {
                            pathProgress = 0.3
                        }
                        
                        // Iniciar movimiento del cohete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            startRocketMovement()
                        }
                    }
                }
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
        
        // Preparar el resultado del test si aún no existe
        prepareTestResult()
        
        // Después de llegar al destino, enviar datos al servidor y mostrar pantalla de finalización
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.5) {
            // Guardar respuestas en ResponseService
            ResponseService.shared.saveQuickDecisionResponses(viewModel: viewModel)
            
            // Mostrar pantalla de finalización
            withAnimation(.easeInOut(duration: 0.5)) {
                gameCompleted = true
            }
            
            // Enviar respuestas al servidor (esto se implementará en el método onContinue)
        }
        
        // Mostrar un toast motivacional al finalizar con alta probabilidad
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if Double.random(in: 0...1) < 0.7 {
                toastManager.showRandomToast()
            }
        }
    }
    
    // MARK: - Quick Decision Logic (Frontend Only)
    private func prepareTestResult() {
        // For frontend-only version, we just record the selections
        // All processing will be done by the backend
        print("Quick decision selections recorded: \(selectedIndices)")
        
        // Store selections in ViewModel for backend submission
        // This can be added to the payload when submitting to backend
    }
    
    private func resetTimer() {
        timer?.invalidate()
        startTimer()
    }
    
    private func startRocketMovement() {
        // Iniciar animación completa del cohete hacia el destino final
        finalRocketAnimation()
        
        // Mostrar partículas del cohete
        withAnimation {
            showRocketParticles = true
        }
        
        // Feedback háptico
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}

#Preview {
    QuickDecisionView(
        viewModel: VocationalTestViewModel(), 
        onContinue: {}
    )
}
