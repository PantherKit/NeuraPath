//
//  UniversityCareer.swift
//  Desarrollo-PantherKit
//
//  Created on 13/5/2025.
//

import SwiftUI

struct UniversityCareer: Identifiable {
    let id = UUID()
    let name: String
    let university: String
    let description: String
    let field: EngineeringField
    let duration: String
    let icon: String
    let color: Color
    
    // Computed property to get color from the field
    var fieldColor: Color {
        return field.color
    }
    
    // Static method to get recommended careers based on test results
    static func getRecommendedCareers(from result: TestResult) -> [UniversityCareer] {
        // Obtener todos los resultados de campos, ordenados por puntuación
        let fieldScoresSorted = result.fieldScores.sorted { $0.value > $1.value }
        
        // Mejorar la selección de carreras basada en puntuaciones ponderadas
        // Paso 1: Asignar una puntuación a cada carrera basada en su campo y los resultados del test
        var careerScores: [(career: UniversityCareer, score: Double)] = []
        
        for career in sampleCareers {
            // Encontrar la puntuación de este campo en los resultados
            var score = result.fieldScores[career.field] ?? 0.0
            
            // Aumentar la puntuación basada en similitudes con otros campos altos
            // (Por ejemplo, si una carrera es de computerScience pero el usuario
            // también puntúa alto en electrical, se aumenta la puntuación)
            for (field, fieldScore) in fieldScoresSorted.prefix(3) {
                if field != career.field {
                    // Verificar si hay afinidad entre los campos
                    let affinityBoost = fieldAffinity(between: career.field, and: field) * fieldScore * 0.3
                    score += affinityBoost
                }
            }
            
            // Considerar también los rasgos de personalidad
            let traitBoost = getTraitBoost(for: career.field, traits: result.traitScores) * 0.2
            score += traitBoost
            
            careerScores.append((career, score))
        }
        
        // Paso 2: Ordenar carreras por puntuación descendente
        let sortedCareers = careerScores.sorted { $0.score > $1.score }
        
        // Paso 3: Tomar las mejores carreras
        var recommendedCareers = sortedCareers.prefix(8).map { $0.career }
        
        // Paso 4: Si hay menos de 6 carreras, añadir más hasta tener al menos 6
        if recommendedCareers.count < 6 {
            let additionalCareers = sampleCareers.filter { career in
                !recommendedCareers.contains(where: { $0.id == career.id })
            }
            
            let neededCount = min(6 - recommendedCareers.count, additionalCareers.count)
            recommendedCareers.append(contentsOf: additionalCareers.prefix(neededCount))
        }
        
        // Paso 5: Duplicar algunas carreras para asegurar un desplazamiento continuo
        let originalCount = recommendedCareers.count
        for i in 0..<min(originalCount, 4) {
            recommendedCareers.append(recommendedCareers[i])
        }
        
        return recommendedCareers
    }
    
    // Helper function to determine affinity between fields
    private static func fieldAffinity(between field1: EngineeringField, and field2: EngineeringField) -> Double {
        let affinityPairs: [(EngineeringField, EngineeringField, Double)] = [
            (.computerScience, .electrical, 0.7),
            (.computerScience, .robotics, 0.6),
            (.mechanical, .mechatronics, 0.8),
            (.electrical, .mechatronics, 0.7),
            (.industrial, .mechanical, 0.5),
            (.biomedical, .environmental, 0.4),
            (.biomedical, .chemical, 0.6),
            (.robotics, .mechatronics, 0.8),
            (.environmental, .chemical, 0.6),
            (.electrical, .mechanical, 0.5)
        ]
        
        // Comprobar en ambas direcciones
        for (f1, f2, affinity) in affinityPairs {
            if (f1 == field1 && f2 == field2) || (f1 == field2 && f2 == field1) {
                return affinity
            }
        }
        
        return 0.1  // Default low affinity for unrelated fields
    }
    
    // Helper to boost career score based on personality traits
    private static func getTraitBoost(for field: EngineeringField, traits: [PersonalityTrait: Double]) -> Double {
        // Define which traits are particularly important for which fields
        let fieldTraitAffinities: [EngineeringField: [PersonalityTrait]] = [
            .computerScience: [.analytical, .problemSolver, .detailOriented],
            .electrical: [.analytical, .detailOriented, .practical],
            .mechanical: [.practical, .problemSolver, .analytical],
            .mechatronics: [.analytical, .creative, .problemSolver],
            .robotics: [.creative, .analytical, .problemSolver],
            .industrial: [.bigPictureThinker, .teamPlayer, .problemSolver],
            .biomedical: [.detailOriented, .analytical, .creative],
            .environmental: [.bigPictureThinker, .teamPlayer, .communicator],
            .chemical: [.detailOriented, .analytical, .practical],
            .civil: [.bigPictureThinker, .practical, .teamPlayer]
        ]
        
        var boost = 0.0
        
        // Add boost for each relevant trait
        if let relevantTraits = fieldTraitAffinities[field] {
            for trait in relevantTraits {
                if let traitScore = traits[trait] {
                    boost += traitScore * 0.2  // Scale the boost
                }
            }
        }
        
        return boost
    }
    
