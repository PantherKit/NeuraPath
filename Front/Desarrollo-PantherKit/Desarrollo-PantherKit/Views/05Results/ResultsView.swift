import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var viewModel: VocationalTestViewModel
    @Environment(\.presentationMode) var presentationMode
    var onContinue: () -> Void
    
    // State properties
    @State private var showingFieldDetail: EngineeringField?
    @State private var showStars: Bool = false
    @State private var showNebulas: Bool = false
    @State private var animateContent: Bool = false
    @State private var rocketOffset: CGFloat = 0
    @State private var rocketRotation: Double = 0
    @State private var selectedCareerForSubjects: UniversityCareer?
    @State private var showingCarousel: Bool = false  // Para controlar la sheet modal
    @State private var showingUniversityInfo: Bool = false // Para mostrar info de universidades
    @State private var shouldShowAdditionalInfo: Bool = false // Para mostrar información adicional
    
    // Colors
    private let accentColor = Color(red: 0.25, green: 0.72, blue: 0.85)
    private let secondaryColor = Color(red: 0.35, green: 0.42, blue: 0.95)
    
    // Toast manager
    private let toastManager = ToastManager.shared
    
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
        .sheet(isPresented: $showingCarousel) {
            careerCarouselSheet
        }
        .sheet(isPresented: $showingUniversityInfo) {
            universityInfoSheet
        }
        .onAppear {
            startAnimations()
            prepareCareerData()
            
            // Mostrar un toast relevante después de unos segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                toastManager.showRandomToast()
            }
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
    
    private var careerCarouselSheet: some View {
        ZStack {
            Color.black.opacity(0.95).edgesIgnoringSafeArea(.all)
            
            VStack {
                // Header con título y botón de cierre
                HStack {
                    Text("Carreras Recomendadas")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.hideCarousel()
                            showingCarousel = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 28))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Subtítulo explicando la relación con las respuestas
                Text("Basado en tus respuestas en el test vocacional")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                    .padding(.top, 4)
                
                // Carrusel
                if !viewModel.recommendedCareers.isEmpty {
                    CareerCarouselView(careers: viewModel.recommendedCareers)
                        .environmentObject(viewModel)
                        .padding(.top, 20)
                    
                    // Botón para ver detalles de universidades
                    Button(action: {
                        showingCarousel = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingUniversityInfo = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "building.columns")
                            Text("Ver información de universidades")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(accentColor.opacity(0.3))
                        .cornerRadius(12)
                    }
                    .padding(.top, 20)
                } else {
                    Text("No se encontraron carreras para este campo")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 40)
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private var universityInfoSheet: some View {
        ZStack {
            Color.black.opacity(0.95).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        Text("Universidades con programas STEM")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            showingUniversityInfo = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.system(size: 28))
                        }
                    }
                    
                    // Universidad sections
                    UniversityInfoCard(
                        name: "Universidad Panamericana",
                        programs: ["Ingeniería Mecatrónica", "Ingeniería Industrial", "Ingeniería en Sistemas"],
                        icon: "building.columns.fill",
                        color: .blue,
                        url: URL(string: "https://www.up.edu.mx/es/admisiones/gdl")
                    )
                    
                    UniversityInfoCard(
                        name: "ITESM",
                        programs: ["Ingeniería en Robótica", "Ingeniería en IA", "Ciencias Computacionales"],
                        icon: "building.2.fill",
                        color: .blue,
                        url: URL(string: "https://tec.mx/es/admisiones")
                    )
                    
                    UniversityInfoCard(
                        name: "Universidad de Guadalajara",
                        programs: ["Ingeniería Mecánica Eléctrica", "Ingeniería Mecatrónica", "Ingeniería en Robótica", "Ingeniería en Desarrollo de Software", "Ingeniería en Electrónica y Computación"],
                        icon: "building.columns.fill",
                        color: .red,
                        url: URL(string: "https://www.escolar.udg.mx/aspirantes")
                    )
                    
                    UniversityInfoCard(
                        name: "UNAM",
                        programs: ["Ciencias de la Computación", "Ingeniería Aeroespacial", "Ingeniería Eléctrica"],
                        icon: "building.columns",
                        color: .blue,
                        url: URL(string: "https://www.admision.unam.mx/")
                    )
                    
                    UniversityInfoCard(
                        name: "IPN",
                        programs: ["Ingeniería Eléctrica", "Mecánica", "Sistemas Computacionales"],
                        icon: "building",
                        color: .blue,
                        url: URL(string: "https://www.ipn.mx/dae/")
                    )
                    
                    // Enlaces a información externa
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Enlaces de interés")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Link(destination: URL(string: "https://www.anuies.mx/")!) {
                            HStack {
                                Image(systemName: "globe")
                                Text("Directorio nacional de universidades (ANUIES)")
                            }
                            .foregroundColor(accentColor)
                        }
                        
                        Link(destination: URL(string: "https://www.gob.mx/sep")!) {
                            HStack {
                                Image(systemName: "book.fill")
                                Text("Secretaría de Educación Pública (SEP)")
                            }
                            .foregroundColor(accentColor)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func resultContent(_ result: TestResult) -> some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header con avatar y cohete
                resultHeader(result)
                
                // Mensaje inclusivo sobre STEM
                inclusiveStemMessage
                    .padding(.horizontal)
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeOut.delay(0.1), value: animateContent)
                
                // Primary field card
                FieldResultCard(
                    field: result.primaryField,
                    score: result.fieldScores[result.primaryField] ?? 0.0,
                    isPrimary: true,
                    action: {
                        // Mostrar carrusel filtrado para el campo primario
                        viewModel.showCarouselFor(field: result.primaryField)
                        showingCarousel = true
                    }
                )
                .padding(.horizontal)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 50)
                .animation(.easeOut.delay(0.2), value: animateContent)
                
                // Secondary field card
                FieldResultCard(
                    field: result.secondaryField,
                    score: result.fieldScores[result.secondaryField] ?? 0.0,
                    isPrimary: false,
                    action: {
                        // Mostrar carrusel filtrado para el campo secundario
                        viewModel.showCarouselFor(field: result.secondaryField)
                        showingCarousel = true
                    }
                )
                .padding(.horizontal)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 50)
                .animation(.easeOut.delay(0.3), value: animateContent)
                
                // Personality traits
                traitsSection(result)
                    .padding(.horizontal)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 50)
                    .animation(.easeOut.delay(0.4), value: animateContent)
                
                // Inteligencias múltiples
                multipleIntelligencesSection(result)
                    .padding(.horizontal)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 50)
                    .animation(.easeOut.delay(0.5), value: animateContent)
                
                // Botón para mostrar/ocultar información adicional
                Button(action: {
                    withAnimation(.spring()) {
                        shouldShowAdditionalInfo.toggle()
                    }
                }) {
                    HStack {
                        Text(shouldShowAdditionalInfo ? "Ocultar detalles" : "Ver más detalles")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(accentColor)
                        
                        Image(systemName: shouldShowAdditionalInfo ? "chevron.up" : "chevron.down")
                            .foregroundColor(accentColor)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                }
                .padding(.horizontal)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 50)
                .animation(.easeOut.delay(0.6), value: animateContent)
                
                // Feedback y contenido adicional
                if shouldShowAdditionalInfo {
                    feedbackSection
                        .padding(.horizontal)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut.delay(0.1), value: shouldShowAdditionalInfo)
                    
                    careerDistributionChart(result)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut.delay(0.2), value: shouldShowAdditionalInfo)
                    
                    traitDistributionChart(result)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut.delay(0.3), value: shouldShowAdditionalInfo)
                    
                    // Referencias e inspiración
                    womenInStemSection
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut.delay(0.4), value: shouldShowAdditionalInfo)
                }
                
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
                    
                    // Mostrar icono relacionado con el campo primario
                    Image(systemName: result.primaryField.icon)
                        .font(.system(size: 40))
                        .foregroundColor(result.primaryField.color)
                }
                .scaleEffect(animateContent ? 1 : 0.5)
                .opacity(animateContent ? 1 : 0)
                
                // Titles
                VStack(spacing: 8) {
                    Text("¡Misión Completada!")
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
    
    private func careerDistributionChart(_ result: TestResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distribución de Campos STEM")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Tomar los 5 campos con mayor puntuación
            let topFields = result.fieldScores.sorted { $0.value > $1.value }.prefix(5)
            
            VStack(spacing: 12) {
                ForEach(Array(topFields), id: \.key) { field, score in
                    HStack {
                        Text(field.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 120, alignment: .leading)
                        
                        // Barra de progreso
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Fondo
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 8)
                                
                                // Progreso
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(field.color)
                                    .frame(width: geometry.size.width * score, height: 8)
                            }
                        }
                        .frame(height: 8)
                        
                        // Porcentaje
                        Text("\(Int(score * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(field.color)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    private func traitDistributionChart(_ result: TestResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Perfil de Personalidad")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Tomar los 4 rasgos con mayor puntuación
            let topTraits = result.traitScores.sorted { $0.value > $1.value }.prefix(4)
            
            VStack(spacing: 12) {
                ForEach(Array(topTraits), id: \.key) { trait, score in
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: trait.icon)
                                .foregroundColor(accentColor)
                            
                            Text(trait.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(width: 140, alignment: .leading)
                        
                        // Barra de progreso
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Fondo
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 8)
                                
                                // Progreso
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [accentColor, secondaryColor]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * score, height: 8)
                            }
                        }
                        .frame(height: 8)
                        
                        // Porcentaje
                        Text("\(Int(score * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(accentColor)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 15) {
            // Botón principal
            Button(action: {
                viewModel.showCarouselFor(field: viewModel.testResult?.primaryField ?? .computerScience)
                showingCarousel = true
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
    
    // MARK: - Vista de Detalle de Campo
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
    
    // MARK: - Animaciones y Datos
    
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
    
    private func prepareCareerData() {
        // Asegurarse de que las carreras recomendadas estén cargadas
        if let result = viewModel.testResult, viewModel.recommendedCareers.isEmpty {
            viewModel.recommendedCareers = UniversityCareer.getRecommendedCareers(from: result)
        }
    }
    
    // Mensaje inclusivo sobre STEM
    private var inclusiveStemMessage: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("STEM es para todos")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Las carreras científicas y tecnológicas se benefician de la diversidad de perspectivas. No se trata solo de matemáticas, sino de creatividad, resolución de problemas, comunicación y trabajo en equipo.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 4)
            
            HStack(spacing: 16) {
                // Cerebro creativo
                Image(systemName: "brain")
                    .font(.system(size: 24))
                    .foregroundColor(accentColor)
                
                // Diversidad 
                Image(systemName: "person.3.fill")
                    .font(.system(size: 24))
                    .foregroundColor(secondaryColor)
                
                // Idea
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.yellow)
                
                // Comunicación
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [.white.opacity(0.2), .clear]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // Sección de inteligencias múltiples
    private func multipleIntelligencesSection(_ result: TestResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tus Inteligencias Múltiples")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("La teoría de Howard Gardner muestra que la inteligencia no es única. Tus respuestas revelan tus fortalezas en diferentes tipos de inteligencia.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 10)
            
            // Grid de inteligencias
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                intelligenceCard(
                    title: "Lógico-Matemática",
                    description: "Habilidad para resolver problemas y razonar lógicamente",
                    icon: "function",
                    color: .cyan,
                    primary: isPrimaryIntelligenceFor(result, .computerScience, .electrical)
                )
                
                intelligenceCard(
                    title: "Visual-Espacial",
                    description: "Capacidad para visualizar y manipular objetos mentalmente",
                    icon: "cube",
                    color: .purple,
                    primary: isPrimaryIntelligenceFor(result, .mechanical, .robotics)
                )
                
                intelligenceCard(
                    title: "Interpersonal",
                    description: "Capacidad para entender y trabajar con otras personas",
                    icon: "person.2.fill",
                    color: .green,
                    primary: isPrimaryIntelligenceFor(result, .industrial)
                )
                
                intelligenceCard(
                    title: "Naturalista",
                    description: "Sensibilidad hacia el entorno natural y sus elementos",
                    icon: "leaf.fill",
                    color: .mint,
                    primary: isPrimaryIntelligenceFor(result, .environmental, .biomedical)
                )
            }
        }
    }
    
    // Helpers for multiple intelligences
    private func isPrimaryIntelligenceFor(_ result: TestResult, _ fields: EngineeringField...) -> Bool {
        // Verifica si alguno de los campos especificados está entre los 2 principales
        return fields.contains(result.primaryField) || fields.contains(result.secondaryField)
    }
    
    // Card de inteligencia
    private func intelligenceCard(title: String, description: String, icon: String, color: Color, primary: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(primary ? color : .white.opacity(0.7))
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(primary ? color.opacity(0.15) : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(primary ? color.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
    
    // Sección de referentes en STEM personalizada
    private var womenInStemSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Referentes con tu perfil")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Personas destacadas con quienes podrías identificarte:")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(getPersonalizedReferents(), id: \.name) { referent in
                        referentCardNew(
                            name: referent.name,
                            contribution: referent.contribution,
                            field: referent.field,
                            image: referent.image,
                            icon: referent.icon
                        )
                    }
                }
                .padding(.bottom, 8)
            }
            
            // Mensaje inspirador
            Text("Estos pioneros y pioneras en STEM compartían rasgos de personalidad similares a los tuyos. Su diversidad de pensamiento y fortalezas únicas fueron clave para sus innovaciones.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    // Tarjeta de referente en STEM mejorada con imagen
    private func referentCardNew(name: String, contribution: String, field: String, image: String, icon: String) -> some View {
        VStack(alignment: .center, spacing: 12) {
            // Imagen o avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [accentColor.opacity(0.3), secondaryColor.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 90, height: 90)
                
                // Si es un emoji, mostrarlo directamente
                if image.containsOnlyEmoji {
                    Text(image)
                        .font(.system(size: 40))
                } else {
                    // Si es un systemName, usar Image
                    Image(systemName: image)
                        .font(.system(size: 36))
                        .foregroundColor(accentColor)
                }
            }
            
            VStack(alignment: .center, spacing: 6) {
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Ícono representativo de su contribución
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(accentColor)
                    
                    Text(field)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(accentColor)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(accentColor.opacity(0.1))
                .cornerRadius(10)
                
                Text(contribution)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .padding(.horizontal, 4)
            }
        }
        .frame(width: 180, height: 280)
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(LinearGradient(
                    gradient: Gradient(colors: [accentColor.opacity(0.3), .clear]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: 1)
        )
    }
    
    // Estructura para referentes personalizados
    private struct STEMReferent {
        let name: String
        let contribution: String
        let field: String
        let image: String // systemName o emoji
        let icon: String  // systemName
    }
    
    // Obtener referentes personalizados basados en el perfil
    private func getPersonalizedReferents() -> [STEMReferent] {
        guard let result = viewModel.testResult else { return [] }
        
        let primaryField = result.primaryField
        let primaryTrait = result.primaryTrait
        
        // Base de referentes organizados por campo y rasgo
        let allReferents: [EngineeringField: [PersonalityTrait: [STEMReferent]]] = [
            .computerScience: [
                .analytical: [
                    STEMReferent(name: "Alan Turing", contribution: "Padre de la computación teórica. Descifró códigos nazis con pensamiento analítico sistemático.", field: "Ciencias Computacionales", image: "desktopcomputer", icon: "lock.open"),
                    STEMReferent(name: "Grace Hopper", contribution: "Pionera en lenguajes de programación. Creó el primer compilador con enfoque metódico para solucionar problemas complejos.", field: "Programación", image: "server.rack", icon: "chevron.left.forwardslash.chevron.right")
                ],
                .creative: [
                    STEMReferent(name: "Steve Wozniak", contribution: "Cofundador de Apple. Combinó creatividad e ingeniería para crear el Apple I y Apple II.", field: "Innovación Tecnológica", image: "laptopcomputer", icon: "lightbulb"),
                    STEMReferent(name: "Ada Lovelace", contribution: "Primera programadora. Visualizó creativamente posibilidades de cómputo cuando no existían computadoras.", field: "Programación", image: "function", icon: "wand.and.stars")
                ],
                .problemSolver: [
                    STEMReferent(name: "Katherine Johnson", contribution: "Matemática de la NASA cuyo trabajo fue crucial para las misiones Apolo y Mercury.", field: "Matemáticas Aplicadas", image: "function", icon: "moon.stars"),
                    STEMReferent(name: "Linus Torvalds", contribution: "Creador de Linux y Git. Resolvió problemas de sistemas operativos con soluciones elegantes y abiertas.", field: "Software Libre", image: "terminal", icon: "network")
                ]
            ],
            .robotics: [
                .practical: [
                    STEMReferent(name: "Rodney Brooks", contribution: "Pionero en robots prácticos como Roomba. Enfatizó la interacción con el mundo real sobre teoría abstracta.", field: "Robótica", image: "circles.hexagongrid", icon: "gearshape.2"),
                    STEMReferent(name: "Ayanna Howard", contribution: "Especialista en robótica inteligente y humanoide. Diseña robots para aplicaciones médicas y educativas.", field: "Robótica Social", image: "person.fill.viewfinder", icon: "brain.head.profile")
                ],
                .creative: [
                    STEMReferent(name: "Cynthia Breazeal", contribution: "Creadora de robots sociales como Kismet. Pionera en interacción humano-robot con enfoque creativo.", field: "Interacción Robot-Humano", image: "face.smiling", icon: "person.wave.2"),
                    STEMReferent(name: "Boston Dynamics", contribution: "Empresa innovadora que desarrolla robots que imitan movimientos de animales, como el perro robot Spot.", field: "Robótica Avanzada", image: "figure.walk", icon: "move.3d")
                ]
            ],
            .mechanical: [
                .detailOriented: [
                    STEMReferent(name: "Nikola Tesla", contribution: "Inventor meticuloso con más de 300 patentes. Su atención al detalle permitió crear sistemas eléctricos revolucionarios.", field: "Ingeniería Eléctrica", image: "bolt.fill", icon: "antenna.radiowaves.left.and.right"),
                    STEMReferent(name: "Leonardo da Vinci", contribution: "Considerado el primer ingeniero moderno. Sus diseños detallados de máquinas estaban siglos adelantados.", field: "Diseño Mecánico", image: "gearshape.2", icon: "pencil.and.ruler")
                ],
                .problemSolver: [
                    STEMReferent(name: "Elon Musk", contribution: "Fundador de SpaceX y Tesla. Resuelve problemas complejos de ingeniería como reutilización de cohetes.", field: "Ingeniería Aeroespacial", image: "🚀", icon: "arrow.up.forward"),
                    STEMReferent(name: "Mae Jemison", contribution: "Primera mujer afroamericana astronauta. Ingeniera y médica que resolvió problemas de ingeniería en el espacio.", field: "Astronáutica", image: "globe.americas.fill", icon: "person.fill.turn.right")
                ]
            ],
            .mechatronics: [
                .bigPictureThinker: [
                    STEMReferent(name: "James Dyson", contribution: "Inventor que revolucionó electrodomésticos con visión integrada de mecánica, electrónica y diseño.", field: "Mecatrónica Aplicada", image: "wind", icon: "tornado"),
                    STEMReferent(name: "Limor Fried", contribution: "Fundadora de Adafruit. Pionera en hardware abierto y electrónica DIY con visión ecosistémica.", field: "Electrónica", image: "cpu", icon: "network")
                ],
                .creative: [
                    STEMReferent(name: "Simone Giertz", contribution: "Inventora de 'robots inútiles'. Usa creatividad y humor para explorar mecatrónica y robótica.", field: "Robótica Creativa", image: "wand.and.stars", icon: "video"),
                    STEMReferent(name: "Anousheh Ansari", contribution: "Primera mujer turista espacial. Emprendedora que visualizó aplicaciones comerciales de tecnología espacial.", field: "Tecnología Espacial", image: "sparkles", icon: "airplane")
                ]
            ],
            .biomedical: [
                .teamPlayer: [
                    STEMReferent(name: "Rosalind Franklin", contribution: "Cristalógrafa cuyo trabajo en equipo fue clave para descubrir la estructura del ADN.", field: "Biología Molecular", image: "dna", icon: "camera"),
                    STEMReferent(name: "Katalin Karikó", contribution: "Bioquímica pionera en tecnología de ARNm. Su colaboración persistente llevó a vacunas COVID-19.", field: "Bioquímica", image: "cross.case", icon: "heart")
                ],
                .communicator: [
                    STEMReferent(name: "Neil deGrasse Tyson", contribution: "Astrofísico y divulgador científico. Comunica conceptos científicos complejos con claridad.", field: "Divulgación Científica", image: "star.fill", icon: "mic"),
                    STEMReferent(name: "Temple Grandin", contribution: "Científica con autismo que revolucionó prácticas ganaderas humanas. Comunica perspectivas neurodiversas.", field: "Bienestar Animal", image: "brain", icon: "quote.bubble")
                ]
            ],
            .industrial: [
                .practical: [
                    STEMReferent(name: "Lillian Gilbreth", contribution: "Pionera en ingeniería industrial. Desarrolló métodos prácticos para optimizar eficiencia en hogares y fábricas.", field: "Ingeniería Industrial", image: "clock.arrow.2.circlepath", icon: "house"),
                    STEMReferent(name: "Eiji Toyoda", contribution: "Transformó Toyota con el sistema de producción eficiente 'just-in-time' y mejora continua.", field: "Manufactura", image: "car", icon: "arrow.triangle.2.circlepath")
                ],
                .bigPictureThinker: [
                    STEMReferent(name: "W. Edwards Deming", contribution: "Estadístico que revolucionó la gestión de calidad con enfoque sistémico en lugar de puntual.", field: "Gestión de Calidad", image: "chart.bar", icon: "arrow.up.right"),
                    STEMReferent(name: "Taiichi Ohno", contribution: "Creador del sistema Toyota. Visualizó la producción como flujo integrado en vez de procesos aislados.", field: "Ingeniería de Procesos", image: "arrow.triangle.pull", icon: "minus.forwardslash.plus")
                ]
            ],
            .electrical: [
                .analytical: [
                    STEMReferent(name: "Claude Shannon", contribution: "Padre de la teoría de la información. Estableció bases matemáticas para comunicaciones digitales.", field: "Teoría de la Información", image: "waveform.path", icon: "function"),
                    STEMReferent(name: "Edith Clarke", contribution: "Primera mujer ingeniera eléctrica profesional. Desarrolló calculadoras para resolver ecuaciones de líneas eléctricas.", field: "Ingeniería Eléctrica", image: "bolt.horizontal", icon: "calculator")
                ],
                .detailOriented: [
                    STEMReferent(name: "Faraday", contribution: "Desarrolló la inducción electromagnética. Su atención meticulosa a experimentos revolucionó la electricidad.", field: "Electromagnetismo", image: "magnet", icon: "lightbulb"),
                    STEMReferent(name: "Jack Kilby", contribution: "Inventor del circuito integrado. Su precisión en diseños miniaturizados transformó la electrónica.", field: "Microelectrónica", image: "cpu", icon: "plusminus")
                ]
            ],
            .environmental: [
                .communicator: [
                    STEMReferent(name: "Rachel Carson", contribution: "Bióloga marina cuyo libro 'Primavera Silenciosa' inició el movimiento ambientalista moderno.", field: "Ecología", image: "leaf", icon: "book"),
                    STEMReferent(name: "Bill Nye", contribution: "Ingeniero y divulgador que comunica problemas ambientales y soluciones científicas.", field: "Divulgación Científica", image: "theatermasks", icon: "globe")
                ],
                .teamPlayer: [
                    STEMReferent(name: "Wangari Maathai", contribution: "Fundadora del Movimiento Cinturón Verde. Combinó ciencia y comunidad para reforestar Kenia.", field: "Ecología Práctica", image: "tree", icon: "person.3"),
                    STEMReferent(name: "Jane Goodall", contribution: "Primatóloga que construyó equipos globales para conservación y educación ambiental.", field: "Conservación", image: "pawprint", icon: "hand.raised")
                ]
            ]
        ]
        
        // Obtener referentes basados en campo y rasgo principales
        var referents: [STEMReferent] = []
        
        // Añadir referentes del campo y rasgo principal
        if let fieldReferents = allReferents[primaryField], let traitReferents = fieldReferents[primaryTrait] {
            referents.append(contentsOf: traitReferents)
        }
        
        // Si no hay suficientes, añadir más del mismo campo pero otro rasgo
        if referents.count < 2, let fieldReferents = allReferents[primaryField] {
            for (trait, traitReferents) in fieldReferents where trait != primaryTrait {
                referents.append(contentsOf: traitReferents)
                if referents.count >= 4 { break }
            }
        }
        
        // Si sigue sin haber suficientes, añadir del campo secundario
        if referents.count < 3 {
            let secondaryField = result.secondaryField
            if let fieldReferents = allReferents[secondaryField], let traitReferents = fieldReferents[primaryTrait] {
                referents.append(contentsOf: traitReferents)
            }
        }
        
        // Si aún no tenemos al menos 3, añadir predeterminados
        if referents.count < 2 {
            referents.append(STEMReferent(name: "Ada Lovelace", contribution: "Primera programadora. Trabajó en la máquina analítica de Babbage en el siglo XIX.", field: "Computación", image: "function", icon: "keyboard"))
            referents.append(STEMReferent(name: "Katherine Johnson", contribution: "Matemática en la NASA cuyo trabajo fue crucial para las misiones Apolo.", field: "Matemáticas", image: "rocket", icon: "moon.stars"))
            referents.append(STEMReferent(name: "Marie Curie", contribution: "Primera persona en ganar dos Premios Nobel en distintos campos científicos.", field: "Física y Química", image: "atom", icon: "sparkles"))
        }
        
        // Limitar a 4 referentes máximo
        return Array(referents.prefix(4))
    }
}

