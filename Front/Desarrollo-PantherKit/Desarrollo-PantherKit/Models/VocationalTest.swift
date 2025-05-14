//
//  VocationalTest.swift
//  Desarrollo-PantherKit
//
//  Created on 5/12/25.
//

import Foundation
import SwiftUI

// MARK: - Avatar Model
struct Avatar: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var imageName: String
    
    // Esta propiedad no está incluida en la conformancia Codable
    var color: Color {
        switch id.uuidString.first?.lowercased() ?? "a" {
        case "a"..."e": return .blue
        case "f"..."j": return .purple
        case "k"..."o": return .orange
        case "p"..."t": return .green
        default: return .red
        }
    }
    
    // CodingKeys asegura que color no esté incluido en la codificación/decodificación
    enum CodingKeys: String, CodingKey {
        case id, name, imageName
    }
    
    static let allAvatars: [Avatar] = [
        Avatar(name: "Explorador", imageName: "person.fill.viewfinder"),
        Avatar(name: "Inventor", imageName: "lightbulb.fill"),
        Avatar(name: "Constructor", imageName: "hammer.fill"),
        Avatar(name: "Científico", imageName: "atom"),
        Avatar(name: "Diseñador", imageName: "paintbrush.fill"),
        Avatar(name: "Programador", imageName: "laptopcomputer")
    ]
}

// MARK: - Modelo de Pregunta/Misión
struct Mission: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var imageName: String?
    var options: [MissionOption]
    var type: MissionType
    
    // Claves de codificación explícitas para asegurar una codificación/decodificación adecuada
    enum CodingKeys: String, CodingKey {
        case id, title, description, imageName, options, type
    }
    
    enum MissionType: String, Codable {
        case logic
        case creativity
        case problemSolving
        case teamwork
        case technical
        case design
        
        // Esta propiedad no está incluida en la conformancia Codable
        var icon: String {
            switch self {
            case .logic: return "brain"
            case .creativity: return "paintpalette"
            case .problemSolving: return "puzzlepiece"
            case .teamwork: return "person.3.fill"
            case .technical: return "gearshape.2"
            case .design: return "pencil.and.ruler"
            }
        }
    }
}

// MARK: - Opción de Misión
struct MissionOption: Identifiable, Codable {
    var id: UUID = UUID()
    var text: String
    var engineeringFields: [EngineeringField]
    var traits: [PersonalityTrait]
    
    // El peso de esta opción para cada campo (0.0 a 1.0)
    private var _fieldWeights: [String: Double]
    
    var fieldWeights: [String: Double] {
        get { return _fieldWeights }
        set { _fieldWeights = newValue }
    }
    
    // Inicializador personalizado
    init(id: UUID = UUID(), text: String, engineeringFields: [EngineeringField], traits: [PersonalityTrait], fieldWeights: [String: Double]) {
        self.id = id
        self.text = text
        self.engineeringFields = engineeringFields
        self.traits = traits
        self._fieldWeights = fieldWeights
    }
    
    // Claves de codificación explícitas para asegurar una codificación/decodificación adecuada
    enum CodingKeys: String, CodingKey {
        case id, text, engineeringFields, traits, _fieldWeights
    }
}

