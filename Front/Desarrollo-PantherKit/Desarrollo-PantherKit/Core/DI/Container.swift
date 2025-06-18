//
//  Container.swift
//  NeuraPath
//
//  Simplified for Frontend-Only Architecture
//

import Foundation

/// Dependency Injection Container
/// Simplified for UI-only dependencies
final class DIContainer {
    static let shared = DIContainer()
    
    private init() {}
    
    // MARK: - Services (Backend Communication)
    
    /// API Service for backend communication
    lazy var apiService: APIService = {
        return APIService()
    }()
    
    // MARK: - Public Factory Methods
    
    /// Creates a simplified ViewModel for UI state management
    @MainActor
    func makeVocationalTestViewModel() -> VocationalTestViewModel {
        return VocationalTestViewModel(apiService: apiService)
    }
}

// MARK: - Simple API Service
/// Basic service for backend communication
final class APIService {
    private let baseURL = "https://vocacional-backend-727426062196.us-central1.run.app"
    
    /// Send test responses to backend and get analysis
    func submitTestResponses(_ responses: [String: Any]) async throws -> APIResponse {
        guard let url = URL(string: "\(baseURL)/guardar_resultado") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: responses, options: [])
        } catch {
            throw APIError.encodingFailed(error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        do {
            return try JSONDecoder().decode(APIResponse.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}

// MARK: - API Errors
enum APIError: LocalizedError {
    case invalidURL
    case encodingFailed(Error)
    case requestFailed
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .encodingFailed(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .requestFailed:
            return "API request failed"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
} 