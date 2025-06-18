//
//  ResponseService.swift
//  Desarrollo-PantherKit - Simplified for Frontend-Only
//

import Foundation
import SwiftUI

/// Servicio simplificado para recolectar respuestas UI solamente
/// Todo el procesamiento se hace en el backend
class ResponseService: ObservableObject {
    static let shared = ResponseService()
    
    private let responsesKey = "UserTestResponses"
    private let apiResponseKey = "LastAPIResponse"
    
    private init() {}
    
    // MARK: - UI Response Collection Only
    
    /// Simplified - just collect user choices without processing
    @MainActor
    func saveDeckViewResponses(viewModel: VocationalTestViewModel) {
        // Simple mapping of user choices to questions format
        var responses: [UserResponse] = []
        
        // Convert userChoices to simple question-answer format
        for (missionId, selectedOption) in viewModel.userChoices {
            guard let mission = viewModel.missions.first(where: { $0.id == missionId }) else { continue }
            
            let response = UserResponse(
                pregunta: mission.title,
                respuesta: selectedOption.text
            )
            responses.append(response)
        }
        
        // Save responses
        var allResponses = getAllResponses()
        allResponses.append(contentsOf: responses)
        saveResponses(allResponses)
    }
    
    /// Simplified - just record the selection
    @MainActor
    func saveQuickDecisionResponses(viewModel: VocationalTestViewModel) {
        // For quick decision, we can add any additional selections here
        // Currently handled by the main ViewModel
        print("Quick decision responses saved (handled by main ViewModel)")
    }
    
    // MARK: - Simple Storage Methods
    
    /// Get all collected responses
    func getAllResponses() -> [UserResponse] {
        guard let data = UserDefaults.standard.data(forKey: responsesKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([UserResponse].self, from: data)
        } catch {
            print("Error decoding responses: \(error)")
            return []
        }
    }
    
    /// Save responses array
    private func saveResponses(_ responses: [UserResponse]) {
        do {
            let data = try JSONEncoder().encode(responses)
            UserDefaults.standard.set(data, forKey: responsesKey)
        } catch {
            print("Error saving responses: \(error)")
        }
    }
    
    /// Clear all stored responses
    func clearAllResponses() {
        UserDefaults.standard.removeObject(forKey: responsesKey)
        UserDefaults.standard.removeObject(forKey: apiResponseKey)
    }
    
    // MARK: - API Response Storage
    
    /// Save API response from backend
    func saveAPIResponse(_ response: APIResponse) {
        do {
            let data = try JSONEncoder().encode(response)
            UserDefaults.standard.set(data, forKey: apiResponseKey)
        } catch {
            print("Error saving API response: \(error)")
        }
    }
    
    /// Get last API response
    func getLastAPIResponse() -> Data? {
        return UserDefaults.standard.data(forKey: apiResponseKey)
    }
}

// MARK: - Legacy Support Structures
struct UserResponse: Codable {
    let pregunta: String
    let respuesta: String
}

// MARK: - Legacy Methods for Compatibility
extension ResponseService {
    /// Legacy method - now just logs
    func sendResponsesToAPI(completion: @escaping (Result<String, Error>) -> Void) {
        print("⚠️ Legacy API call - should use ViewModel.completeTest() instead")
        completion(.success("Use ViewModel.completeTest() for backend communication"))
    }
    
    /// Load API response for backward compatibility
    func loadAPIResponse() -> APIResponse? {
        guard let data = getLastAPIResponse() else {
            return nil
        }
        
        do {
            let response = try JSONDecoder().decode(APIResponse.self, from: data)
            return response
        } catch {
            print("Error decoding API response: \(error)")
            return nil
        }
    }
} 