import Foundation
import SwiftUI

// MARK: - Models

/// Modelo para las respuestas de usuario
struct UserResponse: Codable {
    let pregunta: String
    let respuesta: String
}

/// Servicio para gestionar las respuestas
class ResponseService {
    // Singleton
    static let shared = ResponseService()
    
    // UserDefaults keys
    private let responsesKey = "userTestResponses"
    private let apiResponseKey = "apiResponseData"
    
    // URL del endpoint
    private let apiURL = "http://192.168.0.11:8000/api/questions/process-complete"
    
    // Inicializador privado para singleton
    private init() {}
    
    // MARK: - Métodos para guardar respuestas
    
    /// Guarda las respuestas del test de personalidad (DeckViewWrapper)
    func saveDeckViewResponses(viewModel: VocationalTestViewModel) {
        // Determinar respuestas basadas en los traits
        let traitScores = viewModel.testResult?.traitScores ?? [:]
        
        // E vs I: communicator vs detailOriented
        let isMoreExtroverted = (traitScores[.communicator] ?? 0.0) > (traitScores[.detailOriented] ?? 0.0)
        let extroversionAnswer = isMoreExtroverted ? "Al convivir con otros" : "Estando solo"
        
        // S vs N: practical vs creative
        let isMoreSensing = (traitScores[.practical] ?? 0.0) > (traitScores[.creative] ?? 0.0)
        let sensingAnswer = isMoreSensing ? "En los hechos concretos" : "Ideas abstractas"
        
        // T vs F: analytical vs teamPlayer
        let isMoreThinking = (traitScores[.analytical] ?? 0.0) > (traitScores[.teamPlayer] ?? 0.0)
        let thinkingAnswer = isMoreThinking ? "Con lógica" : "Emociones"
        
        // J vs P: problemSolver vs bigPictureThinker
        let isMoreJudging = (traitScores[.problemSolver] ?? 0.0) > (traitScores[.bigPictureThinker] ?? 0.0)
        let judgingAnswer = isMoreJudging ? "Tener todo planeado" : "Decidir sobre la marcha"
        
        // Crear respuestas MBTI
        let mbtiResponses: [UserResponse] = [
            UserResponse(
                pregunta: "¿Te recargas de energía estando solo o al convivir con otros?",
                respuesta: extroversionAnswer
            ),
            UserResponse(
                pregunta: "¿Te enfocas más en los hechos concretos o en ideas abstractas?",
                respuesta: sensingAnswer
            ),
            UserResponse(
                pregunta: "¿Tomas decisiones más con lógica o con tus emociones?",
                respuesta: thinkingAnswer
            ),
            UserResponse(
                pregunta: "¿Prefieres tener todo planeado o decidir sobre la marcha?",
                respuesta: judgingAnswer
            )
        ]
        
        // Obtener respuestas guardadas
        var allResponses = getAllResponses()
        
        // Añadir o actualizar respuestas MBTI
        for response in mbtiResponses {
            if let index = allResponses.firstIndex(where: { $0.pregunta == response.pregunta }) {
                allResponses[index] = response
            } else {
                allResponses.append(response)
            }
        }
        
        // Guardar todas las respuestas
        saveResponses(allResponses)
    }
    
    /// Guarda las respuestas del test de inteligencias múltiples (QuickDecisionView)
    func saveQuickDecisionResponses(viewModel: VocationalTestViewModel) {
        // Mapear inteligencias a sus preguntas correspondientes
        let fieldMapping: [EngineeringField: String] = [
            .computerScience: "¿Te gusta más escribir una historia o contarla en voz alta?",
            .mechanical: "¿Disfrutas resolver acertijos más que leer cuentos?",
            .electrical: "¿Se te da bien imaginar objetos en 3D o mapas mentales?",
            .mechatronics: "¿Aprendes mejor haciendo cosas con tus manos?",
            .biomedical: "¿Te concentras mejor con música o en completo silencio?",
            .industrial: "¿Disfrutas resolver problemas en grupo?",
            .robotics: "¿Te conoces bien y reflexionas antes de actuar?",
            .environmental: "¿Te gusta observar la naturaleza o entender cómo funcionan los ecosistemas?"
        ]
        
        // Mapear respuestas basado en puntuaciones de campos
        var responses: [UserResponse] = []
        
        // Verificar que tengamos resultados del test
        guard let fieldScores = viewModel.testResult?.fieldScores else {
            return
        }
        
        // Procesar cada campo por separado
        for (field, question) in fieldMapping {
            // Obtener puntuación con valor por defecto explícito
            let fieldScore: Double = fieldScores[field] ?? 0.0
            
            // Determinar respuesta basada en puntuación
            let answer: String
            
            // Usar switch con casos simples
            switch field {
            case .computerScience:
                answer = (fieldScore > 0.5) ? "Escribir" : "Contarla en voz alta"
            case .mechanical:
                answer = (fieldScore > 0.5) ? "Acertijos" : "Leer cuentos"
            case .electrical:
                answer = (fieldScore > 0.5) ? "Sí" : "No"
            case .mechatronics:
                answer = (fieldScore > 0.5) ? "Sí" : "No"
            case .biomedical:
                answer = (fieldScore > 0.5) ? "Con música" : "En silencio"
            case .industrial:
                answer = (fieldScore > 0.5) ? "Sí" : "No"
            case .robotics:
                answer = (fieldScore > 0.5) ? "Sí" : "No"
            case .environmental:
                answer = (fieldScore > 0.5) ? "Ambas" : "Solo observar"
            default:
                answer = "Sí" // Caso por defecto para futuros campos
            }
            
            // Crear y añadir la respuesta
            let userResponse = UserResponse(pregunta: question, respuesta: answer)
            responses.append(userResponse)
        }
        
        // Obtener respuestas guardadas
        var allResponses = getAllResponses()
        
        // Añadir o actualizar respuestas
        for response in responses {
            if let index = allResponses.firstIndex(where: { $0.pregunta == response.pregunta }) {
                allResponses[index] = response
            } else {
                allResponses.append(response)
            }
        }
        
        // Guardar todas las respuestas
        saveResponses(allResponses)
    }
    