// Extensión para validar si un String solo contiene emojis
extension String {
    var containsOnlyEmoji: Bool {
        return !isEmpty && unicodeScalars.allSatisfy { $0.properties.isEmoji }
    }
}

extension UnicodeScalar {
    var isEmoji: Bool {
        return properties.isEmoji
    }
}

// MARK: - Componentes Adicionales

struct UniversityInfoCard: View {
    let name: String
    let programs: [String]
    let icon: String
    let color: Color
    var url: URL?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                
                Text(name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if let validUrl = url {
                    Link(destination: validUrl) {
                        HStack(spacing: 4) {
                            Text("Admisiones")
                                .font(.system(size: 12))
                            Image(systemName: "link.circle")
                        }
                        .foregroundColor(color.opacity(0.7))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(color.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            Text("Programas STEM:")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(programs, id: \.self) { program in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(color)
                        
                        Text(program)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.leading, 4)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Componentes Reutilizables

struct FieldResultCard: View {
    let field: EngineeringField
    let score: Double
    let isPrimary: Bool
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    @State private var showDetails: Bool = false
    
    // Toast manager
    private let toastManager = ToastManager.shared
    
    var body: some View {
        Button(action: {
            hapticFeedback()
            action()
            
            // Posibilidad de mostrar toast motivacional al seleccionar un campo
            if Double.random(in: 0...1) < 0.5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    toastManager.showRandomToast()
                }
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Encabezado del campo con icono y título
                HStack(alignment: .center) {
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
                        HStack(alignment: .center, spacing: 6) {
                            Text(field.rawValue)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            if isPrimary {
                                ZStack {
                                    Capsule()
                                        .fill(field.color.opacity(0.3))
                                        .frame(height: 22)
                                    
                                    Text("Mejor coincidencia")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(field.color)
                                        .padding(.horizontal, 8)
                                }
                            }
                        }
                        
                        Text(isPrimary ? "Coincide perfectamente con tus respuestas" : "Buena alternativa según tu perfil")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isPrimary ? field.color : .white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Gráfico circular de puntuación mejorado
                    ZStack {
                        Circle()
                            .stroke(field.color.opacity(0.3), lineWidth: 6)
                            .frame(width: 55, height: 55)
                        
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
                            .frame(width: 55, height: 55)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 0) {
                            Text("\(Int(score * 100))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("%")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                
                // Botón para mostrar/ocultar detalles
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showDetails.toggle()
                    }
                }) {
                    HStack {
                        Text(showDetails ? "Ocultar descripción" : "Ver descripción")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(field.color.opacity(0.8))
                        
                        Spacer()
                        
                        Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(field.color.opacity(0.8))
                    }
                    .padding(.vertical, 6)
                }
                
                // Descripción del campo - visible solo si showDetails es true
                if showDetails {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(field.description)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Áreas de aplicación:")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                            
                            ForEach(field.realWorldExample.components(separatedBy: ", "), id: \.self) { example in
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(field.color)
                                    
                                    Text(example)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                HStack {
                    Image(systemName: "building.columns")
                        .foregroundColor(field.color)
                    
                    Text("Universidades: UP, ITESM, UNAM, IPN")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    // Añadir etiqueta para indicar que se puede ver carreras
                    HStack(spacing: 4) {
                        Text("Ver carreras")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(field.color)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(field.color)
                            .font(.system(size: 12))
                    }
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
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            self.isPressed = pressing
        }, perform: {})
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
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
    
    // Add recommended careers for preview
    viewModel.recommendedCareers = UniversityCareer.getRecommendedCareers(from: viewModel.testResult!)
    
    return ResultsView(onContinue: {})
        .environmentObject(viewModel)
}
