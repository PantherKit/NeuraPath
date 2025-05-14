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
        // Break down the complex expression into distinct sub-expressions
        
        // Step 1: Sort the field scores by value in descending order
        let sortedFieldScores = result.fieldScores.sorted { $0.value > $1.value }
        
        // Step 2: Take the top 3 scores
        let topThreeScores = sortedFieldScores.prefix(3)
        
        // Step 3: Extract just the fields (keys) from the top scores
        let topFields = topThreeScores.map { $0.key }
        
        // Step 4: Filter careers that match the top fields
        var recommendedCareers = sampleCareers.filter { career in
            topFields.contains(career.field)
        }
        
        // Step 5: Si hay menos de 6 carreras, añadir más hasta tener al menos 6
        if recommendedCareers.count < 6 {
            // Obtener carreras adicionales que no estén ya incluidas
            let additionalCareers = sampleCareers.filter { career in
                !recommendedCareers.contains(where: { $0.id == career.id })
            }
            
            // Añadir carreras adicionales hasta tener 6 o más
            let neededCount = min(6 - recommendedCareers.count, additionalCareers.count)
            recommendedCareers.append(contentsOf: additionalCareers.prefix(neededCount))
        }
        
        // Step 6: Duplicar algunas carreras para asegurar un desplazamiento continuo
        let originalCount = recommendedCareers.count
        for i in 0..<min(originalCount, 4) {
            recommendedCareers.append(recommendedCareers[i])
        }
        
        return recommendedCareers
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
        )
    ]
}
