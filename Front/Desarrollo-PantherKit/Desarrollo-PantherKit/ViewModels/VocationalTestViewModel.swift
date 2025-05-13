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
    // Published properties that the views can observe
    @Published var missions: [Mission] = []
    @Published var currentMissionIndex: Int = 0
    @Published var selectedAvatar: Avatar?
    @Published var testCompleted: Bool = false
    @Published var testResult: TestResult?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Tracking user choices
    @Published var userChoices: [UUID: MissionOption] = [:]
    
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
    
    // Cancellables set to store subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMissions()
    }
    
    // MARK: - Data Loading
    
    func loadMissions() {
        isLoading = true
        errorMessage = nil
        
        // In a real app, you might load from an API or database
        // For now, we'll use sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.missions = Mission.sampleMissions
            self.isLoading = false
            
            // Shuffle missions to make each test experience unique
            self.missions.shuffle()
            
            // Limit to 5 missions for a quick test
            if self.missions.count > 5 {
                self.missions = Array(self.missions.prefix(5))
            }
        }
    }
    
    // MARK: - Navigation
    
    func nextMission() {
        guard currentMissionIndex < missions.count - 1 else {
            // This is the last mission, complete the test
            completeTest()
            return
        }
        
        currentMissionIndex += 1
    }
    
    func previousMission() {
        guard currentMissionIndex > 0 else { return }
        currentMissionIndex -= 1
    }
    
    // MARK: - User Choices
    
    func selectOption(_ option: MissionOption, for mission: Mission) {
        userChoices[mission.id] = option
        
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func isOptionSelected(_ option: MissionOption, for mission: Mission) -> Bool {
        return userChoices[mission.id]?.id == option.id
    }
    
    // MARK: - Test Completion
    
    func completeTest() {
        guard let avatar = selectedAvatar else {
            errorMessage = "Please select an avatar before completing the test"
            return
        }
        
        // Calculate field scores
        var fieldScores: [EngineeringField: Double] = [:]
        var traitScores: [PersonalityTrait: Double] = [:]
        
        // Initialize scores for all fields and traits
        for field in EngineeringField.allCases {
            fieldScores[field] = 0.0
        }
        
        for trait in PersonalityTrait.allCases {
            traitScores[trait] = 0.0
        }
        
        // Calculate scores based on user choices
        for (missionID, option) in userChoices {
            // Find the corresponding mission
            guard let mission = missions.first(where: { $0.id == missionID }) else { continue }
            
            // Add weights for each field
            for (fieldName, weight) in option.fieldWeights {
                if let field = EngineeringField.allCases.first(where: { $0.rawValue == fieldName }) {
                    fieldScores[field, default: 0.0] += weight
                }
            }
            
            // Add scores for traits
            for trait in option.traits {
                traitScores[trait, default: 0.0] += 1.0
            }
        }
        
        // Normalize scores
        let maxFieldScore = fieldScores.values.max() ?? 1.0
        let maxTraitScore = traitScores.values.max() ?? 1.0
        
        for field in fieldScores.keys {
            fieldScores[field] = (fieldScores[field] ?? 0.0) / maxFieldScore
        }
        
        for trait in traitScores.keys {
            traitScores[trait] = (traitScores[trait] ?? 0.0) / maxTraitScore
        }
        
        // Create test result
        testResult = TestResult(
            avatar: avatar,
            fieldScores: fieldScores,
            traitScores: traitScores
        )
        
        // Send anonymous data for analysis
        sendAnonymousData()
        
        // Mark test as completed
        testCompleted = true
    }
    
    // MARK: - Data Analysis
    
    private func sendAnonymousData() {
        guard let result = testResult else { return }
        
        // In a real app, you would send this data to your Hadoop cluster
        let anonymousData = result.anonymousData()
        
        // For now, we'll just print it to the console
        print("Anonymous data for analysis: \(anonymousData)")
        
        // In a real implementation, you would use URLSession or a networking library
        // to send this data to your backend
    }
    
    // MARK: - Reset Test
    
    func resetTest() {
        currentMissionIndex = 0
        userChoices.removeAll()
        testCompleted = false
        testResult = nil
        selectedAvatar = nil
        
        // Reload missions to get a fresh set
        loadMissions()
    }
    
    // MARK: - Career Swipe View
    
    func updateFieldScore(_ field: EngineeringField, by value: Double) {
        // Initialize test result if it doesn't exist
        if testResult == nil {
            // Create a default avatar if none selected
            let defaultAvatar = selectedAvatar ?? Avatar.allAvatars.first!
            
            // Initialize empty field scores
            var fieldScores: [EngineeringField: Double] = [:]
            for field in EngineeringField.allCases {
                fieldScores[field] = 0.0
            }
            
            // Initialize empty trait scores
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
        
        // Update the score for the specified field
        if var fieldScores = testResult?.fieldScores {
            fieldScores[field, default: 0.0] += value
            testResult?.fieldScores = fieldScores
        }
    }
    
    // Add updateTraitScore method
    func updateTraitScore(_ trait: PersonalityTrait, by value: Double) {
        // Initialize test result if it doesn't exist
        if testResult == nil {
            // Create a default avatar if none selected
            let defaultAvatar = selectedAvatar ?? Avatar.allAvatars.first!
            
            // Initialize empty field scores
            var fieldScores: [EngineeringField: Double] = [:]
            for field in EngineeringField.allCases {
                fieldScores[field] = 0.0
            }
            
            // Initialize empty trait scores
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
        
        // Update the score for the specified trait
        if var traitScores = testResult?.traitScores {
            traitScores[trait, default: 0.0] += value
            testResult?.traitScores = traitScores
        }
    }
    
    // MARK: - Galaxy Results View Helpers
    
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
    
    // MARK: - Feedback Generation
    
    func generateFeedback() -> String {
        guard let result = testResult else { return "Complete the test to see your results!" }
        
        let primaryField = result.primaryField
        let secondaryField = result.secondaryField
        let primaryTrait = result.primaryTrait
        
        var feedback = "Based on your choices, you might enjoy exploring \(primaryField.rawValue)!\n\n"
        
        feedback += "You seem to be \(primaryTrait.description.lowercased()). "
        feedback += "Your interests align well with \(primaryField.rawValue), which \(primaryField.description.lowercased())\n\n"
        
        feedback += "You might also enjoy \(secondaryField.rawValue), especially if you're interested in \(secondaryField.realWorldExample).\n\n"
        
        feedback += "Engineers in these fields work on exciting projects like:\n"
        feedback += "• \(primaryField.realWorldExample)\n"
        feedback += "• \(secondaryField.realWorldExample)"
        
        return feedback
    }
}