// MARK: - Campos de Ingeniería
enum EngineeringField: String, Codable, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case mechatronics = "Mecatrónica"
    case robotics = "Robótica"
    case computerScience = "Informática"
    case electrical = "Ingeniería Eléctrica"
    case mechanical = "Ingeniería Mecánica"
    case industrial = "Ingeniería Industrial"
    case biomedical = "Ingeniería Biomédica"
    case environmental = "Ingeniería Ambiental"
    case chemical = "Ingeniería Química"
    case civil = "Ingeniería Civil"
    
    var description: String {
        switch self {
        case .mechatronics:
            return "Combina ingeniería mecánica, eléctrica y computacional para crear sistemas inteligentes y robots."
        case .robotics:
            return "Se centra en el diseño, construcción y programación de robots para diversas aplicaciones."
        case .computerScience:
            return "Estudia algoritmos, lenguajes de programación y desarrollo de software."
        case .electrical:
            return "Trabaja con electricidad, electrónica y electromagnetismo para diversas aplicaciones."
        case .mechanical:
            return "Diseña y construye sistemas físicos, máquinas y dispositivos."
        case .industrial:
            return "Optimiza procesos complejos, sistemas u organizaciones."
        case .biomedical:
            return "Aplica principios de ingeniería a la medicina y biología para la atención médica."
        case .environmental:
            return "Desarrolla soluciones para la protección ambiental y la sostenibilidad."
        case .chemical:
            return "Aplica la química a la producción a gran escala de químicos, combustibles y materiales."
        case .civil:
            return "Diseña y construye infraestructura como edificios, puentes y sistemas de agua."
        }
    }
    
    var icon: String {
        switch self {
        case .mechatronics: return "gearshape.2"
        case .robotics: return "figure.walk.motion"
        case .computerScience: return "desktopcomputer"
        case .electrical: return "bolt.fill"
        case .mechanical: return "gear"
        case .industrial: return "chart.bar.fill"
        case .biomedical: return "heart.text.square.fill"
        case .environmental: return "leaf.fill"
        case .chemical: return "flask.fill"
        case .civil: return "building.columns.fill"
        }
    }
    
    // Esta propiedad no está incluida en la conformancia Codable
    @available(*, deprecated, message: "Use colorName instead for Codable conformance")
    var color: Color {
        switch self {
        case .mechatronics: return .purple
        case .robotics: return .blue
        case .computerScience: return .gray
        case .electrical: return .yellow
        case .mechanical: return .orange
        case .industrial: return .green
        case .biomedical: return .red
        case .environmental: return .mint
        case .chemical: return .teal
        case .civil: return .brown
        }
    }
    
    // Usa esta propiedad para la conformancia Codable
    var colorName: String {
        switch self {
        case .mechatronics: return "purple"
        case .robotics: return "blue"
        case .computerScience: return "gray"
        case .electrical: return "yellow"
        case .mechanical: return "orange"
        case .industrial: return "green"
        case .biomedical: return "red"
        case .environmental: return "mint"
        case .chemical: return "teal"
        case .civil: return "brown"
        }
    }
    
    // Claves de codificación explícitas para asegurar que solo rawValue se incluya en codificación/decodificación
    private enum CodingKeys: String, CodingKey {
        case rawValue
    }
    
    var realWorldExample: String {
        switch self {
        case .mechatronics: return "Sistemas domóticos, robots de manufactura avanzada"
        case .robotics: return "Vehículos autónomos, robots quirúrgicos, drones"
        case .computerScience: return "Aplicaciones móviles, inteligencia artificial, computación en la nube"
        case .electrical: return "Sistemas de energía renovable, microchips, telecomunicaciones"
        case .mechanical: return "Diseño automotriz, sistemas HVAC, equipos de fabricación"
        case .industrial: return "Optimización de cadenas de suministro, diseño de distribución de fábricas"
        case .biomedical: return "Prótesis, dispositivos de imágenes médicas, equipos de diagnóstico"
        case .environmental: return "Sistemas de tratamiento de agua, monitoreo de calidad del aire"
        case .chemical: return "Farmacéuticos, refinación de petróleo, procesamiento de alimentos"
        case .civil: return "Puentes, carreteras, presas, rascacielos, sistemas de suministro de agua"
        }
    }
}

// MARK: - Rasgos de Personalidad
enum PersonalityTrait: String, Codable, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case analytical = "Analítico"
    case creative = "Creativo"
    case practical = "Práctico"
    case teamPlayer = "Trabajo en Equipo"
    case detailOriented = "Orientado al Detalle"
    case bigPictureThinker = "Pensador Global"
    case problemSolver = "Solucionador de Problemas"
    case communicator = "Comunicador"
    
    var description: String {
        switch self {
        case .analytical: return "Disfrutas analizando datos y encontrando patrones"
        case .creative: return "Piensas fuera de la caja y generas soluciones innovadoras"
        case .practical: return "Te enfocas en enfoques realistas y prácticos"
        case .teamPlayer: return "Prosperas en entornos colaborativos"
        case .detailOriented: return "Prestas mucha atención a los pequeños detalles"
        case .bigPictureThinker: return "Ves cómo todo se conecta en un contexto más amplio"
        case .problemSolver: return "Disfrutas abordando desafíos complejos"
        case .communicator: return "Sobresales en explicar ideas complejas con claridad"
        }
    }
    
    var icon: String {
        switch self {
        case .analytical: return "chart.bar.xaxis"
        case .creative: return "lightbulb.fill"
        case .practical: return "hammer.fill"
        case .teamPlayer: return "person.3.fill"
        case .detailOriented: return "magnifyingglass"
        case .bigPictureThinker: return "globe"
        case .problemSolver: return "puzzlepiece.fill"
        case .communicator: return "bubble.left.fill"
        }
    }
    
    // Claves de codificación explícitas para asegurar que solo rawValue se incluya en codificación/decodificación
    private enum CodingKeys: String, CodingKey {
        case rawValue
    }
}

