//
//  StemChallenge.swift
//  Desarrollo-PantherKit
//
//  Created on 5/13/25.
//

import SwiftUI

// MARK: - Challenge Types
enum ChallengeType: String, Identifiable, CaseIterable {
    case logicMath = "Lógico-Matemático"
    case selfRegulation = "Autorregulación"
    case spatial = "Espacial"
    case infoSearch = "Búsqueda de Información"
    case linguistic = "Lingüística"
    case anxiety = "Control de Ansiedad"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .logicMath: return "number.square.fill"
        case .selfRegulation: return "clock.fill"
        case .spatial: return "map.fill"
        case .infoSearch: return "magnifyingglass.circle.fill"
        case .linguistic: return "text.bubble.fill"
        case .anxiety: return "heart.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .logicMath: return .blue
        case .selfRegulation: return .purple
        case .spatial: return .orange
        case .infoSearch: return .green
        case .linguistic: return .red
        case .anxiety: return .pink
        }
    }
    
    var description: String {
        switch self {
        case .logicMath: return "Calibra un sensor numérico ordenando la secuencia correctamente."
        case .selfRegulation: return "Organiza un mini-experimento arrastrando las tareas en el orden correcto."
        case .spatial: return "Traza la ruta óptima para un dron en Marte."
        case .infoSearch: return "Tu robot falla... ¿dónde buscarías ayuda?"
        case .linguistic: return "Crea un slogan impactante para promover la energía solar."
        case .anxiety: return "El temporizador está a punto de llegar a cero. ¿Qué haces?"
        }
    }
    
    var isMI: Bool {
        switch self {
        case .logicMath, .spatial, .linguistic:
            return true
        case .selfRegulation, .infoSearch, .anxiety:
            return false
        }
    }
    
    var category: String {
        return isMI ? "Inteligencia Múltiple" : "Autorregulación"
    }
}

// MARK: - Challenge Models
struct StemChallenge: Identifiable {
    let id = UUID()
    let type: ChallengeType
    let title: String
    let description: String
    let timeLimit: Double
    var options: [ChallengeOption]
}

struct ChallengeOption: Identifiable {
    let id = UUID()
    let text: String
    let isCorrect: Bool
    let trait: PersonalityTrait
}
