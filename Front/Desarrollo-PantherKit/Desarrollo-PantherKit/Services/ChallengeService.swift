//
//  ChallengeService.swift
//  Desarrollo-PantherKit
//
//  Created on 5/13/25.
//

import Foundation

// MARK: - Challenge Service Protocol
protocol ChallengeServiceProtocol {
    func getAllChallenges() -> [StemChallenge]
}

// MARK: - Challenge Service Implementation
class ChallengeService: ChallengeServiceProtocol {
    func getAllChallenges() -> [StemChallenge] {
        return [
            // Challenge 1: Logic-Math (MI)
            StemChallenge(
                type: .logicMath,
                title: "Puzzle de Códigos",
                description: "Ordena la secuencia numérica para calibrar el sensor.",
                timeLimit: 15.0,
                options: [
                    ChallengeOption(text: "3, 6, 12, 24, 48", isCorrect: true, trait: .analytical),
                    ChallengeOption(text: "3, 9, 27, 81, 243", isCorrect: false, trait: .detailOriented),
                    ChallengeOption(text: "2, 4, 8, 16, 32", isCorrect: false, trait: .problemSolver)
                ]
            ),
            
            // Challenge 2: Self-Regulation (SRLAS)
            StemChallenge(
                type: .selfRegulation,
                title: "Gestión de Tiempo",
                description: "Organiza las tareas de un experimento en el orden correcto.",
                timeLimit: 15.0,
                options: [
                    ChallengeOption(text: "Planear → Recolectar → Ejecutar → Analizar", isCorrect: true, trait: .detailOriented),
                    ChallengeOption(text: "Ejecutar → Planear → Recolectar → Analizar", isCorrect: false, trait: .creative),
                    ChallengeOption(text: "Recolectar → Ejecutar → Analizar → Planear", isCorrect: false, trait: .bigPictureThinker)
                ]
            ),
            
            // Challenge 3: Spatial (MI)
            StemChallenge(
                type: .spatial,
                title: "Laberinto Espacial",
                description: "Traza la ruta óptima para el dron en Marte.",
                timeLimit: 15.0,
                options: [
                    ChallengeOption(text: "Ruta A: Diagonal a través de cráteres", isCorrect: true, trait: .problemSolver),
                    ChallengeOption(text: "Ruta B: Bordeando montañas", isCorrect: false, trait: .practical),
                    ChallengeOption(text: "Ruta C: Siguiendo el valle", isCorrect: false, trait: .detailOriented)
                ]
            ),
            
            // Challenge 4: Info Search (SRLAS)
            StemChallenge(
                type: .infoSearch,
                title: "Búsqueda Eureka",
                description: "Tu robot falla inesperadamente. ¿Dónde buscarías ayuda primero?",
                timeLimit: 10.0,
                options: [
                    ChallengeOption(text: "Foro de desarrolladores", isCorrect: true, trait: .teamPlayer),
                    ChallengeOption(text: "Video tutorial", isCorrect: false, trait: .practical),
                    ChallengeOption(text: "Manual técnico", isCorrect: false, trait: .analytical)
                ]
            ),
            
            // Challenge 5: Linguistic (MI)
            StemChallenge(
                type: .linguistic,
                title: "Campaña Viral",
                description: "Elige el mejor slogan para promover la energía solar.",
                timeLimit: 12.0,
                options: [
                    ChallengeOption(text: "Energía Solar: Potencia el Futuro, Protege el Presente", isCorrect: true, trait: .communicator),
                    ChallengeOption(text: "Sol = Energía Limpia y Renovable", isCorrect: false, trait: .analytical),
                    ChallengeOption(text: "Paneles Solares: Eficiencia Energética Garantizada", isCorrect: false, trait: .practical)
                ]
            ),
            
            // Challenge 6: Anxiety Control (SRLAS)
            StemChallenge(
                type: .anxiety,
                title: "Control de Ansiedad",
                description: "El temporizador está a punto de llegar a cero. ¿Qué haces?",
                timeLimit: 10.0,
                options: [
                    ChallengeOption(text: "Respiro, me enfoco y doy mi mejor esfuerzo", isCorrect: true, trait: .problemSolver),
                    ChallengeOption(text: "Me apresuro y completo lo que pueda", isCorrect: false, trait: .practical),
                    ChallengeOption(text: "Acepto que no alcanzaré y me preparo para el siguiente reto", isCorrect: false, trait: .bigPictureThinker)
                ]
            )
        ]
    }
}