    // MARK: - Métodos para acceder a respuestas
    
    /// Obtiene todas las respuestas guardadas
    func getAllResponses() -> [UserResponse] {
        guard let data = UserDefaults.standard.data(forKey: responsesKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([UserResponse].self, from: data)
        } catch {
            print("Error decodificando respuestas: \(error)")
            return []
        }
    }
    
    /// Guarda un array de respuestas
    private func saveResponses(_ responses: [UserResponse]) {
        do {
            let data = try JSONEncoder().encode(responses)
            UserDefaults.standard.set(data, forKey: responsesKey)
        } catch {
            print("Error guardando respuestas: \(error)")
        }
    }
    
    // MARK: - Envío de respuestas a la API
    
    /// Envía las respuestas a la API y notifica con el resultado
    func sendResponsesToAPI(completion: @escaping (Result<String, Error>) -> Void) {
        let responses = getAllResponses()
        
        guard !responses.isEmpty else {
            completion(.failure(NSError(
                domain: "ResponseService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No hay respuestas para enviar"]
            )))
            return
        }
        
        // Crear URL
        guard let url = URL(string: apiURL) else {
            completion(.failure(NSError(
                domain: "ResponseService",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "URL inválida"]
            )))
            return
        }
        
        print("Enviando directamente a URL: \(apiURL)")
        
        // Crear request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Codificar datos
        do {
            let jsonData = try JSONEncoder().encode(responses)
            request.httpBody = jsonData
            
            // Para debugging
            print("Datos: \(String(data: jsonData, encoding: .utf8) ?? "")")
            
            // Realizar solicitud
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                // Verificar si hay error
                if let error = error {
                    print("Error de red: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                // Verificar respuesta HTTP
                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(
                            domain: "ResponseService",
                            code: 3,
                            userInfo: [NSLocalizedDescriptionKey: "Respuesta inválida sin código HTTP"]
                        )))
                    }
                    return
                }
                
                print("Código de respuesta: \(httpResponse.statusCode)")
                
                // Verificar código de estado
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    // Verificar datos en la respuesta
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("Respuesta del backend: \(responseBody)")
                        
                        // Guardar respuesta para uso posterior
                        UserDefaults.standard.set(data, forKey: self.apiResponseKey)
                        
                        DispatchQueue.main.async {
                            completion(.success(responseBody))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.success("Respuesta vacía"))
                        }
                    }
                } else {
                    var errorMessage = "Error del servidor: \(httpResponse.statusCode)"
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        errorMessage += " - \(responseBody)"
                        print("Respuesta del backend: \(responseBody)")
                    }
                    
                    DispatchQueue.main.async {
                        completion(.failure(NSError(
                            domain: "ResponseService",
                            code: httpResponse.statusCode,
                            userInfo: [NSLocalizedDescriptionKey: errorMessage]
                        )))
                    }
                }
            }
            
            task.resume()
        } catch {
            print("Error codificando respuestas: \(error)")
            completion(.failure(error))
        }
    }
    
    /// Recupera la última respuesta de la API
    func getLastAPIResponse() -> Data? {
        return UserDefaults.standard.data(forKey: apiResponseKey)
    }
    
    /// Limpia todas las respuestas guardadas
    func clearResponses() {
        UserDefaults.standard.removeObject(forKey: responsesKey)
    }
} 