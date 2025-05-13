import SwiftUI

struct ResultsView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var animateContent = false
    @State private var showingFieldDetail: EngineeringField?
    @State private var showStars = false
    @State private var showNebulas = false
    @State private var rocketOffset: CGFloat = 0
    @State private var rocketRotation: Double = 0
    let onContinue: () -> Void
    
    // Colores consistentes con QuickDecisionView
    private let accentColor = Color(red: 0.25, green: 0.72, blue: 0.85)
    private let secondaryColor = Color(red: 0.2, green: 0.6, blue: 1.0)
    private let successColor = Color(red: 0.2, green: 0.8, blue: 0.4)
    
    var body: some View {
        ZStack {
            // Fondo espacial mejorado
            spaceBackground
            
            // Efecto de partículas
            ParticleEffectView()
                .opacity(0.3)
            
            if let result = viewModel.testResult {
                resultContent(result)
            } else {
                noResultsView
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(item: $showingFieldDetail) { field in
            fieldDetailView(field: field)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Componentes Principales
    
    private var spaceBackground: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Estrellas
            if showStars {
                ForEach(0..<150) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 1...3))
                        .opacity(Double.random(in: 0.1...0.8))
                        .position(
                            x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0..<UIScreen.main.bounds.height)
                        )
                }
            }
            
            // Nébulas
            if showNebulas {
                ForEach(0..<5) { i in
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
    
    private var noResultsView: some View {
        VStack {
            Text("No results available")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Button("Back") {
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(DefaultButtonStyle())
            .padding()
            .background(accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    private func resultContent(_ result: TestResult) -> some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header con avatar y cohete
                resultHeader(result)
                
                // Primary field card
                FieldResultCard(
                    field: result.primaryField,
                    score: result.fieldScores[result.primaryField] ?? 0.0,
                    isPrimary: true,
                    action: {
                        showingFieldDetail = result.primaryField
                    }
                )
                .padding(.horizontal)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 50)
                
                // Secondary field card
                FieldResultCard(
                    field: result.secondaryField,
                    score: result.fieldScores[result.secondaryField] ?? 0.0,
                    isPrimary: false,
                    action: {
                        showingFieldDetail = result.secondaryField
                    }
                )
                .padding(.horizontal)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 50)
                .animation(.easeOut.delay(0.2), value: animateContent)
                
                // Personality traits
                traitsSection(result)
                    .padding(.horizontal)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 50)
                    .animation(.easeOut.delay(0.4), value: animateContent)
                
                // Feedback
                feedbackSection
                    .padding(.horizontal)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 50)
                    .animation(.easeOut.delay(0.6), value: animateContent)
                
                // Action buttons
                actionButtons
                    .padding(.horizontal)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 50)
                    .animation(.easeOut.delay(0.8), value: animateContent)
                
                Spacer().frame(height: 30)
            }
            .padding(.top, 20)
        }
    }
    
    private func resultHeader(_ result: TestResult) -> some View {
        ZStack(alignment: .top) {
            // Cohete animado
            Text("🚀")
                .font(.system(size: 40))
                .rotationEffect(.degrees(rocketRotation))
                .offset(y: rocketOffset)
                .shadow(radius: 10, x: 0, y: 0)
            
            VStack(spacing: 20) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(result.primaryField.color.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .shadow(color: result.primaryField.color.opacity(0.5), radius: 15, x: 0, y: 5)
                }
                .scaleEffect(animateContent ? 1 : 0.5)
                .opacity(animateContent ? 1 : 0)
                
                // Titles
                VStack(spacing: 8) {
                    Text("Misión Completada!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: accentColor, radius: 10, x: 0, y: 0)
                    
                    Text("Tu perfil STEM")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(result.primaryField.rawValue)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(result.primaryField.color)
                        .padding(.top, 5)
                }
                .opacity(animateContent ? 1 : 0)
                .scaleEffect(animateContent ? 1 : 0.9)
            }
        }
    }
    
    private func traitsSection(_ result: TestResult) -> some View {
        VStack(spacing: 15) {
            Text("Tus Fortalezas Clave")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Traits grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach([result.primaryTrait, result.secondaryTrait], id: \.self) { trait in
                    TraitCard(trait: trait, isPrimary: trait == result.primaryTrait)
                }
            }
        }
    }
    
    private var feedbackSection: some View {
        VStack(spacing: 15) {
            Text("Recomendaciones")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(viewModel.generateFeedback())
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(accentColor.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: accentColor.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 15) {
            // Botón principal
            Button(action: {
                // Acción para explorar más campos
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Explorar Carreras")
                }
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [accentColor, secondaryColor]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .shadow(color: accentColor.opacity(0.5), radius: 10, x: 0, y: 5)
            }
            
            // Botón secundario
            Button(action: {
                viewModel.resetTest()
                onContinue()
            }) {
                Text("Realizar Test Nuevamente")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(accentColor)
                    .padding()
            }
        }
    }
    
    // MARK: - Vista de Detalle de Campo (solución al primer error)
    private func fieldDetailView(field: EngineeringField) -> some View {
        VStack(spacing: 20) {
            Text(field.rawValue)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(field.description)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .padding()
            
            Button("Cerrar") {
                showingFieldDetail = nil
            }
            .padding()
            .background(accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
    
    // MARK: - Animaciones
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0)) {
            showStars = true
            showNebulas = true
            animateContent = true
        }
        
        // Animación del cohete
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            rocketOffset = -20
            rocketRotation = 15
        }
    }
}

