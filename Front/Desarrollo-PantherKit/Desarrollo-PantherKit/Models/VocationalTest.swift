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
    
    // This property is not included in Codable conformance
    var color: Color {
        switch id.uuidString.first?.lowercased() ?? "a" {
        case "a"..."e": return .blue
        case "f"..."j": return .purple
        case "k"..."o": return .orange
        case "p"..."t": return .green
        default: return .red
        }
    }
    
    // CodingKeys ensures color is not included in encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, name, imageName
    }
    
    static let allAvatars: [Avatar] = [
        Avatar(name: "Explorer", imageName: "person.fill.viewfinder"),
        Avatar(name: "Inventor", imageName: "lightbulb.fill"),
        Avatar(name: "Builder", imageName: "hammer.fill"),
        Avatar(name: "Scientist", imageName: "atom"),
        Avatar(name: "Designer", imageName: "paintbrush.fill"),
        Avatar(name: "Programmer", imageName: "laptopcomputer")
    ]
}

// MARK: - Question/Mission Model
struct Mission: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var imageName: String?
    var options: [MissionOption]
    var type: MissionType
    
    // Explicit coding keys to ensure proper encoding/decoding
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
        
        // This property is not included in Codable conformance
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

// MARK: - Mission Option
struct MissionOption: Identifiable, Codable {
    var id: UUID = UUID()
    var text: String
    var engineeringFields: [EngineeringField]
    var traits: [PersonalityTrait]
    
    // The weight of this option for each field (0.0 to 1.0)
    private var _fieldWeights: [String: Double]
    
    var fieldWeights: [String: Double] {
        get { return _fieldWeights }
        set { _fieldWeights = newValue }
    }
    
    // Custom initializer
    init(id: UUID = UUID(), text: String, engineeringFields: [EngineeringField], traits: [PersonalityTrait], fieldWeights: [String: Double]) {
        self.id = id
        self.text = text
        self.engineeringFields = engineeringFields
        self.traits = traits
        self._fieldWeights = fieldWeights
    }
    
    // Explicit coding keys to ensure proper encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, text, engineeringFields, traits, _fieldWeights
    }
}

// MARK: - Engineering Fields
enum EngineeringField: String, Codable, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case mechatronics = "Mechatronics"
    case robotics = "Robotics"
    case computerScience = "Computer Science"
    case electrical = "Electrical Engineering"
    case mechanical = "Mechanical Engineering"
    case industrial = "Industrial Engineering"
    case biomedical = "Biomedical Engineering"
    case environmental = "Environmental Engineering"
    case chemical = "Chemical Engineering"
    case civil = "Civil Engineering"
    
    var description: String {
        switch self {
        case .mechatronics:
            return "Combines mechanical, electrical, and computer engineering to create smart systems and robots."
        case .robotics:
            return "Focuses on designing, building, and programming robots for various applications."
        case .computerScience:
            return "Studies algorithms, programming languages, and software development."
        case .electrical:
            return "Works with electricity, electronics, and electromagnetism for various applications."
        case .mechanical:
            return "Designs and builds physical systems, machines, and devices."
        case .industrial:
            return "Optimizes complex processes, systems, or organizations."
        case .biomedical:
            return "Applies engineering principles to medicine and biology for healthcare."
        case .environmental:
            return "Develops solutions for environmental protection and sustainability."
        case .chemical:
            return "Applies chemistry to large-scale production of chemicals, fuels, and materials."
        case .civil:
            return "Designs and constructs infrastructure like buildings, bridges, and water systems."
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
    
    // This property is not included in Codable conformance
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
    
    // Use this property for Codable conformance
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
    
    // Explicit coding keys to ensure only rawValue is included in encoding/decoding
    private enum CodingKeys: String, CodingKey {
        case rawValue
    }
    
    var realWorldExample: String {
        switch self {
        case .mechatronics: return "Smart home systems, advanced manufacturing robots"
        case .robotics: return "Autonomous vehicles, surgical robots, drones"
        case .computerScience: return "Mobile apps, artificial intelligence, cloud computing"
        case .electrical: return "Renewable energy systems, microchips, telecommunications"
        case .mechanical: return "Automotive design, HVAC systems, manufacturing equipment"
        case .industrial: return "Supply chain optimization, factory layout design"
        case .biomedical: return "Prosthetics, medical imaging devices, diagnostic equipment"
        case .environmental: return "Water treatment systems, air quality monitoring"
        case .chemical: return "Pharmaceuticals, petroleum refining, food processing"
        case .civil: return "Bridges, highways, dams, skyscrapers, water supply systems"
        }
    }
}

// MARK: - Personality Traits
enum PersonalityTrait: String, Codable, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case analytical = "Analytical"
    case creative = "Creative"
    case practical = "Practical"
    case teamPlayer = "Team Player"
    case detailOriented = "Detail-Oriented"
    case bigPictureThinker = "Big Picture Thinker"
    case problemSolver = "Problem Solver"
    case communicator = "Communicator"
    
    var description: String {
        switch self {
        case .analytical: return "You enjoy analyzing data and finding patterns"
        case .creative: return "You think outside the box and come up with innovative solutions"
        case .practical: return "You focus on realistic, hands-on approaches"
        case .teamPlayer: return "You thrive in collaborative environments"
        case .detailOriented: return "You pay close attention to the small details"
        case .bigPictureThinker: return "You see how everything connects in the larger context"
        case .problemSolver: return "You enjoy tackling complex challenges"
        case .communicator: return "You excel at explaining complex ideas clearly"
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
    
    // Explicit coding keys to ensure only rawValue is included in encoding/decoding
    private enum CodingKeys: String, CodingKey {
        case rawValue
    }
}

// MARK: - Dictionary Extension
extension Dictionary {
    func mapKeys<T>(_ transform: (Key) -> T) -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            result[transform(key)] = value
        }
        return result
    }
}