// MARK: - Extensión de Diccionario
extension Dictionary {
    func mapKeys<T>(_ transform: (Key) -> T) -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            result[transform(key)] = value
        }
        return result
    }
}

// MARK: - Resultado del Test
struct TestResult: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var avatar: Avatar
    
    // Estos diccionarios necesitan claves de codificación personalizadas ya que Dictionary con claves enum no se conforma automáticamente a Codable
    private var _fieldScores: [String: Double]
    private var _traitScores: [String: Double]
    
    // Interfaz pública que utiliza los tipos enum
    var fieldScores: [EngineeringField: Double] {
        get {
            var result: [EngineeringField: Double] = [:]
            for (key, value) in _fieldScores {
                if let field = EngineeringField(rawValue: key) {
                    result[field] = value
                }
            }
            return result
        }
        set {
            _fieldScores = newValue.mapKeys { $0.rawValue }
        }
    }
    
    var traitScores: [PersonalityTrait: Double] {
        get {
            var result: [PersonalityTrait: Double] = [:]
            for (key, value) in _traitScores {
                if let trait = PersonalityTrait(rawValue: key) {
                    result[trait] = value
                }
            }
            return result
        }
        set {
            _traitScores = newValue.mapKeys { $0.rawValue }
        }
    }
    
    init(id: UUID = UUID(), date: Date = Date(), avatar: Avatar, fieldScores: [EngineeringField: Double], traitScores: [PersonalityTrait: Double]) {
        self.id = id
        self.date = date
        self.avatar = avatar
        self._fieldScores = fieldScores.mapKeys { $0.rawValue }
        self._traitScores = traitScores.mapKeys { $0.rawValue }
    }
    
    var primaryField: EngineeringField {
        fieldScores.max(by: { $0.value < $1.value })?.key ?? .mechatronics
    }
    
    var secondaryField: EngineeringField {
        let sortedFields = fieldScores.sorted(by: { $0.value > $1.value })
        return sortedFields.count > 1 ? sortedFields[1].key : .robotics
    }
    
    var primaryTrait: PersonalityTrait {
        traitScores.max(by: { $0.value < $1.value })?.key ?? .problemSolver
    }
    
    var secondaryTrait: PersonalityTrait {
        let sortedTraits = traitScores.sorted(by: { $0.value > $1.value })
        return sortedTraits.count > 1 ? sortedTraits[1].key : .creative
    }
    
    // Datos anónimos para análisis Hadoop
    func anonymousData() -> [String: Any] {
        [
            "timestamp": date.timeIntervalSince1970,
            "primaryField": primaryField.rawValue,
            "secondaryField": secondaryField.rawValue,
            "primaryTrait": primaryTrait.rawValue,
            "secondaryTrait": secondaryTrait.rawValue,
            "allFieldScores": _fieldScores,
            "allTraitScores": _traitScores
        ]
    }
}

