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
    var color: Color {
        switch id.uuidString.first?.lowercased() ?? "a" {
        case "a"..."e": return .blue
        case "f"..."j": return .purple
        case "k"..."o": return .orange
        case "p"..."t": return .green
        default: return .red
        }
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
    
    enum MissionType: String, Codable {
        case logic
        case creativity
        case problemSolving
        case teamwork
        case technical
        case design
        
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
    var fieldWeights: [String: Double]
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
        }
    }
    
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
        }
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
}

// MARK: - Test Result
struct TestResult: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var avatar: Avatar
    var fieldScores: [EngineeringField: Double]
    var traitScores: [PersonalityTrait: Double]
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
            "allFieldScores": fieldScores.mapKeys { $0.rawValue },
            "allTraitScores": traitScores.mapKeys { $0.rawValue }
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
            )
        ]
    }
}

// MARK: - Helper Extensions
extension Dictionary {
    func mapKeys<T>(_ transform: (Key) -> T) -> [T: Value] where T: Hashable {
        var result: [T: Value] = [:]
        for (key, value) in self {
            result[transform(key)] = value
        }
        return result
    }
}
