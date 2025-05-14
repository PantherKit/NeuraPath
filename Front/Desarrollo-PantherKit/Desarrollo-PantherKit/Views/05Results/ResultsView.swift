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
                        color: .blue
                    )
                    
                    UniversityInfoCard(
                        name: "ITESM",
                        programs: ["Ingeniería en Robótica", "Ingeniería en IA", "Ciencias Computacionales"],
                        icon: "building.2.fill",
                        color: .blue
                    )
                    
                    UniversityInfoCard(
                        name: "UNAM",
                        programs: ["Ciencias de la Computación", "Ingeniería Aeroespacial", "Ingeniería Eléctrica"],
                        icon: "building.columns",
                        color: .blue
                    )
                    
                    UniversityInfoCard(
                        name: "IPN",
                        programs: ["Ingeniería Eléctrica", "Mecánica", "Sistemas Computacionales"],
                        icon: "building",
                        color: .blue
                    )
                    
                    // Enlaces a información externa
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Enlaces de interés")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "globe")
                            Text("Directorio de universidades")
                        }
                        .foregroundColor(accentColor)
                        
                        HStack {
                            Image(systemName: "book.fill")
                            Text("Guía para elegir carrera")
                        }
                        .foregroundColor(accentColor)
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
                .animation(.easeOut.delay(0.2), value: animateContent)
                
                // Personality traits
                traitsSection(result)
                    .padding(.horizontal)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 50)
                    .animation(.easeOut.delay(0.4), value: animateContent)
                
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
                .animation(.easeOut.delay(0.5), value: animateContent)
                
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
}

// MARK: - Componentes Adicionales

struct UniversityInfoCard: View {
    let name: String
    let programs: [String]
    let icon: String
    let color: Color
    
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
                
                Image(systemName: "link.circle")
                    .font(.system(size: 18))
                    .foregroundColor(color.opacity(0.7))
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
