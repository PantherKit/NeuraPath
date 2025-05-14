//
//  VocationalTestViewModel.swift
//  Desarrollo-PantherKit
//
//  Created on 5/12/25.
//

import Foundation
import SwiftUI
import Combine

class VocationalTestViewModel: ObservableObject {
    // Propiedades publicadas que las vistas pueden observar
    @Published var missions: [Mission] = []
    @Published var currentMissionIndex: Int = 0
    @Published var selectedAvatar: Avatar?
    @Published var testCompleted: Bool = false
    @Published var testResult: TestResult?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var recommendedCareers: [UniversityCareer] = []
    @Published var showCareerCarousel: Bool = false
    
    // Seguimiento de las elecciones del usuario
    @Published var userChoices: [UUID: MissionOption] = [:]
    
    // Timer para actualizar el desplazamiento de carreras
    private var carouselTimer: Timer?
    
    // Computed properties
    var currentMission: Mission? {
        guard currentMissionIndex < missions.count else { return nil }
        return missions[currentMissionIndex]
    }
    
    var progress: Double {
        guard !missions.isEmpty else { return 0.0 }
        return Double(currentMissionIndex) / Double(missions.count)
    }
    
    var canGoNext: Bool {
        guard let currentMission = currentMission else { return false }
        return userChoices[currentMission.id] != nil
    }
    
    var canGoBack: Bool {
        return currentMissionIndex > 0
    }
    
    var isLastMission: Bool {
        return currentMissionIndex == missions.count - 1
    }
    
