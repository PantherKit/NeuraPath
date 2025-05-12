//
//  Project.swift
//  Desarrollo-PantherKit
//
//  Created on 5/11/25.
//

import Foundation
import SwiftUI

// This is a sample model that can be modified based on the hackathon theme
struct Project: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var imageURL: URL?
    var createdAt: Date
    var updatedAt: Date
    var tags: [String]
    var status: ProjectStatus
    var progress: Double // 0.0 to 1.0
    var teamMembers: [TeamMember]
    var additionalData: [String: String] // Flexible field for hackathon-specific data
    
    // Sample initializer with default values
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        imageURL: URL? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tags: [String] = [],
        status: ProjectStatus = .notStarted,
        progress: Double = 0.0,
        teamMembers: [TeamMember] = [],
        additionalData: [String: String] = [:]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
        self.status = status
        self.progress = progress
        self.teamMembers = teamMembers
        self.additionalData = additionalData
    }
}

// Status enum that can be customized based on hackathon needs
enum ProjectStatus: String, Codable, CaseIterable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"
    case onHold = "On Hold"
    
    var color: Color {
        switch self {
        case .notStarted:
            return .gray
        case .inProgress:
            return .blue
        case .completed:
            return .green
        case .onHold:
            return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .notStarted:
            return "circle"
        case .inProgress:
            return "arrow.triangle.2.circlepath"
        case .completed:
            return "checkmark.circle"
        case .onHold:
            return "pause.circle"
        }
    }
}

// Team member model
struct TeamMember: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var role: String
    var avatarURL: URL?
    var contactInfo: String?
    
    init(id: UUID = UUID(), name: String, role: String, avatarURL: URL? = nil, contactInfo: String? = nil) {
        self.id = id
        self.name = name
        self.role = role
        self.avatarURL = avatarURL
        self.contactInfo = contactInfo
    }
}

// MARK: - Sample Data
extension Project {
    static var sampleProjects: [Project] {
        [
            Project(
                title: "Smart City Solution",
                description: "An IoT-based solution for monitoring and managing city resources efficiently.",
                tags: ["IoT", "Smart City", "Sustainability"],
                status: .inProgress,
                progress: 0.65,
                teamMembers: [
                    TeamMember(name: "Alex Johnson", role: "Project Lead"),
                    TeamMember(name: "Maria Garcia", role: "IoT Developer"),
                    TeamMember(name: "Sam Lee", role: "UI/UX Designer")
                ]
            ),
            Project(
                title: "Health Monitoring App",
                description: "Mobile application for tracking health metrics and providing personalized recommendations.",
                tags: ["Healthcare", "Mobile", "AI"],
                status: .notStarted,
                progress: 0.0,
                teamMembers: [
                    TeamMember(name: "Chris Wong", role: "Health Specialist"),
                    TeamMember(name: "Jamie Smith", role: "Mobile Developer")
                ]
            ),
            Project(
                title: "Educational Platform",
                description: "Interactive learning platform for students with gamification elements.",
                tags: ["Education", "Gamification", "Web"],
                status: .completed,
                progress: 1.0,
                teamMembers: [
                    TeamMember(name: "Taylor Brown", role: "Education Expert"),
                    TeamMember(name: "Jordan Miller", role: "Full Stack Developer"),
                    TeamMember(name: "Casey Wilson", role: "Game Designer")
                ]
            )
        ]
    }
}
