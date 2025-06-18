//
//  VocationalTestViewModel.swift
//  NeuraPath
//
//  Simplified for Frontend-Only Architecture
//

import Foundation
import SwiftUI
import Combine

/// Simplified ViewModel for UI state management only
/// All business logic moved to backend
@MainActor
final class VocationalTestViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI State Only)
    
    @Published var missions: [Mission] = []
    @Published var currentMissionIndex: Int = 0
    @Published var selectedAvatar: Avatar?
    @Published var testCompleted: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // User responses tracking (for backend submission)
    @Published var userChoices: [UUID: MissionOption] = [:]
    
    // Backend response
    @Published var apiResponse: APIResponse?
    
    // MARK: - Private Dependencies
    
    private let apiService: APIService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties (Simple UI Logic Only)
    
    var currentMission: Mission? {
        guard currentMissionIndex < missions.count else { return nil }
        return missions[currentMissionIndex]
    }
    
    var progress: Double {
        guard !missions.isEmpty else { return 0.0 }
        return Double(userChoices.count) / Double(missions.count)
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
    
    var canCompleteTest: Bool {
        return selectedAvatar != nil && userChoices.count >= missions.count
    }
    
    // MARK: - Initialization
    
    init(apiService: APIService) {
        self.apiService = apiService
        loadMissions()
    }
    
    /// Legacy init for backward compatibility
    convenience init() {
        self.init(apiService: DIContainer.shared.apiService)
    }
    
    // MARK: - Public Interface
    
    func loadMissions() {
        isLoading = true
        errorMessage = nil
        
        // Load missions from local data
        Task {
            do {
                // Simulate loading delay
                try await Task.sleep(nanoseconds: 500_000_000)
                
                await MainActor.run {
                    self.missions = Mission.sampleMissions
                    self.missions.shuffle()
                    
                    // Limit to 5 missions for quick test
                    if self.missions.count > 5 {
                        self.missions = Array(self.missions.prefix(5))
                    }
                    
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load missions: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func nextMission() {
        guard currentMissionIndex < missions.count - 1 else {
            return
        }
        currentMissionIndex += 1
    }
    
    func previousMission() {
        guard canGoBack else { return }
        currentMissionIndex -= 1
    }
    
    func selectOption(_ option: MissionOption, for mission: Mission) {
        userChoices[mission.id] = option
        
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func isOptionSelected(_ option: MissionOption, for mission: Mission) -> Bool {
        return userChoices[mission.id]?.id == option.id
    }
    
    func selectAvatar(_ avatar: Avatar) {
        selectedAvatar = avatar
    }
    
    /// Submit test to backend and get analysis
    func completeTest() {
        guard canCompleteTest else {
            errorMessage = "Please complete all questions and select an avatar"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Prepare payload for backend
                let payload = createBackendPayload()
                
                // Submit to backend
                let response = try await apiService.submitTestResponses(payload)
                
                await MainActor.run {
                    self.apiResponse = response
                    self.testCompleted = true
                    self.isLoading = false
                    
                    print("✅ Test completed successfully")
                    print("📊 Received \(response.careerRecommendations.count) career recommendations")
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to submit test: \(error.localizedDescription)"
                    self.isLoading = false
                    print("❌ Test submission failed: \(error)")
                }
            }
        }
    }
    
    func resetTest() {
        currentMissionIndex = 0
        userChoices.removeAll()
        testCompleted = false
        selectedAvatar = nil
        errorMessage = nil
        apiResponse = nil
        
        loadMissions()
    }
    
    // MARK: - Private Helpers
    
    /// Create payload for backend submission
    private func createBackendPayload() -> [String: Any] {
        var responses: [[String: Any]] = []
        
        // Convert user choices to backend format
        for (missionId, selectedOption) in userChoices {
            guard let mission = missions.first(where: { $0.id == missionId }) else { continue }
            
            let response: [String: Any] = [
                "mission_id": missionId.uuidString,
                "mission_title": mission.title,
                "selected_option_id": selectedOption.id.uuidString,
                "selected_option_text": selectedOption.text,
                "field_weights": selectedOption.fieldWeights,
                "personality_traits": selectedOption.traits.map { $0.rawValue }
            ]
            
            responses.append(response)
        }
        
        return [
            "usuario_id": UUID().uuidString,
            "avatar": [
                "id": selectedAvatar?.id.uuidString ?? "",
                "name": selectedAvatar?.name ?? "",
                "image": selectedAvatar?.imageName ?? ""
            ],
            "responses": responses,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
} 