    // Conjunto de cancelables para almacenar suscripciones
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMissions()
    }
    
    // MARK: - Carga de datos
    
    func loadMissions() {
        isLoading = true
        errorMessage = nil
        
        // En una aplicación real, podrías cargar desde una API o base de datos
        // Por ahora, usaremos datos de muestra
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.missions = Mission.sampleMissions
            self.isLoading = false
            
            // Barajar misiones para hacer única cada experiencia de prueba
            self.missions.shuffle()
            
            // Limitar a 5 misiones para una prueba rápida
            if self.missions.count > 5 {
                self.missions = Array(self.missions.prefix(5))
            }
        }
    }
    
    // MARK: - Navegación
    
    func nextMission() {
        guard currentMissionIndex < missions.count - 1 else {
            // Esta es la última misión, completar la prueba
            completeTest()
            return
        }
        
        currentMissionIndex += 1
    }
    
    func previousMission() {
        guard currentMissionIndex > 0 else { return }
        currentMissionIndex -= 1
    }
    
    // MARK: - Elecciones del usuario
    
    func selectOption(_ option: MissionOption, for mission: Mission) {
        userChoices[mission.id] = option
        
        // Proporcionar retroalimentación háptica
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func isOptionSelected(_ option: MissionOption, for mission: Mission) -> Bool {
        return userChoices[mission.id]?.id == option.id
    }
    
    // MARK: - Finalización de la prueba
    
    func completeTest() {
        guard let avatar = selectedAvatar else {
            errorMessage = "Por favor selecciona un avatar antes de completar la prueba"
            return
        }
        
        // Calcular puntuaciones de campos
        var fieldScores: [EngineeringField: Double] = [:]
        var traitScores: [PersonalityTrait: Double] = [:]
        
        // Inicializar puntuaciones para todos los campos y rasgos
        for field in EngineeringField.allCases {
            fieldScores[field] = 0.0
        }
        
        for trait in PersonalityTrait.allCases {
            traitScores[trait] = 0.0
        }
        
        // Calcular puntuaciones basadas en las elecciones del usuario
        for (missionID, option) in userChoices {
            // Encontrar la misión correspondiente
            guard let mission = missions.first(where: { $0.id == missionID }) else { continue }
            
            // Agregar pesos para cada campo
            for (fieldName, weight) in option.fieldWeights {
                if let field = EngineeringField.allCases.first(where: { $0.rawValue == fieldName }) {
                    fieldScores[field, default: 0.0] += weight
                }
            }
            
            // Agregar puntuaciones para rasgos
            for trait in option.traits {
                traitScores[trait, default: 0.0] += 1.0
            }
        }
        
        // Normalizar puntuaciones
        let maxFieldScore = fieldScores.values.max() ?? 1.0
        let maxTraitScore = traitScores.values.max() ?? 1.0
        
        for field in fieldScores.keys {
            fieldScores[field] = (fieldScores[field] ?? 0.0) / maxFieldScore
        }
        
        for trait in traitScores.keys {
            traitScores[trait] = (traitScores[trait] ?? 0.0) / maxTraitScore
        }
        
        // Crear resultado de la prueba
        testResult = TestResult(
            avatar: avatar,
            fieldScores: fieldScores,
            traitScores: traitScores
        )
        
        // Enviar datos anónimos para análisis
        sendAnonymousData()
        
        // Marcar prueba como completada
        testCompleted = true

        // Guardar resultado de la prueba en archivo JSON para posterior POST
        saveTestResultToJSON()
    }
    
    // MARK: - Guardar JSON localmente
    private func saveTestResultToJSON() {
        guard let result = testResult else { return }
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(result)
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = directory.appendingPathComponent("testResult.json")
            try data.write(to: fileURL)
            print("Resultado de la prueba guardado en JSON en \(fileURL)")
        } catch {
            print("Error al guardar el resultado de la prueba en JSON: \(error)")
        }
    }
    
    // MARK: - Análisis de datos
    
    private func sendAnonymousData() {
        guard let result = testResult else { return }
        
        // En una aplicación real, enviarías estos datos a tu clúster de Hadoop
        let anonymousData = result.anonymousData()
        
        // Por ahora, solo lo imprimiremos en la consola
        print("Datos anónimos para análisis: \(anonymousData)")
        
        // En una implementación real, usarías URLSession o una biblioteca de red
        // para enviar estos datos a tu backend
    }
    
    // MARK: - Reiniciar prueba
    
    func resetTest() {
        currentMissionIndex = 0
        userChoices.removeAll()
        testCompleted = false
        testResult = nil
        selectedAvatar = nil
        recommendedCareers = []
        
        // Recargar misiones para obtener un nuevo conjunto
        loadMissions()
    }
    
    // MARK: - Vista de deslizamiento de carrera
    
    func updateFieldScore(_ field: EngineeringField, by value: Double) {
        // Inicializar resultado de la prueba si no existe
        if testResult == nil {
            // Crear un avatar predeterminado si no se selecciona ninguno
            let defaultAvatar = selectedAvatar ?? Avatar.allAvatars.first!
            
            // Inicializar puntuaciones de campos vacías
            var fieldScores: [EngineeringField: Double] = [:]
            for field in EngineeringField.allCases {
                fieldScores[field] = 0.0
            }
            
            // Inicializar puntuaciones de rasgos vacías
            var traitScores: [PersonalityTrait: Double] = [:]
            for trait in PersonalityTrait.allCases {
                traitScores[trait] = 0.0
            }
            
            testResult = TestResult(
                avatar: defaultAvatar,
                fieldScores: fieldScores,
                traitScores: traitScores
            )
        }
        
        // Actualizar la puntuación para el campo especificado
        if var fieldScores = testResult?.fieldScores {
            fieldScores[field, default: 0.0] += value
            testResult?.fieldScores = fieldScores
        }
    }
    
    // Agregar método updateTraitScore
    func updateTraitScore(_ trait: PersonalityTrait, by value: Double) {
        // Inicializar resultado de la prueba si no existe
        if testResult == nil {
            // Crear un avatar predeterminado si no se selecciona ninguno
            let defaultAvatar = selectedAvatar ?? Avatar.allAvatars.first!
            
            // Inicializar puntuaciones de campos vacías
            var fieldScores: [EngineeringField: Double] = [:]
            for field in EngineeringField.allCases {
                fieldScores[field] = 0.0
            }
            
            // Inicializar puntuaciones de rasgos vacías
            var traitScores: [PersonalityTrait: Double] = [:]
            for trait in PersonalityTrait.allCases {
                traitScores[trait] = 0.0
            }
            
            testResult = TestResult(
                avatar: defaultAvatar,
                fieldScores: fieldScores,
                traitScores: traitScores
            )
        }
        
        // Actualizar la puntuación para el rasgo especificado
        if var traitScores = testResult?.traitScores {
            traitScores[trait, default: 0.0] += value
            testResult?.traitScores = traitScores
        }
    }
    
    // MARK: - Ayudantes de vista de resultados de la galaxia
    
    var fieldScores: [EngineeringField: Double] {
        return testResult?.fieldScores ?? [:]
    }
    
    var primaryField: EngineeringField {
        return testResult?.primaryField ?? .mechatronics
    }
    
    var secondaryField: EngineeringField {
        return testResult?.secondaryField ?? .robotics
    }
    
    var primaryTrait: PersonalityTrait {
        return testResult?.primaryTrait ?? .problemSolver
    }
    
    var secondaryTrait: PersonalityTrait {
        return testResult?.secondaryTrait ?? .creative
    }
    
    var topFields: [EngineeringField] {
        return fieldScores.sorted { $0.value > $1.value }.map { $0.key }
    }
    
    func normalizedScore(for field: EngineeringField) -> Double {
        guard let maxScore = fieldScores.values.max(), maxScore > 0 else {
            return 0.0
        }
        return (fieldScores[field] ?? 0.0) / maxScore
    }
    
    // MARK: - Generación de retroalimentación
    
    func generateFeedback() -> String {
        guard let result = testResult else { return "¡Completa la prueba para ver tus resultados!" }
        
        let primaryField = result.primaryField
        let secondaryField = result.secondaryField
        let primaryTrait = result.primaryTrait
        let secondaryTrait = result.secondaryTrait
        
        // Porcentajes exactos para los campos principales
        let primaryScore = Int((result.fieldScores[primaryField] ?? 0.0) * 100)
        let secondaryScore = Int((result.fieldScores[secondaryField] ?? 0.0) * 100)
        
        // Construir un mensaje más personalizado basado en las respuestas reales
        var feedback = "Tu perfil muestra una afinidad del \(primaryScore)% con \(primaryField.rawValue). "
        
        // Mensaje inclusivo sobre diversas formas de inteligencia
        feedback += "En STEM son valoradas muchas formas de inteligencia, no solo la matemática. "
        feedback += "Tu combinación de \(primaryTrait.rawValue.lowercased()) y \(secondaryTrait.rawValue.lowercased()) es una fortaleza única que aporta diversidad a estos campos.\n\n"
        
        // Mencionar campo secundario con enfoque en complementariedad
        feedback += "También muestras un \(secondaryScore)% de compatibilidad con \(secondaryField.rawValue), lo que enriquece tu perfil con una perspectiva complementaria.\n\n"
        
        // Áreas de aplicación específicas según las respuestas, con enfoque en impacto social
        feedback += "Tus respuestas sugieren que podrías destacar en áreas como:\n"
        feedback += "• \(primaryField.realWorldExample)\n"
        feedback += "• Proyectos que conecten \(primaryField.rawValue) con áreas sociales y humanísticas\n"
        
        // Consejos específicos basados en rasgos con enfoque en múltiples inteligencias
        feedback += "\nPara desarrollar tu potencial independientemente de tu formación previa:\n"
        
        // Añadir consejos personalizados según el rasgo principal
        switch primaryTrait {
        case .analytical:
            feedback += "• Tu pensamiento estructurado es valioso en proyectos que requieren organización\n"
            feedback += "• No necesitas ser un experto en matemáticas, muchos problemas se resuelven con pensamiento lógico básico"
        case .creative:
            feedback += "• La innovación en STEM surge de personas creativas como tú\n"
            feedback += "• La visualización y diseño son tan importantes como las fórmulas matemáticas"
        case .teamPlayer:
            feedback += "• La colaboración efectiva es fundamental en los grandes proyectos STEM\n"
            feedback += "• Tu capacidad para coordinar equipos diversos es esencial para resolver problemas complejos"
        case .practical:
            feedback += "• El enfoque práctico que tienes permite implementar soluciones reales\n"
            feedback += "• No todo en ingeniería es teoría; la aplicación práctica es igualmente valiosa"
        case .detailOriented:
            feedback += "• Tu atención al detalle es crucial en áreas que requieren precisión\n"
            feedback += "• Esta habilidad te permite destacar en pruebas, documentación y control de calidad"
        case .bigPictureThinker:
            feedback += "• Tu visión global permite conectar disciplinas diferentes y encontrar soluciones innovadoras\n"
            feedback += "• Esta habilidad es esencial para liderar proyectos multidisciplinarios"
        case .problemSolver:
            feedback += "• Tu enfoque en soluciones te ayudará a superar las dificultades iniciales en cualquier área STEM\n"
            feedback += "• Las habilidades de resolución de problemas son transferibles entre disciplinas"
        case .communicator:
            feedback += "• La comunicación efectiva es una habilidad infravalorada pero crítica en STEM\n"
            feedback += "• Tu capacidad para explicar conceptos complejos es esencial para equipos y proyectos exitosos"
        }
        
        // Mensaje final inclusivo
        feedback += "\n\nRecuerda: las carreras STEM necesitan todo tipo de mentes y talentos. La diversidad de pensamiento impulsa la innovación."
        
        return feedback
    }
    
    // MARK: - Career Carousel Control
    
    func showCarouselFor(field: EngineeringField) {
        // Filter careers to show only those matching the selected field
        if let result = testResult {
            // Start with all recommended careers
            let allRecommendedCareers = UniversityCareer.getRecommendedCareers(from: result)
            
            // Filter by field
            let fieldCareers = allRecommendedCareers.filter { $0.field == field }
            
            // If no careers found for this specific field, show all recommended
            if fieldCareers.isEmpty {
                recommendedCareers = allRecommendedCareers
            } else {
                recommendedCareers = fieldCareers
            }
            
            // Show the carousel with animation
            withAnimation(.spring()) {
                showCareerCarousel = true
            }
            
            // Iniciar el temporizador para el desplazamiento continuo
            startCarouselAutoScroll()
        }
    }
    
    func hideCarousel() {
        // Hide the carousel with animation
        withAnimation(.spring()) {
            showCareerCarousel = false
        }
        
        // Detener el temporizador
        stopCarouselAutoScroll()
        
        // After hiding, restore all recommended careers with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self, let result = self.testResult else { return }
            self.recommendedCareers = UniversityCareer.getRecommendedCareers(from: result)
        }
    }
    
    // Iniciar desplazamiento automático del carrusel
    private func startCarouselAutoScroll() {
        // Detener cualquier temporizador existente
        stopCarouselAutoScroll()
        
        // Crear nuevo temporizador que se dispara cada 3 segundos
        carouselTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.recommendedCareers.isEmpty else { return }
            
            withAnimation(.easeInOut(duration: 1.0)) {
                // Rotar las carreras para crear efecto de desplazamiento hacia la derecha
                // (mover el último elemento al principio)
                if let lastCareer = self.recommendedCareers.last {
                    var updatedCareers = self.recommendedCareers
                    updatedCareers.removeLast()
                    updatedCareers.insert(lastCareer, at: 0)
                    self.recommendedCareers = updatedCareers
                }
            }
        }
    }
    
    // Detener desplazamiento automático
    private func stopCarouselAutoScroll() {
        carouselTimer?.invalidate()
        carouselTimer = nil
    }
    
    // Asegurar que el temporizador se detenga cuando el ViewModel sea liberado
    deinit {
        stopCarouselAutoScroll()
    }
}
