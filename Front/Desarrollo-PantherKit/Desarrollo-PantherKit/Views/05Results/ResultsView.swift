import SwiftUI
import SafariServices

struct ResultsView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var apiResponse: APIResponse?
    @State private var showFullDetails = false
    @State private var selectedCareer: APICareerRecommendation?
    @State private var animateBackground = false
    @State private var animateTitle = false
    @State private var animateCards = false
    @State private var isLoading = true
    @State private var showSTEMDirectory = false
    @State private var selectedSTEMCareer: STEMCareer?
    @State private var showGlobalAnalysis = false
    @State private var isLoadingAnalysis = false
    @State private var showAnalysisRequestButton = false
    
    // Colores
    private let accentColor = Color(red: 0.25, green: 0.72, blue: 0.85)
    private let secondaryColor = Color(red: 0.2, green: 0.6, blue: 1.0)
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.black,
            Color(red: 0.1, green: 0.1, blue: 0.3)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        ZStack {
            // Fondo espacial
            backgroundGradient
                .ignoresSafeArea()
            
            // Estrellas animadas
            AnimatedStarField(
                numberOfStars: 150,
                starBrightness: 0.7,
                starSpeed: 0.5
            )
            .opacity(animateBackground ? 1 : 0)
            
            // Nebulosas decorativas
            ForEach(0..<3) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                accentColor.opacity(0.2),
                                accentColor.opacity(0)
                            ]),
                            center: .center,
                            startRadius: 5,
                            endRadius: 200
                        )
                    )
                    .frame(width: 300, height: 300)
                    .position(
                        x: CGFloat.random(in: 50..<UIScreen.main.bounds.width-50),
                        y: CGFloat.random(in: 100..<UIScreen.main.bounds.height-100)
                    )
                    .blur(radius: 70)
                    .opacity(animateBackground ? 0.7 : 0)
            }
            
            // Contenido principal
            if isLoading {
                loadingView
            } else {
                ScrollView {
                    VStack(spacing: 25) {
                        // Encabezado
                        headerView
                            .opacity(animateTitle ? 1 : 0)
                            .offset(y: animateTitle ? 0 : -30)
                        
                        // Perfil MBTI
                        if let mbti = apiResponse?.mbtiProfile {
                            mbtiProfileView(mbti)
                                .padding(.horizontal)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 20)
                        }
                        
                        // Carreras recomendadas
                        if let recommendations = apiResponse?.careerRecommendations, !recommendations.isEmpty {
                            careerRecommendationsView(recommendations)
                                .padding(.horizontal)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 30)
                        }
                        
                        // Inteligencias múltiples
                        if let scores = apiResponse?.miScores {
                            multipleIntelligencesView(scores)
                                .padding(.horizontal)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 40)
                        }
                        
                        // Botón para solicitar análisis detallado si no está disponible
                        if apiResponse != nil && apiResponse?.analysis == nil && !isLoadingAnalysis {
                            requestAnalysisButton
                                .padding(.horizontal)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 40)
                        }
                        
                        // Análisis global detallado (si está disponible)
                        if let analysis = apiResponse?.analysis {
                            globalAnalysisView(analysis)
                                .padding(.horizontal)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 45)
                        }
                        
                        // Directorio de carreras STEM
                        stemDirectoryView()
                            .padding(.horizontal)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 50)
                        
                        // Indicador de análisis en carga
                        if isLoadingAnalysis {
                            analysisLoadingView
                                .padding(.horizontal)
                                .opacity(animateCards ? 1 : 0)
                        }
                        
                        Spacer(minLength: 80)
                    }
                    .padding(.top, 30)
                }
            }
        }
        .onAppear {
            loadAPIResponse()
            startAnimations()
            
            // Comprobar si debemos mostrar el botón de solicitar análisis
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                if apiResponse != nil && apiResponse?.analysis == nil {
                    showAnalysisRequestButton = true
                }
            }
        }
        .sheet(item: $selectedCareer) { career in
            careerDetailView(career)
        }
        .sheet(item: $selectedSTEMCareer) { career in
            SafariView(url: URL(string: career.promoURL)!)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    // MARK: - Vistas de componentes
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(accentColor)
                .rotationEffect(.degrees(animateBackground ? 360 : 0))
                .animation(
                    Animation.linear(duration: 5).repeatForever(autoreverses: false),
                    value: animateBackground
                )
            
            Text("Cargando tus resultados...")
                .font(.headline)
                .foregroundColor(.white)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                .scaleEffect(1.5)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 15) {
            Text("¡Resultados de tu viaje!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: accentColor.opacity(0.5), radius: 10)
                .padding(.horizontal)
            
            Text("Basado en tus respuestas, hemos encontrado las mejores carreras para tu perfil")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 10)
    }
    
    private func mbtiProfileView(_ profile: MBTIProfile) -> some View {
        VStack(spacing: 15) {
            // Título de la sección
            sectionHeader(title: "Tu Perfil de Personalidad", icon: "person.fill")
            
            // Código MBTI con explicación
            HStack(spacing: 30) {
                Text(profile.code)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [accentColor, secondaryColor]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: accentColor.opacity(0.5), radius: 10)
                    )
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(getMBTIDescription(profile.code))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(getMBTITraits(profile.code))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // Gráfico MBTI
            mbtiWeightsView(profile.weights)
                .frame(height: 100)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: accentColor.opacity(0.2), radius: 15)
        )
    }
    
    private func mbtiWeightsView(_ weights: MBTIWeights) -> some View {
        HStack(spacing: 15) {
            mbtiDimensionBar(label: "E - I", value: weights.ei, leftColor: .blue, rightColor: .purple)
            mbtiDimensionBar(label: "S - N", value: weights.sn, leftColor: .green, rightColor: .orange)
            mbtiDimensionBar(label: "T - F", value: weights.tf, leftColor: .red, rightColor: .pink)
            mbtiDimensionBar(label: "J - P", value: weights.jp, leftColor: .yellow, rightColor: .teal)
        }
    }
    
    private func mbtiDimensionBar(label: String, value: Double, leftColor: Color, rightColor: Color) -> some View {
        VStack(spacing: 5) {
            // Barra de dimensión
            ZStack(alignment: .bottom) {
                // Fondo de la barra
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 20, height: 70)
                
                // Barra de valor
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [leftColor, rightColor]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 20, height: 70 * CGFloat(value))
            }
            
            // Etiqueta
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private func careerRecommendationsView(_ careers: [APICareerRecommendation]) -> some View {
        VStack(spacing: 15) {
            // Título de la sección
            sectionHeader(title: "Carreras Recomendadas", icon: "graduationcap.fill")
            
            // Lista de carreras
            VStack(spacing: 12) {
                ForEach(careers.prefix(5)) { career in
                    careerCard(career)
                }
            }
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: accentColor.opacity(0.2), radius: 15)
        )
    }
    
    private func careerCard(_ career: APICareerRecommendation) -> some View {
        // Verificar si hay análisis disponible o podemos generarlo
        let hasAnalysis = career.careerAnalysis != nil || 
                         (apiResponse?.canGenerateAnalysisFor(careerName: career.nombre) ?? false)
        
        return VStack(spacing: 0) {
            // Información principal de la carrera
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(career.nombre)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack {
                        Text(career.universidad)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("•")
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(career.ciudad)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Indicador de compatibilidad
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                        .frame(width: 46, height: 46)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(min(career.matchScore * 20, 1.0)))
                        .stroke(
                            getMatchColor(score: career.matchScore),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 46, height: 46)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(career.matchScore * 100))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
            .onTapGesture {
                selectedCareer = career
            }
            
            // Botón de análisis detallado (si está disponible)
            if hasAnalysis {
                Button(action: {
                    selectedCareer = career
                }) {
                    HStack {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .foregroundColor(accentColor)
                            .font(.system(size: 14))
                        
                        Text("Ver análisis detallado")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(accentColor)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(accentColor.opacity(0.7))
                            .font(.system(size: 14))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                    )
                }
            }
        }
    }
    
    private func careerDetailView(_ career: APICareerRecommendation) -> some View {
        // Generar análisis para esta carrera si no existe
        let generatedAnalysis = career.careerAnalysis ?? apiResponse?.generateCareerAnalysis(for: career.nombre)
        
        return ZStack {
            // Fondo
            Color.black.opacity(0.9).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Encabezado con indicador de análisis personalizado
                    VStack(spacing: 8) {
                        Text(career.nombre)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        // Indicador de análisis personalizado
                        if generatedAnalysis != nil {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(accentColor)
                                    .font(.system(size: 12))
                                
                                Text("Análisis personalizado disponible")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(accentColor)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(accentColor.opacity(0.5), lineWidth: 1)
                                    .background(Color.black.opacity(0.3))
                            )
                        }
                    }
                    .padding(.top, 30)
                    
                    // Universidad y ciudad
                    HStack {
                        Image(systemName: "building.columns.fill")
                            .foregroundColor(accentColor)
                
                        Text(career.universidad)
                            .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    }
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(accentColor)
                        
                        Text(career.ciudad)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    // Compatibilidad
                    VStack(spacing: 10) {
                        Text("Compatibilidad con tu perfil")
                            .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 5)
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(min(career.matchScore * 20, 1.0)))
                                .stroke(
                                    getMatchColor(score: career.matchScore),
                                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                                )
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(Int(career.matchScore * 100))%")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 10)
                    }
                    .padding(.vertical, 10)
                    
                    // Contenido principal: Análisis o descripción genérica
                    Group {
                        // Análisis detallado (si está disponible)
                        if let analysis = generatedAnalysis {
                            VStack(alignment: .center) {
                                Text("Análisis personalizado")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(accentColor)
                                    .padding(.bottom, 20)
                                
                                analysisDetailView(analysis)
                            }
                        } else {
                            // Descripción genérica si no hay análisis detallado
                            VStack(alignment: .leading, spacing: 15) {
                                Text("¿Por qué es adecuada para ti?")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(accentColor)
                                
                                Text(getCareerDescription(career.nombre))
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(5)
                                    .padding(.bottom, 10)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 30)
                    
                    // Botón de cierre
                    Button(action: {
                        selectedCareer = nil
                    }) {
                        Text("Cerrar")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 40)
                            .background(
                                Capsule()
                                    .fill(accentColor)
                                    .shadow(color: accentColor.opacity(0.4), radius: 10)
                            )
                    }
                    .padding(.bottom, 30)
                }
                .padding()
            }
        }
    }
    
    // Vista para mostrar el análisis detallado de una carrera
    private func analysisDetailView(_ analysis: CareerAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Encabezado
            Text("Análisis personalizado")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(accentColor)
                .padding(.top, 10)
            
            // Por qué se recomienda
            VStack(alignment: .leading, spacing: 10) {
                Text("¿Por qué te recomendamos esta carrera?")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(accentColor.opacity(0.8))
                
                Text(analysis.whyRecommended)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(5)
            }
            
            // Compatibilidad con personalidad
            VStack(alignment: .leading, spacing: 10) {
                Text("Compatibilidad con tu personalidad")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(accentColor.opacity(0.8))
                
                Text(analysis.personalityFit)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(5)
            }
            
            // Compatibilidad con inteligencias
            VStack(alignment: .leading, spacing: 10) {
                Text("Relación con tus inteligencias múltiples")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(accentColor.opacity(0.8))
                
                Text(analysis.intelligencesFit)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(5)
            }
            
            // Habilidades a desarrollar
            VStack(alignment: .leading, spacing: 10) {
                Text("Habilidades a desarrollar")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(accentColor.opacity(0.8))
                
                ForEach(analysis.skillsToFocus, id: \.self) { skill in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "star.fill")
                            .foregroundColor(accentColor)
                            .font(.system(size: 12))
                            .padding(.top, 5)
                        
                        Text(skill)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.05))
                .padding(.horizontal, 10)
        )
    }
    
    private func multipleIntelligencesView(_ scores: MIScores) -> some View {
        VStack(spacing: 15) {
            // Título de la sección
            sectionHeader(title: "Tus Inteligencias Múltiples", icon: "brain.head.profile")
            
            // Gráfico de barras
            VStack(spacing: 8) {
                intelligenceBar(label: "Lingüística", value: scores.linguistic, color: .blue)
                intelligenceBar(label: "Lógico-Matemática", value: scores.logicalMath, color: .green)
                intelligenceBar(label: "Espacial", value: scores.spatial, color: .orange)
                intelligenceBar(label: "Corporal-Kinestésica", value: scores.bodilyKinesthetic, color: .red)
                intelligenceBar(label: "Musical", value: scores.musical, color: .purple)
                intelligenceBar(label: "Interpersonal", value: scores.interpersonal, color: .pink)
                intelligenceBar(label: "Intrapersonal", value: scores.intrapersonal, color: .yellow)
                intelligenceBar(label: "Naturalista", value: scores.naturalist, color: .teal)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 15)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: accentColor.opacity(0.2), radius: 15)
        )
    }
    
    private func intelligenceBar(label: String, value: Double, color: Color) -> some View {
        HStack {
            // Etiqueta
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 140, alignment: .leading)
            
            // Barra de progreso
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Fondo de la barra
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .cornerRadius(5)
                    
                    // Barra de valor
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.7), color]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(5)
                        .frame(width: geometry.size.width * CGFloat(value))
                }
            }
            .frame(height: 14)
            
            // Valor numérico
            Text("\(Int(value * 100))")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 30)
        }
        .frame(height: 24)
    }
    
    private func stemDirectoryView() -> some View {
        VStack(spacing: 15) {
            // Título de la sección
            sectionHeader(title: "Directorio de Carreras STEM", icon: "folder.fill")
            
            // Botón para ver todas las carreras
            Button(action: {
                withAnimation {
                    showSTEMDirectory.toggle()
                }
            }) {
                HStack {
                    Text(showSTEMDirectory ? "Ocultar directorio" : "Ver todas las carreras")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Image(systemName: showSTEMDirectory ? "chevron.up" : "chevron.down")
                        .foregroundColor(accentColor)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            // Lista de carreras STEM
            if showSTEMDirectory {
                VStack(spacing: 10) {
                    ForEach(getStemCareers()) { career in
                        stemCareerRow(career)
                    }
                }
                .padding(.top, 5)
            }
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: accentColor.opacity(0.2), radius: 15)
        )
    }
    
    private func stemCareerRow(_ career: STEMCareer) -> some View {
        Button(action: {
            selectedSTEMCareer = career
        }) {
            HStack {
                // Icono de la carrera
                Image(systemName: career.icon)
                    .foregroundColor(accentColor)
                    .font(.system(size: 16))
                    .frame(width: 30)
                
                // Nombre de la carrera
                Text(career.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Universidad
                Text(career.university)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                // Indicador de enlace
                Image(systemName: "link.circle.fill")
                    .foregroundColor(accentColor.opacity(0.8))
                    .font(.system(size: 16))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    // MARK: - Componentes reutilizables
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(accentColor)
            
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Funciones auxiliares
    
    private func loadAPIResponse() {
        // Simular tiempo de carga
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            apiResponse = ResponseService.shared.loadAPIResponse()
            isLoading = false
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.5)) {
            animateBackground = true
        }
        
        withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
            animateTitle = true
        }
        
        withAnimation(.easeInOut(duration: 1.2).delay(1.0)) {
            animateCards = true
        }
    }
    
    private func getMatchColor(score: Double) -> Color {
        let adjustedScore = score * 20 // Ajustar para una mejor visualización
        
        if adjustedScore > 0.8 {
            return .green
        } else if adjustedScore > 0.5 {
            return .yellow
        } else {
            return .orange
        }
    }
    
    private func getMBTIDescription(_ code: String) -> String {
        // Aquí podrías incluir descripciones personalizadas para cada tipo MBTI
        switch code {
        case "INFP":
            return "El Mediador: Idealista, creativo y orientado a valores"
        case "INTJ":
            return "El Arquitecto: Estratégico, innovador y planificador"
        case "ENFP":
            return "El Activista: Entusiasta, creativo y sociable"
        // Añadir más casos según sea necesario
        default:
            return "Personalidad equilibrada y multifacética"
        }
    }
    
    private func getMBTITraits(_ code: String) -> String {
        // Rasgos específicos para cada tipo MBTI
        switch code {
        case "INFP":
            return "Introspectivo • Empático • Imaginativo • Idealista"
        case "INTJ":
            return "Analítico • Independiente • Perfeccionista • Estratégico"
        case "ENFP":
            return "Carismático • Optimista • Espontáneo • Versátil"
        // Añadir más casos según sea necesario
        default:
            return "Adaptable • Balanceado • Flexible • Versátil"
        }
    }
    
    private func getCareerDescription(_ careerName: String) -> String {
        // Descripción personalizada para cada carrera
        switch careerName {
        case "Ingeniería en Energías Renovables":
            return "Esta carrera combina tu interés por la naturaleza y el medio ambiente con tus habilidades lógico-matemáticas. Tu perfil INFP te proporciona la creatividad y el idealismo necesarios para trabajar en soluciones innovadoras para problemas energéticos globales."
        case "Ingeniería Aeroespacial":
            return "Tu combinación de inteligencia espacial y lógico-matemática te hace ideal para esta carrera. Como INFP, tu creatividad e imaginación serán valiosas para el diseño y la innovación en tecnologías aeroespaciales."
        case "Ciencias Genómicas":
            return "Esta carrera aprovecha tu inteligencia naturalista y lógico-matemática. Tu perfil INFP te da la paciencia y la dedicación necesarias para la investigación científica profunda."
        // Más descripciones...
        default:
            return "Esta carrera se alinea con tus fortalezas y valores personales, ofreciéndote un camino profesional donde puedes aplicar tus habilidades naturales mientras contribuyes significativamente a tu campo elegido."
        }
    }
    
    // Modelo para carreras STEM
    private struct STEMCareer: Identifiable {
        let id = UUID()
        let name: String
        let university: String
        let icon: String
        let promoURL: String
    }
    
    // Obtener lista de carreras STEM
    private func getStemCareers() -> [STEMCareer] {
        return [
            STEMCareer(
                name: "Ingeniería en Sistemas Computacionales",
                university: "Universidad Panamericana",
                icon: "desktopcomputer",
                promoURL: "https://www.up.edu.mx/es/licenciatura/mex/ingenieria-en-sistemas-y-tecnologias-de-informacion"
            ),
            STEMCareer(
                name: "Ingeniería Mecánica",
                university: "Universidad Panamericana",
                icon: "gear",
                promoURL: "https://www.up.edu.mx/es/licenciatura/mex/ingenieria-mecanica"
            ),
            STEMCareer(
                name: "Ingeniería Industrial",
                university: "Universidad Panamericana",
                icon: "building.2",
                promoURL: "https://www.up.edu.mx/es/licenciatura/mex/ingenieria-industrial"
            ),
            STEMCareer(
                name: "Ingeniería Civil",
                university: "Universidad Panamericana",
                icon: "building.columns",
                promoURL: "https://www.up.edu.mx/es/licenciatura/mex/ingenieria-civil"
            ),
            STEMCareer(
                name: "Ingeniería Mecatrónica",
                university: "Universidad Panamericana",
                icon: "cpu",
                promoURL: "https://www.up.edu.mx/es/licenciatura/mex/ingenieria-mecatronica"
            ),
            STEMCareer(
                name: "Ingeniería Biomédica",
                university: "Universidad Panamericana",
                icon: "heart.text.square",
                promoURL: "https://www.up.edu.mx/es/licenciatura/mex/ingenieria-biomedica"
            ),
            STEMCareer(
                name: "Ingeniería Química",
                university: "Universidad Panamericana",
                icon: "flame",
                promoURL: "https://www.up.edu.mx/es/licenciatura/mex/ingenieria-quimica"
            ),
            STEMCareer(
                name: "Matemáticas Aplicadas",
                university: "UNAM",
                icon: "function",
                promoURL: "https://www.matematicas.unam.mx/"
            ),
            STEMCareer(
                name: "Física",
                university: "UNAM",
                icon: "atom",
                promoURL: "https://www.fisica.unam.mx/"
            ),
            STEMCareer(
                name: "Ciencia de Datos",
                university: "ITAM",
                icon: "chart.bar.xaxis",
                promoURL: "https://datos.itam.mx/es"
            ),
            STEMCareer(
                name: "Biotecnología",
                university: "Tec de Monterrey",
                icon: "leaf",
                promoURL: "https://tec.mx/es/estudiar-biotecnologia"
            ),
            STEMCareer(
                name: "Nanotecnología",
                university: "UNAM",
                icon: "plusminus.circle",
                promoURL: "https://www.nanociencias.unam.mx/"
            )
        ]
    }
    
    // Vista para mostrar el análisis global detallado
    private func globalAnalysisView(_ analysis: DetailedAnalysis) -> some View {
        VStack(spacing: 15) {
            // Título de la sección
            sectionHeader(title: "Análisis Personalizado", icon: "person.text.rectangle")
            
            // Botón para expandir/contraer el análisis
            Button(action: {
                withAnimation {
                    showGlobalAnalysis.toggle()
                }
            }) {
                HStack {
                    Text(showGlobalAnalysis ? "Ocultar análisis" : "Ver análisis completo")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Image(systemName: showGlobalAnalysis ? "chevron.up" : "chevron.down")
                        .foregroundColor(accentColor)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            // Contenido del análisis detallado
            if showGlobalAnalysis {
                VStack(alignment: .leading, spacing: 20) {
                    // Resumen de personalidad
                    analysisSection(
                        title: "Resumen de tu personalidad",
                        content: analysis.personalitySummary,
                        icon: "person.fill"
                    )
                    
                    // Resumen de inteligencias
                    analysisSection(
                        title: "Tus inteligencias destacadas",
                        content: analysis.intelligencesSummary,
                        icon: "brain.head.profile"
                    )
                    
                    // Lógica de recomendación
                    analysisSection(
                        title: "Por qué estas carreras te convienen",
                        content: analysis.recommendationRationale,
                        icon: "lightbulb.fill"
                    )
                    
                    // Habilidades sugeridas
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "hammer.fill")
                                .foregroundColor(accentColor)
                                .font(.system(size: 18))
                            
                            Text("Habilidades a desarrollar")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(analysis.suggestedSkills, id: \.self) { skill in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(accentColor.opacity(0.8))
                                        .font(.system(size: 14))
                                    
                                    Text(skill)
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                        }
                        .padding(.leading, 5)
                    }
                    
                    // Oportunidades y desafíos
                    HStack(alignment: .top, spacing: 15) {
                        // Oportunidades
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "arrow.up.forward.circle.fill")
                                    .foregroundColor(.green.opacity(0.8))
                                    .font(.system(size: 18))
                                
                                Text("Oportunidades")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(analysis.opportunities, id: \.self) { opportunity in
                                    HStack(alignment: .top) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.green.opacity(0.8))
                                            .font(.system(size: 14))
                                        
                                        Text(opportunity)
                                            .font(.system(size: 15))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                            }
                            .padding(.leading, 5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Desafíos
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange.opacity(0.8))
                                    .font(.system(size: 18))
                                
                                Text("Desafíos")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(analysis.challenges, id: \.self) { challenge in
                                    HStack(alignment: .top) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .foregroundColor(.orange.opacity(0.8))
                                            .font(.system(size: 14))
                                        
                                        Text(challenge)
                                            .font(.system(size: 15))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                            }
                            .padding(.leading, 5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 10)
            }
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: accentColor.opacity(0.2), radius: 15)
        )
    }
    
    // Componente para secciones de análisis
    private func analysisSection(title: String, content: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(accentColor)
                    .font(.system(size: 18))
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(content)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(5)
        }
    }
    
    // Botón para solicitar análisis detallado
    private var requestAnalysisButton: some View {
        Button(action: {
            requestDetailedAnalysis()
        }) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                
                Text("Solicitar análisis personalizado")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [secondaryColor, accentColor]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .cornerRadius(15)
            )
            .shadow(color: accentColor.opacity(0.5), radius: 10)
        }
    }
    
    // Vista de carga de análisis
    private var analysisLoadingView: some View {
        VStack(spacing: 15) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                .scaleEffect(1.2)
            
            Text("Obteniendo análisis personalizado...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: accentColor.opacity(0.2), radius: 15)
        )
    }
    
    // Simplified analysis request - now handled by backend
    private func requestDetailedAnalysis() {
        isLoadingAnalysis = true
        
        // Simulate analysis loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoadingAnalysis = false
            
            // Try to reload from stored response
            self.apiResponse = ResponseService.shared.loadAPIResponse()
            
            if self.apiResponse != nil {
                print("✅ Analysis loaded from stored response")
            } else {
                print("⚠️ No stored analysis found - use completeTest() to get backend analysis")
            }
        }
    }
}

// Vista Safari para mostrar enlaces web
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        // No se necesita actualización
    }
}

#Preview {
    ResultsView(viewModel: VocationalTestViewModel())
}
