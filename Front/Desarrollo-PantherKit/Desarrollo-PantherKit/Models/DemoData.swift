//
//  DemoData.swift
//  NeuraPath - Demo Data for Complete Frontend Experience
//

import Foundation
import SwiftUI

/// Datos de demostración para la aplicación
struct DemoData {
    
    // MARK: - Demo API Response
    static let sampleAPIResponse = APIResponse(
        status: "success",
        message: "Análisis completado exitosamente",
        responseId: 12345,
        llmResultId: 67890,
        llmProvider: "OpenAI GPT-4",
        mbtiProfile: MBTIProfile(
            code: "ENFP",
            weights: MBTIWeights(
                ei: 0.75,  // Extrovertido
                sn: 0.80,  // Intuitivo
                tf: 0.65,  // Sentimiento
                jp: 0.70   // Percepción
            ),
            vector: [1, 1, 0, 1] // E, N, F, P
        ),
        miScores: MIScores(
            linguistic: 0.75,
            logicalMath: 0.85,     // ✅ Corregido: logicalMath en lugar de logicalMathematical
            spatial: 0.70,
            bodilyKinesthetic: 0.60,
            musical: 0.55,
            interpersonal: 0.80,
            intrapersonal: 0.70,
            naturalist: 0.65       // ✅ Corregido: naturalist en lugar de naturalistic
        ),
        miRanking: [
            "Lógico-Matemática",
            "Interpersonal", 
            "Lingüística",
            "Espacial",
            "Intrapersonal",
            "Naturalista",
            "Corporal-Kinestésica",
            "Musical"
        ],
        careerRecommendations: [
            APICareerRecommendation(
                nombre: "Ingeniería en Inteligencia Artificial",
                universidad: "Universidad Tecnológica Nacional",
                ciudad: "Ciudad de México",
                matchScore: 0.92,
                careerAnalysis: CareerAnalysis(
                    personalityFit: "Tu perfil ENFP se alinea perfectamente con la IA. Tu creatividad e intuición son ideales para desarrollar soluciones innovadoras.",
                    intelligencesFit: "Tu alta inteligencia lógico-matemática (85%) y espacial (70%) son fundamentales para algoritmos y visualización de datos.",
                    skillsToFocus: [
                        "Programación en Python y TensorFlow",
                        "Matemáticas aplicadas y estadística",
                        "Machine Learning y Deep Learning",
                        "Ética en IA y responsabilidad social"
                    ],
                    whyRecommended: "La IA combina tu amor por la innovación con tu capacidad analítica, permitiéndote crear tecnología que mejore la vida de las personas."
                )
            ),
            APICareerRecommendation(
                nombre: "Ingeniería Biomédica",
                universidad: "Instituto Politécnico Nacional",
                ciudad: "Guadalajara",
                matchScore: 0.88,
                careerAnalysis: CareerAnalysis(
                    personalityFit: "Tu empatía natural y deseo de ayudar a otros se complementa perfectamente con la tecnología médica.",
                    intelligencesFit: "Tu combinación de inteligencias lógica (85%) e interpersonal (80%) es ideal para crear soluciones médicas centradas en el paciente.",
                    skillsToFocus: [
                        "Biología y fisiología humana",
                        "Diseño de dispositivos médicos",
                        "Programación de sistemas de salud",
                        "Regulaciones médicas y bioética"
                    ],
                    whyRecommended: "Puedes combinar tu pasión por la tecnología con tu deseo de impactar positivamente en la salud humana."
                )
            )
        ],
        careerAnalysis: "### Análisis Personalizado para Perfil ENFP\n\nTu perfil ENFP se caracteriza por creatividad, empatía y capacidad analítica. Las carreras STEM recomendadas aprovechan estas fortalezas únicas.",
        detailedAnalysis: DetailedAnalysis(
            personalitySummary: "Eres un innovador nato con gran capacidad para conectar ideas y personas. Tu energía y optimismo son contagiosos.",
            intelligencesSummary: "Tu perfil de inteligencias múltiples revela equilibrio entre capacidades analíticas y sociales, perfecto para carreras STEM colaborativas.",
            recommendationRationale: "Las carreras recomendadas aprovechan tu combinación de creatividad, empatía y capacidad analítica para crear tecnología con propósito.",
            suggestedSkills: [
                "Programación en Python y JavaScript",
                "Machine Learning y Data Science", 
                "Diseño UX/UI centrado en usuario",
                "Metodologías ágiles y Design Thinking",
                "Comunicación técnica y storytelling",
                "Liderazgo de equipos técnicos"
            ],
            opportunities: [
                "Liderar innovación en startups tecnológicas",
                "Desarrollar IA para impacto social positivo",
                "Crear soluciones de salud digital",
                "Trabajar en sostenibilidad y tech verde"
            ],
            challenges: [
                "Mantener enfoque en proyectos de largo plazo",
                "Desarrollar paciencia para debugging complejo",
                "Balancear idealismo con limitaciones técnicas",
                "Gestionar múltiples intereses simultáneamente"
            ]
        )
    )
    
    // MARK: - Demo Engineering Fields
    static let demoFields: [EngineeringField] = [
        .computerScience,
        .biomedical,
        .mechatronics,
        .industrial,
        .environmental
    ]
    
    static let demoFieldScores: [EngineeringField: Double] = [
        .computerScience: 0.92,
        .biomedical: 0.88,
        .mechatronics: 0.75,
        .industrial: 0.68,
        .environmental: 0.82
    ]
    
    // MARK: - Demo Personality Traits
    static let demoTraitScores: [PersonalityTrait: Double] = [
        .creative: 0.90,
        .analytical: 0.85,
        .communicator: 0.88,
        .teamPlayer: 0.82,
        .problemSolver: 0.86,
        .detailOriented: 0.70,
        .practical: 0.75,
        .bigPictureThinker: 0.92
    ]
    
    // MARK: - Helper Methods
    static func normalizedScore(for field: EngineeringField) -> Double {
        return demoFieldScores[field] ?? 0.5
    }
    
    static var primaryField: EngineeringField {
        return demoFieldScores.max(by: { $0.value < $1.value })?.key ?? .computerScience
    }
    
    static var topFields: [EngineeringField] {
        return demoFieldScores.sorted(by: { $0.value > $1.value }).map { $0.key }
    }
    
    static var primaryTrait: PersonalityTrait {
        return demoTraitScores.max(by: { $0.value < $1.value })?.key ?? .creative
    }
    
    static var secondaryTrait: PersonalityTrait {
        let sorted = demoTraitScores.sorted(by: { $0.value > $1.value })
        return sorted.count > 1 ? sorted[1].key : .analytical
    }
} 