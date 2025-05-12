//
//  ProjectViewModel.swift
//  Desarrollo-PantherKit
//
//  Created on 5/11/25.
//

import Foundation
import SwiftUI
import Combine

class ProjectViewModel: ObservableObject {
    // Published properties that the views can observe
    @Published var projects: [Project] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedProject: Project?
    @Published var filterStatus: ProjectStatus?
    @Published var searchText: String = ""
    
    // Cancellables set to store subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init(projects: [Project] = []) {
        self.projects = projects.isEmpty ? Project.sampleProjects : projects
        
        // Set up search and filter publishers
        setupPublishers()
    }
    
    // MARK: - Publishers Setup
    
    private func setupPublishers() {
        // Combine the search text and filter status publishers
        Publishers.CombineLatest($searchText, $filterStatus)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] (searchText, filterStatus) in
                self?.filterProjects(searchText: searchText, status: filterStatus)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Filtering
    
    private func filterProjects(searchText: String, status: ProjectStatus?) {
        // This would typically filter from a master list
        // For now, we'll just reset to sample data and then filter
        var filteredProjects = Project.sampleProjects
        
        // Filter by status if needed
        if let status = status {
            filteredProjects = filteredProjects.filter { $0.status == status }
        }
        
        // Filter by search text if not empty
        if !searchText.isEmpty {
            filteredProjects = filteredProjects.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased()) ||
                $0.tags.contains { $0.lowercased().contains(searchText.lowercased()) }
            }
        }
        
        // Update the projects list
        self.projects = filteredProjects
    }
    
    // MARK: - CRUD Operations
    
    func addProject(_ project: Project) {
        projects.append(project)
        // In a real app, you would save to persistent storage here
    }
    
    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            // In a real app, you would update persistent storage here
        }
    }
    
    func deleteProject(at indexSet: IndexSet) {
        projects.remove(atOffsets: indexSet)
        // In a real app, you would update persistent storage here
    }
    
    func deleteProject(withID id: UUID) {
        projects.removeAll { $0.id == id }
        // In a real app, you would update persistent storage here
    }
    
    // MARK: - Data Loading
    
    func loadProjects() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // In a real app, you would load from an API or database
            self.projects = Project.sampleProjects
            self.isLoading = false
        }
    }
    
    // MARK: - Project Status Management
    
    func updateProjectStatus(projectID: UUID, newStatus: ProjectStatus) {
        if let index = projects.firstIndex(where: { $0.id == projectID }) {
            projects[index].status = newStatus
            projects[index].updatedAt = Date()
            
            // Update progress based on status
            switch newStatus {
            case .completed:
                projects[index].progress = 1.0
            case .notStarted:
                projects[index].progress = 0.0
            case .onHold:
                // Keep current progress
                break
            case .inProgress:
                // If it was not started, set to some initial progress
                if projects[index].progress == 0 {
                    projects[index].progress = 0.1
                }
            }
            
            // In a real app, you would update persistent storage here
        }
    }
    
    func updateProjectProgress(projectID: UUID, progress: Double) {
        if let index = projects.firstIndex(where: { $0.id == projectID }) {
            // Ensure progress is between 0 and 1
            let clampedProgress = max(0, min(1, progress))
            projects[index].progress = clampedProgress
            projects[index].updatedAt = Date()
            
            // Update status based on progress
            if clampedProgress >= 1.0 {
                projects[index].status = .completed
            } else if clampedProgress > 0 {
                projects[index].status = .inProgress
            }
            
            // In a real app, you would update persistent storage here
        }
    }
    
    // MARK: - Team Management
    
    func addTeamMember(to projectID: UUID, member: TeamMember) {
        if let index = projects.firstIndex(where: { $0.id == projectID }) {
            projects[index].teamMembers.append(member)
            projects[index].updatedAt = Date()
            
            // In a real app, you would update persistent storage here
        }
    }
    
    func removeTeamMember(from projectID: UUID, memberID: UUID) {
        if let projectIndex = projects.firstIndex(where: { $0.id == projectID }) {
            projects[projectIndex].teamMembers.removeAll { $0.id == memberID }
            projects[projectIndex].updatedAt = Date()
            
            // In a real app, you would update persistent storage here
        }
    }
}