// MARK: - Sample Data
extension Mission {
    static var sampleMissions: [Mission] {
        [
            // Lógica y Resolución de Problemas
            Mission(
                title: "Resolver un Enigma Matemático",
                description: "Te enfrentas a un acertijo que requiere lógica y pensamiento crítico para encontrar la solución.",
                imageName: "brain",
                options: [
                    MissionOption(
                        text: "Analizar cada paso y validar con pruebas numéricas",
                        engineeringFields: [.computerScience, .electrical],
                        traits: [.analytical, .detailOriented],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.8,
                            EngineeringField.electrical.rawValue: 0.6
                        ]
                    ),
                    MissionOption(
                        text: "Buscar patrones y formular una estrategia general",
                        engineeringFields: [.mechanical, .industrial],
                        traits: [.bigPictureThinker, .problemSolver],
                        fieldWeights: [
                            EngineeringField.mechanical.rawValue: 0.7,
                            EngineeringField.industrial.rawValue: 0.5
                        ]
                    )
                ],
                type: .logic
            ),
            // Creatividad e Innovación
            Mission(
                title: "Diseñar un Producto Sostenible",
                description: "Desarrolla un concepto de producto que utilice materiales reciclados y sea funcional.",
                imageName: "leaf",
                options: [
                    MissionOption(
                        text: "Enfocar en materiales y procesos ecológicos innovadores",
                        engineeringFields: [.environmental, .chemical],
                        traits: [.creative, .practical],
                        fieldWeights: [
                            EngineeringField.environmental.rawValue: 0.9,
                            EngineeringField.chemical.rawValue: 0.6
                        ]
                    ),
                    MissionOption(
                        text: "Crear un prototipo sencillo y atractivo para usuarios",
                        engineeringFields: [.computerScience, .industrial],
                        traits: [.communicator, .detailOriented],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.8,
                            EngineeringField.industrial.rawValue: 0.5
                        ]
                    )
                ],
                type: .creativity
            ),
            // Trabajo en Equipo
            Mission(
                title: "Colaborar en un Proyecto Interdisciplinario",
                description: "Participa en un equipo con distintas especialidades para completar una tarea compleja.",
                imageName: "person.3.fill",
                options: [
                    MissionOption(
                        text: "Coordinar reuniones y distribuir tareas según fortalezas",
                        engineeringFields: [.industrial, .civil],
                        traits: [.teamPlayer, .communicator],
                        fieldWeights: [
                            EngineeringField.industrial.rawValue: 0.8,
                            EngineeringField.civil.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Contribuir con soluciones técnicas específicas en tu área",
                        engineeringFields: [.mechanical, .electrical],
                        traits: [.problemSolver, .detailOriented],
                        fieldWeights: [
                            EngineeringField.mechanical.rawValue: 0.7,
                            EngineeringField.electrical.rawValue: 0.6
                        ]
                    )
                ],
                type: .teamwork
            ),
            // Competencias Técnicas
            Mission(
                title: "Optimizar un Algoritmo de Búsqueda",
                description: "Mejora el rendimiento de un algoritmo que procesa grandes volúmenes de datos.",
                imageName: "terminal",
                options: [
                    MissionOption(
                        text: "Implementar estructuras de datos avanzadas para acelerar búsquedas",
                        engineeringFields: [.computerScience],
                        traits: [.analytical, .problemSolver],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 1.0
                        ]
                    ),
                    MissionOption(
                        text: "Paralelizar procesos y distribuir carga en múltiples hilos",
                        engineeringFields: [.computerScience, .industrial],
                        traits: [.detailOriented, .bigPictureThinker],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.8,
                            EngineeringField.industrial.rawValue: 0.6
                        ]
                    )
                ],
                type: .technical
            ),
            // Diseño y Ergonomía
            Mission(
                title: "Crear una Interfaz de Usuario Intuitiva",
                description: "Diseña mockups y prototipos que garanticen una experiencia de usuario óptima.",
                imageName: "paintbrush",
                options: [
                    MissionOption(
                        text: "Elaborar wireframes claros y jerarquía visual definida",
                        engineeringFields: [.computerScience, .industrial],
                        traits: [.creative, .bigPictureThinker],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.9,
                            EngineeringField.industrial.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Testing con usuarios reales y ajustes basados en feedback",
                        engineeringFields: [.computerScience, .industrial],
                        traits: [.communicator, .detailOriented],
                        fieldWeights: [
                            EngineeringField.industrial.rawValue: 0.7,
                            EngineeringField.computerScience.rawValue: 0.6
                        ]
                    )
                ],
                type: .design
            )
        ]
    }
}