    // Sample careers for testing
    static var sampleCareers: [UniversityCareer] = [
        UniversityCareer(
            name: "Ingeniería Mecatrónica",
            university: "Universidad Panamericana",
            description: "Combina mecánica, electrónica, control y computación para diseñar sistemas robóticos avanzados.",
            field: .mechatronics,
            duration: "4.5 años",
            icon: "gearshape.2",
            color: .blue
        ),
        UniversityCareer(
            name: "Ingeniería en Robótica",
            university: "ITESM",
            description: "Especialización en diseño, programación y control de sistemas robóticos para aplicaciones industriales y de servicio.",
            field: .robotics,
            duration: "4 años",
            icon: "brain.head.profile",
            color: .purple
        ),
        UniversityCareer(
            name: "Ciencias de la Computación",
            university: "UNAM",
            description: "Enfocada en algoritmos, inteligencia artificial, desarrollo de software y sistemas computacionales.",
            field: .computerScience,
            duration: "4 años",
            icon: "desktopcomputer",
            color: .green
        ),
        UniversityCareer(
            name: "Ingeniería Eléctrica",
            university: "IPN",
            description: "Estudio de sistemas eléctricos, electrónica, telecomunicaciones y control automático.",
            field: .electrical,
            duration: "4.5 años",
            icon: "bolt",
            color: .yellow
        ),
        UniversityCareer(
            name: "Ingeniería Mecánica",
            university: "Universidad Iberoamericana",
            description: "Diseño y análisis de sistemas mecánicos, termodinámica, materiales y manufactura.",
            field: .mechanical,
            duration: "4 años",
            icon: "wrench.and.screwdriver",
            color: .orange
        ),
        UniversityCareer(
            name: "Ingeniería Industrial",
            university: "ITAM",
            description: "Optimización de procesos, logística, gestión de calidad y administración de operaciones.",
            field: .industrial,
            duration: "4 años",
            icon: "chart.bar.fill",
            color: .red
        ),
        UniversityCareer(
            name: "Ingeniería Biomédica",
            university: "UAM",
            description: "Aplicación de principios de ingeniería para resolver problemas médicos y biológicos.",
            field: .biomedical,
            duration: "4.5 años",
            icon: "heart.text.square",
            color: .pink
        ),
        UniversityCareer(
            name: "Ingeniería Ambiental",
            university: "Universidad Anáhuac",
            description: "Desarrollo de soluciones para problemas ambientales, gestión de recursos y energías renovables.",
            field: .environmental,
            duration: "4 años",
            icon: "leaf",
            color: .mint
        ),
        // Nuevas carreras
        UniversityCareer(
            name: "Ingeniería en IA",
            university: "ITESM",
            description: "Desarrollo de sistemas de inteligencia artificial, aprendizaje profundo y procesamiento del lenguaje natural.",
            field: .computerScience,
            duration: "4.5 años",
            icon: "brain",
            color: .cyan
        ),
        UniversityCareer(
            name: "Ingeniería Aeroespacial",
            university: "UNAM",
            description: "Diseño y desarrollo de aeronaves, satélites y sistemas de propulsión para aplicaciones espaciales.",
            field: .mechanical,
            duration: "5 años",
            icon: "airplane",
            color: .indigo
        ),
        UniversityCareer(
            name: "Ingeniería en Energías Renovables",
            university: "Universidad Autónoma de Guadalajara",
            description: "Diseño e implementación de sistemas de energía solar, eólica y otras fuentes renovables.",
            field: .environmental,
            duration: "4 años",
            icon: "sun.max",
            color: .green
        ),
        UniversityCareer(
            name: "Bioinformática",
            university: "CINVESTAV",
            description: "Aplicación de métodos computacionales para analizar datos biológicos y genómicos.",
            field: .biomedical,
            duration: "4 años",
            icon: "dna",
            color: .teal
        ),
        // Agregar más carreras para mayor diversidad
        UniversityCareer(
            name: "Ingeniería en Sistemas Computacionales",
            university: "Universidad Panamericana",
            description: "Diseño y gestión de infraestructura computacional, desarrollo de software y soluciones empresariales.",
            field: .computerScience,
            duration: "4 años",
            icon: "server.rack",
            color: .blue
        ),
        UniversityCareer(
            name: "Robótica y Sistemas Inteligentes",
            university: "UNAM",
            description: "Especialización en creación de sistemas autónomos, visión artificial y robótica avanzada.",
            field: .robotics,
            duration: "4.5 años",
            icon: "cpu",
            color: .purple
        ),
        UniversityCareer(
            name: "Ingeniería Electrónica",
            university: "IPN",
            description: "Desarrollo de circuitos, dispositivos electrónicos y sistemas de control para diversas aplicaciones.",
            field: .electrical,
            duration: "4 años",
            icon: "wave.3.right",
            color: .yellow
        ),
        UniversityCareer(
            name: "Nanociencia y Nanotecnología",
            university: "UNAM",
            description: "Estudio y manipulación de la materia a escala nanométrica para crear nuevos materiales y dispositivos.",
            field: .chemical,
            duration: "5 años",
            icon: "atom",
            color: .purple
        ),
        UniversityCareer(
            name: "Ingeniería Automotriz",
            university: "ITESM",
            description: "Diseño y desarrollo de vehículos, sistemas de transporte y tecnologías automotrices.",
            field: .mechanical,
            duration: "4.5 años",
            icon: "car",
            color: .red
        ),
        UniversityCareer(
            name: "Ingeniería en Telemática",
            university: "Universidad Iberoamericana",
            description: "Integración de telecomunicaciones y sistemas informáticos para transmisión de datos e información.",
            field: .computerScience,
            duration: "4 años",
            icon: "network",
            color: .blue
        ),
        UniversityCareer(
            name: "Biotecnología",
            university: "CINVESTAV",
            description: "Aplicación de procesos biológicos para desarrollar productos y servicios en diversos sectores.",
            field: .biomedical,
            duration: "4.5 años",
            icon: "leaf.arrow.circlepath",
            color: .green
        ),
        UniversityCareer(
            name: "Ingeniería en Data Science",
            university: "ITAM",
            description: "Análisis de grandes volúmenes de datos para obtener información valiosa y tomar decisiones.",
            field: .computerScience,
            duration: "4 años",
            icon: "chart.bar.xaxis",
            color: .blue
        )
    ]
}
