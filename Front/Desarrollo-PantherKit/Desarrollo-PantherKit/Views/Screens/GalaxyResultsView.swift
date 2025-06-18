//
//  GalaxyResultsView.swift
//  NeuraPath - Complete STEM Analysis Demo
//

import SwiftUI

struct GalaxyResultsView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var isAnimating = false
    @State private var showFieldDetails = false
    @State private var selectedField: EngineeringField? = nil
    @State private var animateBackground = false
    @State private var animateTitle = false
    @State private var animateCards = false
    @State private var showPersonalityAnalysis = false
    @State private var showIntelligenceAnalysis = false
    @State private var showMBTIAnalysis = false
    
    // Demo data
    private let demoFields = DemoData.demoFields
    private let starSizes: [CGFloat] = [80, 70, 60, 50, 45]
    
    // Colores tema
    private let accentColor = Color(red: 0.25, green: 0.72, blue: 0.85)
    private let secondaryColor = Color(red: 0.2, green: 0.6, blue: 1.0)
    
    var body: some View {
        ZStack {
            // Fondo espacial con gradiente
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color.black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Campo de estrellas animado
            AnimatedStarField(
                numberOfStars: 200,
                starBrightness: 0.8,
                starSpeed: 0.3
            )
            .opacity(animateBackground ? 1 : 0)
            
            // Nebulosas decorativas
            ForEach(0..<4) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                [accentColor, secondaryColor, .purple, .blue][i].opacity(0.3),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 5,
                            endRadius: 300
                        )
                    )
                    .frame(width: 400, height: 400)
                    .position(
                        x: CGFloat.random(in: 50..<UIScreen.main.bounds.width-50),
                        y: CGFloat.random(in: 100..<UIScreen.main.bounds.height-100)
                    )
                    .blur(radius: 80)
                    .opacity(animateBackground ? 0.6 : 0)
            }
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header principal
                    headerView
                        .opacity(animateTitle ? 1 : 0)
                        .offset(y: animateTitle ? 0 : -50)
                    
                    // Vista Galaxia STEM con análisis
                    galaxyAnalysisView
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 30)
                    
                    // Análisis MBTI
                    mbtiAnalysisView
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 40)
                    
                    // Análisis de Inteligencias Múltiples
                    intelligencesAnalysisView
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 50)
                    
                    // Rasgos de Personalidad
                    personalityAnalysisView
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 60)
                    
                    // Recomendaciones de Carrera
                    careerRecommendationsView
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 70)
                    
                    // Botones de acción
                    actionButtonsView
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 80)
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 15)
                .padding(.top, 20)
            }
            
            // Modal de detalles de campo
            if showFieldDetails, let field = selectedField {
                fieldDetailsModal(field)
                    .zIndex(10)
            }
        }
        .onAppear {
            startAnimations()
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 15) {
            Text("🌟 Tu Mapa Estelar STEM 🌟")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: accentColor.opacity(0.5), radius: 10)
            
            Text("Análisis Completo de tu Perfil Vocacional")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
            
            // Indicador de análisis personalizado
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Análisis Personalizado Completo")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.yellow)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                    .background(Color.black.opacity(0.3))
            )
        }
    }
    
    // MARK: - Galaxy Analysis View
    private var galaxyAnalysisView: some View {
        VStack(spacing: 20) {
            sectionHeader(title: "Tu Galaxia de Afinidades STEM", icon: "star.circle.fill")
            
            // Vista de galaxia interactiva
            ZStack {
                // Fondo de la galaxia
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black.opacity(0.7))
                    .frame(height: 450)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(accentColor.opacity(0.3), lineWidth: 2)
                    )
                
                // Estrellas STEM
                ZStack {
                    // Estrella central (campo principal)
                    StarView(
                        field: DemoData.primaryField,
                        size: 100,
                        score: 1.0,
                        position: .center,
                        isAnimating: isAnimating
                    )
                    .onTapGesture {
                        selectedField = DemoData.primaryField
                        showFieldDetails = true
                    }
                    
                    // Estrellas orbitales (otros campos)
                    ForEach(Array(demoFields.filter { $0 != DemoData.primaryField }.enumerated()), id: \.element) { index, field in
                        let score = DemoData.normalizedScore(for: field)
                        let size = starSizes[min(index, starSizes.count - 1)]
                        let angle = Double(index) * (360.0 / Double(demoFields.count - 1))
                        let distance = 120.0 + Double(index) * 25.0
                        
                        StarView(
                            field: field,
                            size: size,
                            score: score,
                            position: .orbit(angle: angle, distance: distance),
                            isAnimating: isAnimating
                        )
                        .onTapGesture {
                            selectedField = field
                            showFieldDetails = true
                        }
                    }
                }
                .frame(height: 400)
            }
            
            // Leyenda de campos
            VStack(alignment: .leading, spacing: 12) {
                Text("🎯 Tus Mejores Afinidades:")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                ForEach(DemoData.topFields.prefix(5), id: \.self) { field in
                    HStack {
                        Circle()
                            .fill(field.color)
                            .frame(width: 12, height: 12)
                        
                        Text(field.rawValue)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(Int(DemoData.normalizedScore(for: field) * 100))%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(field.color)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(field.color)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(accentColor.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: accentColor.opacity(0.2), radius: 15)
        )
    }
    
    // MARK: - MBTI Analysis View
    private var mbtiAnalysisView: some View {
        VStack(spacing: 15) {
            Button(action: {
                withAnimation {
                    showMBTIAnalysis.toggle()
                }
            }) {
                HStack {
                    sectionHeader(title: "Perfil MBTI: \(DemoData.sampleAPIResponse.mbtiProfile.code)", icon: "person.fill.badge.plus")
                    
                    Spacer()
                    
                    Image(systemName: showMBTIAnalysis ? "chevron.up" : "chevron.down")
                        .foregroundColor(accentColor)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            
            if showMBTIAnalysis {
                VStack(alignment: .leading, spacing: 15) {
                    // Descripción del tipo
                    Text("El Inspirador - Entusiasta, creativo y sociable")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(accentColor)
                    
                    Text("Eres una persona que busca nuevas posibilidades y conexiones significativas. Tu energía contagiosa y tu capacidad para ver el potencial en las ideas y en las personas te convierte en un líder natural en proyectos innovadores.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(4)
                    
                    // Dimensiones MBTI
                    VStack(spacing: 10) {
                        mbtiDimension("Extroversión", value: 0.75, description: "Energía de interacciones sociales")
                        mbtiDimension("iNtuición", value: 0.80, description: "Enfoque en posibilidades futuras")
                        mbtiDimension("Sentimiento", value: 0.65, description: "Decisiones basadas en valores")
                        mbtiDimension("Percepción", value: 0.70, description: "Flexibilidad y adaptabilidad")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.05))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: secondaryColor.opacity(0.2), radius: 15)
        )
    }
    
    // MARK: - Intelligences Analysis View
    private var intelligencesAnalysisView: some View {
        VStack(spacing: 15) {
            Button(action: {
                withAnimation {
                    showIntelligenceAnalysis.toggle()
                }
            }) {
                HStack {
                    sectionHeader(title: "Inteligencias Múltiples", icon: "brain.head.profile")
                    
                    Spacer()
                    
                    Image(systemName: showIntelligenceAnalysis ? "chevron.up" : "chevron.down")
                        .foregroundColor(accentColor)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            
            if showIntelligenceAnalysis {
                VStack(spacing: 12) {
                    // Top 3 inteligencias
                    let topIntelligences = [
                        ("Lógico-Matemática", 0.85, "Resolución de problemas y razonamiento"),
                        ("Interpersonal", 0.80, "Comprensión y colaboración con otros"),
                        ("Lingüística", 0.75, "Comunicación efectiva y expresión")
                    ]
                    
                    ForEach(Array(topIntelligences.enumerated()), id: \.offset) { index, intelligence in
                        intelligenceBar(
                            name: intelligence.0,
                            value: intelligence.1,
                            description: intelligence.2,
                            color: [accentColor, secondaryColor, .purple][index]
                        )
                    }
                    
                    Text("💡 Tu combinación de inteligencias es ideal para carreras STEM que requieren tanto rigor técnico como colaboración humana.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 10)
                        .italic()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.05))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: .purple.opacity(0.2), radius: 15)
        )
    }
    
    // MARK: - Personality Analysis View
    private var personalityAnalysisView: some View {
        VStack(spacing: 15) {
            Button(action: {
                withAnimation {
                    showPersonalityAnalysis.toggle()
                }
            }) {
                HStack {
                    sectionHeader(title: "Rasgos de Personalidad", icon: "person.fill.checkmark")
                    
                    Spacer()
                    
                    Image(systemName: showPersonalityAnalysis ? "chevron.up" : "chevron.down")
                        .foregroundColor(accentColor)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            
            if showPersonalityAnalysis {
                VStack(spacing: 12) {
                    // Rasgos principales
                    let topTraits = [
                        ("Creatividad", 0.90, "lightbulb.fill", "Generas soluciones innovadoras"),
                        ("Comunicación", 0.88, "bubble.left.fill", "Explicas ideas complejas claramente"),
                        ("Análisis", 0.85, "chart.bar.xaxis", "Procesas información sistemáticamente"),
                        ("Trabajo en Equipo", 0.82, "person.3.fill", "Colaboras efectivamente")
                    ]
                    
                    ForEach(Array(topTraits.enumerated()), id: \.offset) { index, trait in
                        HStack {
                            Image(systemName: trait.2)
                                .foregroundColor([.yellow, accentColor, .green, .orange][index])
                                .font(.system(size: 18))
                                .frame(width: 25)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(trait.0)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text(trait.3)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Text("\(Int(trait.1 * 100))%")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor([.yellow, accentColor, .green, .orange][index])
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.05))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: .green.opacity(0.2), radius: 15)
        )
    }
    
    // MARK: - Career Recommendations View
    private var careerRecommendationsView: some View {
        VStack(spacing: 15) {
            sectionHeader(title: "Carreras Recomendadas", icon: "graduationcap.fill")
            
            ForEach(DemoData.sampleAPIResponse.careerRecommendations, id: \.nombre) { career in
                careerCard(career)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: .blue.opacity(0.2), radius: 15)
        )
    }
    
    // MARK: - Action Buttons View
    private var actionButtonsView: some View {
        VStack(spacing: 15) {
            // Botón compartir
            Button(action: {
                // Share functionality
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Compartir mi análisis STEM")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple, Color.blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 5)
            }
            
            // Botón volver al inicio
            Button(action: {
                if let window = UIApplication.shared.windows.first {
                    window.rootViewController = UIHostingController(rootView: MainAppView())
                }
            }) {
                HStack {
                    Image(systemName: "house.fill")
                    Text("Explorar más carreras")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.green]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(accentColor)
                .font(.system(size: 22))
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    private func mbtiDimension(_ name: String, value: Double, description: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(value * 100))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(accentColor)
            }
            
            ProgressView(value: value)
                .progressViewStyle(LinearProgressViewStyle(tint: accentColor))
                .frame(height: 8)
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 5)
    }
    
    private func intelligenceBar(name: String, value: Double, description: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(value * 100))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
            
            ProgressView(value: value)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .frame(height: 8)
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 5)
    }
    
    private func careerCard(_ career: APICareerRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(career.nombre)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "building.2.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                        
                        Text(career.universidad)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                        
                        Text(career.ciudad)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack {
                    Text("\(Int(career.matchScore * 100))%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("Match")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                }
            }
            
            if let analysis = career.careerAnalysis {
                Text(analysis.whyRecommended)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(3)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func fieldDetailsModal(_ field: EngineeringField) -> some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    showFieldDetails = false
                }
            
            VStack(spacing: 25) {
                // Botón cerrar
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showFieldDetails = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                // Ícono del campo
                ZStack {
                    Circle()
                        .fill(field.color.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: field.icon)
                        .font(.system(size: 60))
                        .foregroundColor(field.color)
                }
                
                // Información del campo
                VStack(spacing: 15) {
                    Text(field.rawValue)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Afinidad: \(Int(DemoData.normalizedScore(for: field) * 100))%")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(field.color)
                    
                    Text(field.description)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ejemplos del mundo real:")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(field.realWorldExample)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(3)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(field.color.opacity(0.5), lineWidth: 2)
                    )
            )
            .padding()
        }
    }
    
    // MARK: - Animation Methods
    
    private func startAnimations() {
        // Animación de fondo
        withAnimation(.easeInOut(duration: 1.5)) {
            animateBackground = true
        }
        
        // Animación de título
        withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
            animateTitle = true
        }
        
        // Animación de estrellas
        withAnimation(.easeInOut(duration: 2.0).delay(1.0)) {
            isAnimating = true
        }
        
        // Animación de tarjetas
        withAnimation(.easeInOut(duration: 1.5).delay(1.5)) {
            animateCards = true
        }
    }
}

// MARK: - Star View
struct StarView: View {
    let field: EngineeringField
    let size: CGFloat
    let score: Double
    let position: StarPosition
    let isAnimating: Bool
    
    enum StarPosition {
        case center
        case orbit(angle: Double, distance: Double)
    }
    
    var body: some View {
        ZStack {
            // Efecto de brillo
            Circle()
                .fill(field.color.opacity(0.6))
                .frame(width: size * 1.8, height: size * 1.8)
                .blur(radius: 20)
            
            // Anillo orbital
            Circle()
                .stroke(field.color.opacity(0.3), lineWidth: 2)
                .frame(width: size * 1.4, height: size * 1.4)
            
            // Estrella principal
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            field.color,
                            field.color.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: size/2
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(field.color.lighter(), lineWidth: 1)
                )
            
            // Ícono del campo
            Image(systemName: field.icon)
                .font(.system(size: size / 2.5, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2)
            
            // Indicador de puntuación
            if score < 1.0 {
                Text("\(Int(score * 100))%")
                    .font(.system(size: size / 6, weight: .bold))
                    .foregroundColor(.white)
                    .offset(y: size / 2.5)
                    .shadow(color: .black.opacity(0.7), radius: 1)
            }
        }
        .scaleEffect(isAnimating ? 1.0 : 0.1)
        .opacity(isAnimating ? 1.0 : 0.0)
        .rotationEffect(.degrees(isAnimating ? 360 : 0))
        .position(position: position)
        .animation(.spring(response: 1.5, dampingFraction: 0.6).delay(Double.random(in: 0...1)), value: isAnimating)
    }
}

// MARK: - Extensions
extension View {
    func position(position: StarView.StarPosition) -> some View {
        switch position {
        case .center:
            return self.position(x: UIScreen.main.bounds.width / 2, y: 200)
        case .orbit(let angle, let distance):
            let radians = angle * .pi / 180
            let x = UIScreen.main.bounds.width / 2 + cos(radians) * distance
            let y = 200 + sin(radians) * distance
            return self.position(x: x, y: y)
        }
    }
}

#Preview {
    GalaxyResultsView(viewModel: VocationalTestViewModel())
}
