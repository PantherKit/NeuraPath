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
    
    // Seguimiento de las elecciones del usuario
    @Published var userChoices: [UUID: MissionOption] = [:]
    
    // Propiedades calculadas
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
        
        var feedback = "¡Basado en tus elecciones, podrías disfrutar explorando \(primaryField.rawValue)!\n\n"
        
        feedback += "Pareces ser \(primaryTrait.description.lowercased()). "
        feedback += "Tus intereses se alinean bien con \(primaryField.rawValue), que \(primaryField.description.lowercased())\n\n"
        
        feedback += "También podrías disfrutar \(secondaryField.rawValue), especialmente si estás interesado en \(secondaryField.realWorldExample).\n\n"
        
        feedback += "Los ingenieros en estos campos trabajan en proyectos emocionantes como:\n"
        feedback += "• \(primaryField.realWorldExample)\n"
        feedback += "• \(secondaryField.realWorldExample)"
        
        return feedback
    }
}
