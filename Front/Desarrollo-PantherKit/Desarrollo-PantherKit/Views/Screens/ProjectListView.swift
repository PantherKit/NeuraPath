//
//  ProjectListView.swift
//  Desarrollo-PantherKit
//
//  Created on 5/11/25.
//

import SwiftUI

struct ProjectListView: View {
    @ObservedObject var viewModel: ProjectViewModel
    @State private var showingAddProject = false
    @State private var searchText = ""
    @State private var selectedStatusFilter: ProjectStatus?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search and filter bar
                    searchAndFilterBar
                    
                    // Project list
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.projects.isEmpty {
                        emptyStateView
                    } else {
                        projectListContent
                    }
                }
                .navigationTitle("Projects")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddProject = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddProject) {
                    Text("Add Project View Placeholder")
                        .padding()
                }
                .onAppear {
                    viewModel.loadProjects()
                }
            }
        }
    }
    
    // MARK: - Search and Filter Bar
    
    private var searchAndFilterBar: some View {
        VStack(spacing: AppTheme.Layout.spacingS) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.Colors.secondaryText)
                
                TextField("Search projects", text: $searchText)
                    .onChange(of: searchText) { newValue in
                        viewModel.searchText = newValue
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
            }
            .padding(AppTheme.Layout.spacingM)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(AppTheme.Layout.cornerRadiusM)
            .padding(.horizontal)
            
            // Status filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Layout.spacingS) {
                    statusFilterChip(nil, "All")
                    
                    ForEach(ProjectStatus.allCases, id: \.self) { status in
                        statusFilterChip(status, status.rawValue)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, AppTheme.Layout.spacingS)
        }
        .background(AppTheme.Colors.background)
    }
    
    private func statusFilterChip(_ status: ProjectStatus?, _ title: String) -> some View {
        let isSelected = (selectedStatusFilter == status)
        
        return Button(action: {
            if selectedStatusFilter == status {
                // Deselect if already selected
                selectedStatusFilter = nil
                viewModel.filterStatus = nil
            } else {
                selectedStatusFilter = status
                viewModel.filterStatus = status
            }
        }) {
            Text(title)
                .font(.system(size: AppTheme.Typography.caption1))
                .padding(.horizontal, AppTheme.Layout.spacingM)
                .padding(.vertical, AppTheme.Layout.spacingS)
                .background(isSelected ? (status?.color ?? AppTheme.Colors.primary) : AppTheme.Colors.secondaryBackground)
                .foregroundColor(isSelected ? .white : AppTheme.Colors.text)
                .cornerRadius(AppTheme.Layout.cornerRadiusM)
        }
    }
    
    // MARK: - Project List Content
    
    private var projectListContent: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Layout.spacingM) {
                ForEach(viewModel.projects) { project in
                    NavigationLink(destination: Text("Project Detail View Placeholder for \(project.title)")) {
                        ProjectCardView(project: project)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
    
    // MARK: - Loading and Empty States
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Loading projects...")
                .font(.system(size: AppTheme.Typography.body))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Layout.spacingL) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.secondaryText)
            
            Text("No projects found")
                .font(.system(size: AppTheme.Typography.title3, weight: .semibold))
                .foregroundColor(AppTheme.Colors.text)
            
            Text("Try adjusting your search or filters, or create a new project.")
                .font(.system(size: AppTheme.Typography.body))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            PantherButton(
                title: "Create New Project",
                icon: "plus",
                action: {
                    showingAddProject = true
                }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Project Card View

struct ProjectCardView: View {
    let project: Project
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppTheme.Layout.spacingM) {
                // Header with title and status
                HStack {
                    Text(project.title)
                        .font(.system(size: AppTheme.Typography.headline, weight: .bold))
                        .foregroundColor(AppTheme.Colors.text)
                    
                    Spacer()
                    
                    // Status badge
                    HStack(spacing: AppTheme.Layout.spacingXS) {
                        Image(systemName: project.status.icon)
                            .font(.system(size: AppTheme.Typography.caption2))
                        
                        Text(project.status.rawValue)
                            .font(.system(size: AppTheme.Typography.caption2, weight: .medium))
                    }
                    .padding(.horizontal, AppTheme.Layout.spacingS)
                    .padding(.vertical, 4)
                    .background(project.status.color.opacity(0.2))
                    .foregroundColor(project.status.color)
                    .cornerRadius(AppTheme.Layout.cornerRadiusS)
                }
                
                // Description
                Text(project.description)
                    .font(.system(size: AppTheme.Typography.subheadline))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .lineLimit(2)
                
                // Progress bar
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress")
                        .font(.system(size: AppTheme.Typography.caption1))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusS)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            // Progress
                            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusS)
                                .fill(progressColor)
                                .frame(width: geometry.size.width * CGFloat(project.progress), height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    // Progress percentage
                    HStack {
                        Spacer()
                        Text("\(Int(project.progress * 100))%")
                            .font(.system(size: AppTheme.Typography.caption2))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
                
                // Tags
                if !project.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.Layout.spacingXS) {
                            ForEach(project.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: AppTheme.Typography.caption2))
                                    .padding(.horizontal, AppTheme.Layout.spacingS)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.Colors.secondary.opacity(0.1))
                                    .foregroundColor(AppTheme.Colors.secondary)
                                    .cornerRadius(AppTheme.Layout.cornerRadiusS)
                            }
                        }
                    }
                }
                
                // Team members
                if !project.teamMembers.isEmpty {
                    HStack {
                        ForEach(project.teamMembers.prefix(3)) { member in
                            ZStack {
                                Circle()
                                    .fill(AppTheme.Colors.primary)
                                    .frame(width: 30, height: 30)
                                
                                Text(member.name.prefix(1).uppercased())
                                    .font(.system(size: AppTheme.Typography.caption1, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if project.teamMembers.count > 3 {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 30, height: 30)
                                
                                Text("+\(project.teamMembers.count - 3)")
                                    .font(.system(size: AppTheme.Typography.caption2, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.text)
                            }
                        }
                        
                        Spacer()
                        
                        // Updated date
                        Text(formattedDate(project.updatedAt))
                            .font(.system(size: AppTheme.Typography.caption2))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
            }
        }
    }
    
    // Helper properties
    
    private var progressColor: Color {
        if project.progress >= 1.0 {
            return .green
        } else if project.progress >= 0.7 {
            return .blue
        } else if project.progress >= 0.3 {
            return .orange
        } else {
            return .red
        }
    }
    
    // Helper functions
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview
struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectListView(viewModel: ProjectViewModel())
    }
}