// MARK: - Componentes Reutilizables

struct FieldResultCard: View {
    let field: EngineeringField
    let score: Double
    let isPrimary: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Icono
                    ZStack {
                        Circle()
                            .fill(field.color.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: field.icon)
                            .font(.system(size: 22))
                            .foregroundColor(field.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(field.rawValue)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(isPrimary ? "Mejor coincidencia" : "Segunda opción")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isPrimary ? field.color : .white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Gráfico circular de puntuación
                    ZStack {
                        Circle()
                            .stroke(field.color.opacity(0.3), lineWidth: 6)
                            .frame(width: 50, height: 50)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(score))
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [field.color, field.color.opacity(0.5)]),
                                    center: .center,
                                    startAngle: .degrees(0),
                                    endAngle: .degrees(360)
                                ),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 50, height: 50)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int(score * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Text(field.description)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(field.color)
                    
                    Text("Ejemplos: \(field.realWorldExample)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(field.color)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isPrimary ? field.color.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
            )
            .shadow(color: isPrimary ? field.color.opacity(0.3) : .clear, radius: 20, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct TraitCard: View {
    let trait: PersonalityTrait
    let isPrimary: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: trait.icon)
                    .font(.system(size: 18))
                    .foregroundColor(isPrimary ? .white : Color(red: 0.25, green: 0.72, blue: 0.85))
                
                Text(trait.rawValue)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(trait.description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isPrimary ? Color(red: 0.25, green: 0.72, blue: 0.85).opacity(0.2) : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isPrimary ? Color(red: 0.25, green: 0.72, blue: 0.85) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Estilos y Efectos

struct ParticleEffectView: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
            }
        }
        .onAppear {
            for _ in 0..<30 {
                particles.append(Particle())
            }
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint = CGPoint(
        x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
        y: CGFloat.random(in: 0..<UIScreen.main.bounds.height)
    )
    var size: CGFloat = CGFloat.random(in: 1...3)
    var opacity: Double = Double.random(in: 0.1...0.5)
}

// MARK: - Previews

#Preview {
    let viewModel = VocationalTestViewModel()
    viewModel.selectedAvatar = Avatar.allAvatars.first
    viewModel.testResult = TestResult(
        avatar: Avatar.allAvatars.first!,
        fieldScores: [
            .mechatronics: 0.9,
            .robotics: 0.8,
            .computerScience: 0.7,
            .electrical: 0.6,
            .mechanical: 0.5,
            .industrial: 0.4,
            .biomedical: 0.3,
            .environmental: 0.2
        ],
        traitScores: [
            .analytical: 0.9,
            .creative: 0.8,
            .practical: 0.7,
            .teamPlayer: 0.6,
            .detailOriented: 0.5,
            .bigPictureThinker: 0.4,
            .problemSolver: 0.3,
            .communicator: 0.2
        ]
    )
    return ResultsView(viewModel: viewModel, onContinue: {})
}