// MARK: - Test Result
struct TestResult: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var avatar: Avatar
    
    // These dictionaries need custom coding keys since Dictionary with enum keys doesn't automatically conform to Codable
    private var _fieldScores: [String: Double]
    private var _traitScores: [String: Double]
    
    // Public interface that uses the enum types
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
    
    // Anonymous data for Hadoop analysis
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
            Mission(
                title: "Mars Base Construction",
                description: "You've just landed on Mars and need to build a base. What's your first priority?",
                imageName: "globe",
                options: [
                    MissionOption(
                        text: "Design an efficient power system using solar panels",
                        engineeringFields: [.electrical, .environmental],
                        traits: [.analytical, .practical],
                        fieldWeights: [
                            EngineeringField.electrical.rawValue: 0.8,
                            EngineeringField.environmental.rawValue: 0.6,
                            EngineeringField.mechatronics.rawValue: 0.4
                        ]
                    ),
                    MissionOption(
                        text: "Create an automated robot to help with construction",
                        engineeringFields: [.robotics, .mechatronics],
                        traits: [.creative, .problemSolver],
                        fieldWeights: [
                            EngineeringField.robotics.rawValue: 0.9,
                            EngineeringField.mechatronics.rawValue: 0.7,
                            EngineeringField.computerScience.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Design the base layout for maximum efficiency",
                        engineeringFields: [.industrial, .mechanical],
                        traits: [.bigPictureThinker, .detailOriented],
                        fieldWeights: [
                            EngineeringField.industrial.rawValue: 0.8,
                            EngineeringField.mechanical.rawValue: 0.6,
                            EngineeringField.environmental.rawValue: 0.4
                        ]
                    ),
                    MissionOption(
                        text: "Establish communication systems with Earth",
                        engineeringFields: [.computerScience, .electrical],
                        traits: [.communicator, .teamPlayer],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.7,
                            EngineeringField.electrical.rawValue: 0.7,
                            EngineeringField.mechatronics.rawValue: 0.3
                        ]
                    ),
                ],
                type: .problemSolving
            ),
            
            Mission(
                title: "Artificial Intelligence Project",
                description: "You're developing an AI system. What application would you focus on?",
                imageName: "brain.head.profile",
                options: [
                    MissionOption(
                        text: "Medical diagnosis and healthcare assistance",
                        engineeringFields: [.computerScience, .biomedical],
                        traits: [.analytical, .problemSolver],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.8,
                            EngineeringField.biomedical.rawValue: 0.8,
                            EngineeringField.electrical.rawValue: 0.3
                        ]
                    ),
                    MissionOption(
                        text: "Autonomous systems for manufacturing and logistics",
                        engineeringFields: [.robotics, .industrial],
                        traits: [.practical, .bigPictureThinker],
                        fieldWeights: [
                            EngineeringField.robotics.rawValue: 0.7,
                            EngineeringField.industrial.rawValue: 0.8,
                            EngineeringField.computerScience.rawValue: 0.6
                        ]
                    ),
                    MissionOption(
                        text: "Natural language processing and communication systems",
                        engineeringFields: [.computerScience, .electrical],
                        traits: [.communicator, .creative],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.9,
                            EngineeringField.electrical.rawValue: 0.5,
                            EngineeringField.mechatronics.rawValue: 0.3
                        ]
                    ),
                    MissionOption(
                        text: "Environmental monitoring and climate prediction",
                        engineeringFields: [.computerScience, .environmental],
                        traits: [.detailOriented, .teamPlayer],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.7,
                            EngineeringField.environmental.rawValue: 0.9,
                            EngineeringField.industrial.rawValue: 0.4
                        ]
                    )
                ],
                type: .logic
            ),
            
            Mission(
                title: "Sustainable Manufacturing",
                description: "You're redesigning a manufacturing process to be more sustainable. What's your approach?",
                imageName: "leaf.circle",
                options: [
                    MissionOption(
                        text: "Implement closed-loop recycling and zero-waste production",
                        engineeringFields: [.environmental, .industrial],
                        traits: [.bigPictureThinker, .practical],
                        fieldWeights: [
                            EngineeringField.environmental.rawValue: 0.9,
                            EngineeringField.industrial.rawValue: 0.8,
                            EngineeringField.mechanical.rawValue: 0.4
                        ]
                    ),
                    MissionOption(
                        text: "Develop energy-efficient machinery and processes",
                        engineeringFields: [.mechanical, .electrical],
                        traits: [.analytical, .detailOriented],
                        fieldWeights: [
                            EngineeringField.mechanical.rawValue: 0.8,
                            EngineeringField.electrical.rawValue: 0.7,
                            EngineeringField.environmental.rawValue: 0.6
                        ]
                    ),
                    MissionOption(
                        text: "Create smart factory systems with AI optimization",
                        engineeringFields: [.computerScience, .industrial],
                        traits: [.problemSolver, .analytical],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.7,
                            EngineeringField.industrial.rawValue: 0.8,
                            EngineeringField.mechatronics.rawValue: 0.6
                        ]
                    ),
                    MissionOption(
                        text: "Design products for longevity, repair, and recyclability",
                        engineeringFields: [.mechanical, .environmental],
                        traits: [.creative, .teamPlayer],
                        fieldWeights: [
                            EngineeringField.mechanical.rawValue: 0.7,
                            EngineeringField.environmental.rawValue: 0.8,
                            EngineeringField.industrial.rawValue: 0.6
                        ]
                    )
                ],
                type: .creativity
            ),
            
            Mission(
                title: "Wearable Technology",
                description: "You're designing a new wearable device. What would it do?",
                imageName: "applewatch",
                options: [
                    MissionOption(
                        text: "Monitor health metrics and provide personalized wellness advice",
                        engineeringFields: [.biomedical, .computerScience],
                        traits: [.analytical, .communicator],
                        fieldWeights: [
                            EngineeringField.biomedical.rawValue: 0.9,
                            EngineeringField.computerScience.rawValue: 0.7,
                            EngineeringField.electrical.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Enhance physical capabilities through exoskeleton support",
                        engineeringFields: [.mechatronics, .mechanical],
                        traits: [.practical, .problemSolver],
                        fieldWeights: [
                            EngineeringField.mechatronics.rawValue: 0.8,
                            EngineeringField.mechanical.rawValue: 0.8,
                            EngineeringField.biomedical.rawValue: 0.6
                        ]
                    ),
                    MissionOption(
                        text: "Create immersive AR experiences for everyday life",
                        engineeringFields: [.computerScience, .electrical],
                        traits: [.creative, .bigPictureThinker],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.8,
                            EngineeringField.electrical.rawValue: 0.7,
                            EngineeringField.industrial.rawValue: 0.4
                        ]
                    ),
                    MissionOption(
                        text: "Develop sustainable, energy-harvesting smart clothing",
                        engineeringFields: [.electrical, .environmental],
                        traits: [.detailOriented, .creative],
                        fieldWeights: [
                            EngineeringField.electrical.rawValue: 0.7,
                            EngineeringField.environmental.rawValue: 0.7,
                            EngineeringField.mechanical.rawValue: 0.5
                        ]
                    )
                ],
                type: .design
            ),
            
            Mission(
                title: "Water Resource Management",
                description: "Your region is facing water scarcity. How would you address this challenge?",
                imageName: "drop.fill",
                options: [
                    MissionOption(
                        text: "Design advanced water purification and recycling systems",
                        engineeringFields: [.environmental, .chemical],
                        traits: [.practical, .analytical],
                        fieldWeights: [
                            EngineeringField.environmental.rawValue: 0.9,
                            EngineeringField.biomedical.rawValue: 0.5,
                            EngineeringField.mechanical.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Develop smart monitoring networks for water usage optimization",
                        engineeringFields: [.computerScience, .environmental],
                        traits: [.detailOriented, .problemSolver],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.7,
                            EngineeringField.environmental.rawValue: 0.8,
                            EngineeringField.electrical.rawValue: 0.6
                        ]
                    ),
                    MissionOption(
                        text: "Create infrastructure for rainwater harvesting and groundwater recharge",
                        engineeringFields: [.civil, .environmental],
                        traits: [.bigPictureThinker, .teamPlayer],
                        fieldWeights: [
                            EngineeringField.environmental.rawValue: 0.8,
                            EngineeringField.industrial.rawValue: 0.6,
                            EngineeringField.mechanical.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Design water-efficient agricultural systems and practices",
                        engineeringFields: [.environmental, .mechanical],
                        traits: [.creative, .practical],
                        fieldWeights: [
                            EngineeringField.environmental.rawValue: 0.8,
                            EngineeringField.mechanical.rawValue: 0.6,
                            EngineeringField.industrial.rawValue: 0.5
                        ]
                    )
                ],
                type: .problemSolving
            ),
            
            Mission(
                title: "Smart City Challenge",
                description: "Your team is designing a smart city feature. Which project would you lead?",
                imageName: "building.2",
                options: [
                    MissionOption(
                        text: "Intelligent traffic management system",
                        engineeringFields: [.computerScience, .industrial],
                        traits: [.analytical, .bigPictureThinker],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.8,
                            EngineeringField.industrial.rawValue: 0.7,
                            EngineeringField.electrical.rawValue: 0.4
                        ]
                    ),
                    MissionOption(
                        text: "Automated waste collection robots",
                        engineeringFields: [.robotics, .environmental],
                        traits: [.practical, .problemSolver],
                        fieldWeights: [
                            EngineeringField.robotics.rawValue: 0.8,
                            EngineeringField.environmental.rawValue: 0.7,
                            EngineeringField.mechatronics.rawValue: 0.6
                        ]
                    ),
                    MissionOption(
                        text: "Energy-efficient building design",
                        engineeringFields: [.mechanical, .environmental],
                        traits: [.detailOriented, .creative],
                        fieldWeights: [
                            EngineeringField.mechanical.rawValue: 0.7,
                            EngineeringField.environmental.rawValue: 0.8,
                            EngineeringField.industrial.rawValue: 0.4
                        ]
                    ),
                    MissionOption(
                        text: "Public health monitoring network",
                        engineeringFields: [.biomedical, .computerScience],
                        traits: [.teamPlayer, .communicator],
                        fieldWeights: [
                            EngineeringField.biomedical.rawValue: 0.9,
                            EngineeringField.computerScience.rawValue: 0.6,
                            EngineeringField.electrical.rawValue: 0.4
                        ]
                    )
                ],
                type: .teamwork
            ),
            
            Mission(
                title: "Robot Design Challenge",
                description: "You're designing a new robot. What aspect do you focus on most?",
                imageName: "figure.walk.motion",
                options: [
                    MissionOption(
                        text: "Advanced movement and mechanical systems",
                        engineeringFields: [.mechanical, .robotics],
                        traits: [.practical, .detailOriented],
                        fieldWeights: [
                            EngineeringField.mechanical.rawValue: 0.9,
                            EngineeringField.robotics.rawValue: 0.7,
                            EngineeringField.mechatronics.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Sophisticated AI and decision-making algorithms",
                        engineeringFields: [.computerScience, .robotics],
                        traits: [.analytical, .problemSolver],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.9,
                            EngineeringField.robotics.rawValue: 0.7,
                            EngineeringField.mechatronics.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Intuitive user interface and controls",
                        engineeringFields: [.computerScience, .industrial],
                        traits: [.communicator, .creative],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.7,
                            EngineeringField.industrial.rawValue: 0.6,
                            EngineeringField.electrical.rawValue: 0.4
                        ]
                    ),
                    MissionOption(
                        text: "Efficient power systems and sensors",
                        engineeringFields: [.electrical, .mechatronics],
                        traits: [.analytical, .detailOriented],
                        fieldWeights: [
                            EngineeringField.electrical.rawValue: 0.8,
                            EngineeringField.mechatronics.rawValue: 0.8,
                            EngineeringField.robotics.rawValue: 0.5
                        ]
                    )
                ],
                type: .technical
            ),
            
            Mission(
                title: "Medical Innovation",
                description: "A hospital needs a new medical device. What would you create?",
                imageName: "heart.text.square",
                options: [
                    MissionOption(
                        text: "Wearable vital signs monitor with real-time alerts",
                        engineeringFields: [.biomedical, .electrical],
                        traits: [.practical, .problemSolver],
                        fieldWeights: [
                            EngineeringField.biomedical.rawValue: 0.9,
                            EngineeringField.electrical.rawValue: 0.7,
                            EngineeringField.computerScience.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Robotic surgical assistant with precision control",
                        engineeringFields: [.robotics, .mechatronics],
                        traits: [.detailOriented, .analytical],
                        fieldWeights: [
                            EngineeringField.robotics.rawValue: 0.8,
                            EngineeringField.mechatronics.rawValue: 0.8,
                            EngineeringField.biomedical.rawValue: 0.7
                        ]
                    ),
                    MissionOption(
                        text: "AI-powered diagnostic system",
                        engineeringFields: [.computerScience, .biomedical],
                        traits: [.analytical, .bigPictureThinker],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.8,
                            EngineeringField.biomedical.rawValue: 0.7,
                            EngineeringField.electrical.rawValue: 0.3
                        ]
                    ),
                    MissionOption(
                        text: "Ergonomic hospital equipment for patient comfort",
                        engineeringFields: [.mechanical, .industrial],
                        traits: [.creative, .teamPlayer],
                        fieldWeights: [
                            EngineeringField.mechanical.rawValue: 0.7,
                            EngineeringField.industrial.rawValue: 0.8,
                            EngineeringField.biomedical.rawValue: 0.6
                        ]
                    )
                ],
                type: .design
            ),
            
            Mission(
                title: "Environmental Challenge",
                description: "Your community faces an environmental issue. How do you solve it?",
                imageName: "leaf.fill",
                options: [
                    MissionOption(
                        text: "Design an automated recycling system",
                        engineeringFields: [.mechatronics, .environmental],
                        traits: [.practical, .problemSolver],
                        fieldWeights: [
                            EngineeringField.mechatronics.rawValue: 0.7,
                            EngineeringField.environmental.rawValue: 0.8,
                            EngineeringField.industrial.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Create a data-driven pollution monitoring network",
                        engineeringFields: [.computerScience, .environmental],
                        traits: [.analytical, .detailOriented],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.7,
                            EngineeringField.environmental.rawValue: 0.8,
                            EngineeringField.electrical.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Develop renewable energy solutions",
                        engineeringFields: [.electrical, .mechanical],
                        traits: [.creative, .bigPictureThinker],
                        fieldWeights: [
                            EngineeringField.electrical.rawValue: 0.8,
                            EngineeringField.mechanical.rawValue: 0.7,
                            EngineeringField.environmental.rawValue: 0.7
                        ]
                    ),
                    MissionOption(
                        text: "Organize community-wide sustainability initiatives",
                        engineeringFields: [.industrial, .environmental],
                        traits: [.communicator, .teamPlayer],
                        fieldWeights: [
                            EngineeringField.industrial.rawValue: 0.6,
                            EngineeringField.environmental.rawValue: 0.9,
                            EngineeringField.biomedical.rawValue: 0.3
                        ]
                    )
                ],
                type: .creativity
            ),
            
            // New questions
            Mission(
                title: "Future Transportation",
                description: "You're designing the next generation of transportation. What's your approach?",
                imageName: "car.fill",
                options: [
                    MissionOption(
                        text: "Develop autonomous electric vehicles with advanced AI",
                        engineeringFields: [.computerScience, .electrical],
                        traits: [.analytical, .bigPictureThinker],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.8,
                            EngineeringField.electrical.rawValue: 0.8,
                            EngineeringField.mechanical.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Create hyperloop transportation with magnetic levitation",
                        engineeringFields: [.mechanical, .electrical],
                        traits: [.creative, .problemSolver],
                        fieldWeights: [
                            EngineeringField.mechanical.rawValue: 0.8,
                            EngineeringField.electrical.rawValue: 0.7,
                            EngineeringField.industrial.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Design efficient urban transit networks and infrastructure",
                        engineeringFields: [.industrial, .environmental],
                        traits: [.teamPlayer, .bigPictureThinker],
                        fieldWeights: [
                            EngineeringField.industrial.rawValue: 0.9,
                            EngineeringField.environmental.rawValue: 0.6,
                            EngineeringField.mechanical.rawValue: 0.4
                        ]
                    ),
                    MissionOption(
                        text: "Build personal flying vehicles with advanced stabilization",
                        engineeringFields: [.mechatronics, .robotics],
                        traits: [.detailOriented, .creative],
                        fieldWeights: [
                            EngineeringField.mechatronics.rawValue: 0.8,
                            EngineeringField.robotics.rawValue: 0.7,
                            EngineeringField.mechanical.rawValue: 0.6
                        ]
                    )
                ],
                type: .design
            ),
            
            Mission(
                title: "Space Exploration",
                description: "NASA has asked you to contribute to their next mission. What would you work on?",
                imageName: "sparkles",
                options: [
                    MissionOption(
                        text: "Design life support systems for long-duration space travel",
                        engineeringFields: [.biomedical, .environmental],
                        traits: [.practical, .detailOriented],
                        fieldWeights: [
                            EngineeringField.biomedical.rawValue: 0.8,
                            EngineeringField.environmental.rawValue: 0.8,
                            EngineeringField.mechanical.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Develop advanced propulsion systems for interplanetary travel",
                        engineeringFields: [.mechanical, .electrical],
                        traits: [.analytical, .creative],
                        fieldWeights: [
                            EngineeringField.mechanical.rawValue: 0.9,
                            EngineeringField.electrical.rawValue: 0.7,
                            EngineeringField.computerScience.rawValue: 0.4
                        ]
                    ),
                    MissionOption(
                        text: "Create AI systems for autonomous space exploration",
                        engineeringFields: [.computerScience, .robotics],
                        traits: [.problemSolver, .bigPictureThinker],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.9,
                            EngineeringField.robotics.rawValue: 0.8,
                            EngineeringField.electrical.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Design habitats and infrastructure for lunar or Martian colonies",
                        engineeringFields: [.industrial, .environmental],
                        traits: [.teamPlayer, .practical],
                        fieldWeights: [
                            EngineeringField.industrial.rawValue: 0.8,
                            EngineeringField.environmental.rawValue: 0.7,
                            EngineeringField.mechanical.rawValue: 0.6
                        ]
                    )
                ],
                type: .problemSolving
            ),
            
            Mission(
                title: "Virtual Reality Innovation",
                description: "You're developing the next generation of VR technology. What's your focus?",
                imageName: "visionpro",
                options: [
                    MissionOption(
                        text: "Create immersive haptic feedback systems for realistic touch",
                        engineeringFields: [.mechatronics, .electrical],
                        traits: [.creative, .detailOriented],
                        fieldWeights: [
                            EngineeringField.mechatronics.rawValue: 0.8,
                            EngineeringField.electrical.rawValue: 0.7,
                            EngineeringField.biomedical.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Develop advanced graphics engines for photorealistic environments",
                        engineeringFields: [.computerScience, .electrical],
                        traits: [.analytical, .detailOriented],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.9,
                            EngineeringField.electrical.rawValue: 0.6,
                            EngineeringField.mechanical.rawValue: 0.3
                        ]
                    ),
                    MissionOption(
                        text: "Design lightweight, comfortable headsets with extended battery life",
                        engineeringFields: [.mechanical, .electrical],
                        traits: [.practical, .problemSolver],
                        fieldWeights: [
                            EngineeringField.mechanical.rawValue: 0.8,
                            EngineeringField.electrical.rawValue: 0.7,
                            EngineeringField.industrial.rawValue: 0.6
                        ]
                    ),
                    MissionOption(
                        text: "Create collaborative VR spaces for education and training",
                        engineeringFields: [.computerScience, .industrial],
                        traits: [.communicator, .teamPlayer],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.7,
                            EngineeringField.industrial.rawValue: 0.7,
                            EngineeringField.biomedical.rawValue: 0.4
                        ]
                    )
                ],
                type: .creativity
            ),
            
            Mission(
                title: "Renewable Energy Project",
                description: "You're leading a renewable energy initiative. Which technology do you choose?",
                imageName: "bolt.fill",
                options: [
                    MissionOption(
                        text: "Advanced solar panel systems with tracking and storage",
                        engineeringFields: [.electrical, .environmental],
                        traits: [.practical, .analytical],
                        fieldWeights: [
                            EngineeringField.electrical.rawValue: 0.8,
                            EngineeringField.environmental.rawValue: 0.8,
                            EngineeringField.mechanical.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Innovative wind turbine designs for urban environments",
                        engineeringFields: [.mechanical, .environmental],
                        traits: [.creative, .problemSolver],
                        fieldWeights: [
                            EngineeringField.mechanical.rawValue: 0.9,
                            EngineeringField.environmental.rawValue: 0.7,
                            EngineeringField.electrical.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Ocean wave and tidal energy capture systems",
                        engineeringFields: [.mechanical, .electrical],
                        traits: [.bigPictureThinker, .detailOriented],
                        fieldWeights: [
                            EngineeringField.mechanical.rawValue: 0.8,
                            EngineeringField.electrical.rawValue: 0.7,
                            EngineeringField.environmental.rawValue: 0.7
                        ]
                    ),
                    MissionOption(
                        text: "Smart grid technology for efficient energy distribution",
                        engineeringFields: [.computerScience, .electrical],
                        traits: [.analytical, .teamPlayer],
                        fieldWeights: [
                            EngineeringField.computerScience.rawValue: 0.7,
                            EngineeringField.electrical.rawValue: 0.9,
                            EngineeringField.industrial.rawValue: 0.5
                        ]
                    )
                ],
                type: .technical
            ),
            
            Mission(
                title: "Disaster Response Technology",
                description: "You're developing technology to help in natural disaster response. What's your focus?",
                imageName: "hurricane",
                options: [
                    MissionOption(
                        text: "Autonomous search and rescue drones with thermal imaging",
                        engineeringFields: [.robotics, .computerScience],
                        traits: [.problemSolver, .practical],
                        fieldWeights: [
                            EngineeringField.robotics.rawValue: 0.9,
                            EngineeringField.computerScience.rawValue: 0.7,
                            EngineeringField.electrical.rawValue: 0.5
                        ]
                    ),
                    MissionOption(
                        text: "Rapid-deployment emergency communication networks",
                        engineeringFields: [.electrical, .computerScience],
                        traits: [.communicator, .teamPlayer],
                        fieldWeights: [
                            EngineeringField.electrical.rawValue: 0.8,
                            EngineeringField.computerScience.rawValue: 0.7,
                            EngineeringField.industrial.rawValue: 0.4
                        ]
                    ),
                    MissionOption(
                        text: "Structural integrity monitoring systems for buildings",
                        engineeringFields: [.mechanical, .industrial],
                        traits: [.analytical, .detailOriented],
                        fieldWeights: [
                            EngineeringField.mechanical.rawValue: 0.8,
                            EngineeringField.industrial.rawValue: 0.7,
                            EngineeringField.computerScience.rawValue: 0.4
                        ]
                    ),
                    MissionOption(
                        text: "Water purification and emergency resource distribution systems",
                        engineeringFields: [.environmental, .biomedical],
                        traits: [.bigPictureThinker, .practical],
                        fieldWeights: [
                            EngineeringField.environmental.rawValue: 0.9,
                            EngineeringField.biomedical.rawValue: 0.6,
                            EngineeringField.mechanical.rawValue: 0.4
                        ]
                    )
                ],
                type: .problemSolving
            )
        ]
    }
}
