//
//  MainTabView.swift
//  Desarrollo-PantherKit
//
//  Created on 5/11/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var projectViewModel = ProjectViewModel()
    @StateObject private var vocationalTestViewModel = VocationalTestViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Vocational Test Tab
            WelcomeView(viewModel: vocationalTestViewModel)
                .tabItem {
                    Label("Discover", systemImage: "lightbulb.fill")
                }
                .tag(0)
            
            // Projects Tab
            ProjectListView(viewModel: projectViewModel)
                .tabItem {
                    Label("Projects", systemImage: "folder")
                }
                .tag(1)
            
            // Dashboard Tab (Placeholder)
            dashboardView
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
                .tag(2)
            
            // Team Tab (Placeholder)
            teamView
                .tabItem {
                    Label("Team", systemImage: "person.3")
                }
                .tag(3)
            
            // Settings Tab (Placeholder)
            settingsView
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .accentColor(AppTheme.Colors.primary)
    }
    
    // MARK: - Placeholder Views
    
    private var dashboardView: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppTheme.Layout.spacingL) {
                    // Header
                    Text("Dashboard")
                        .font(.system(size: AppTheme.Typography.largeTitle, weight: .bold))
                        .foregroundColor(AppTheme.Colors.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Stats Cards
                    HStack(spacing: AppTheme.Layout.spacingM) {
                        statCard(title: "Active", value: "3", icon: "arrow.triangle.2.circlepath", color: .blue)
                        statCard(title: "Completed", value: "12", icon: "checkmark.circle", color: .green)
                    }
                    .padding(.horizontal)
                    
                    // Chart Placeholder
                    CardView {
                        VStack(alignment: .leading, spacing: AppTheme.Layout.spacingM) {
                            Text("Project Progress")
                                .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.text)
                            
                            // Placeholder for chart
                            ZStack {
                                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusS)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 200)
                                
                                Text("Chart Placeholder")
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: AppTheme.Layout.spacingM) {
                        Text("Recent Activity")
                            .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.text)
                            .padding(.horizontal)
                        
                        // Activity list
                        CardView {
                            VStack(spacing: AppTheme.Layout.spacingM) {
                                activityItem(
                                    title: "Project Updated",
                                    description: "Smart City Solution was updated",
                                    time: "2h ago",
                                    icon: "pencil",
                                    color: .blue
                                )
                                
                                Divider()
                                
                                activityItem(
                                    title: "New Team Member",
                                    description: "Jamie Smith joined Health Monitoring App",
                                    time: "5h ago",
                                    icon: "person.badge.plus",
                                    color: .green
                                )
                                
                                Divider()
                                
                                activityItem(
                                    title: "Project Completed",
                                    description: "Educational Platform marked as completed",
                                    time: "1d ago",
                                    icon: "checkmark.circle",
                                    color: .purple
                                )
                            }
                            .padding(0)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
    }
    
    private var teamView: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppTheme.Layout.spacingL) {
                    // Header
                    Text("Team")
                        .font(.system(size: AppTheme.Typography.largeTitle, weight: .bold))
                        .foregroundColor(AppTheme.Colors.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Team members list
                    ScrollView {
                        VStack(spacing: AppTheme.Layout.spacingM) {
                            teamMemberCard(
                                name: "Alex Johnson",
                                role: "Project Lead",
                                projects: 3,
                                color: .blue
                            )
                            
                            teamMemberCard(
                                name: "Maria Garcia",
                                role: "IoT Developer",
                                projects: 2,
                                color: .purple
                            )
                            
                            teamMemberCard(
                                name: "Sam Lee",
                                role: "UI/UX Designer",
                                projects: 4,
                                color: .orange
                            )
                            
                            teamMemberCard(
                                name: "Chris Wong",
                                role: "Health Specialist",
                                projects: 1,
                                color: .green
                            )
                            
                            teamMemberCard(
                                name: "Jamie Smith",
                                role: "Mobile Developer",
                                projects: 2,
                                color: .red
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
    }
    
    private var settingsView: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppTheme.Layout.spacingL) {
                    // Header
                    Text("Settings")
                        .font(.system(size: AppTheme.Typography.largeTitle, weight: .bold))
                        .foregroundColor(AppTheme.Colors.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Settings list
                    VStack(spacing: 1) {
                        settingItem(title: "Account", icon: "person.circle")
                        settingItem(title: "Notifications", icon: "bell")
                        settingItem(title: "Appearance", icon: "paintbrush")
                        settingItem(title: "Privacy", icon: "lock.shield")
                        settingItem(title: "Help & Support", icon: "questionmark.circle")
                        settingItem(title: "About", icon: "info.circle")
                    }
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(AppTheme.Layout.cornerRadiusM)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Version info
                    Text("Version 1.0.0")
                        .font(.system(size: AppTheme.Typography.caption1))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .padding(.bottom)
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Helper Views
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: AppTheme.Layout.spacingS) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Spacer()
                
                // Value
                Text(value)
                    .font(.system(size: AppTheme.Typography.title1, weight: .bold))
                    .foregroundColor(AppTheme.Colors.text)
                
                // Title
                Text(title)
                    .font(.system(size: AppTheme.Typography.subheadline))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
            .frame(height: 120)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func activityItem(title: String, description: String, time: String, icon: String, color: Color) -> some View {
        HStack(spacing: AppTheme.Layout.spacingM) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: AppTheme.Typography.subheadline, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.text)
                
                Text(description)
                    .font(.system(size: AppTheme.Typography.caption1))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
            
            Spacer()
            
            // Time
            Text(time)
                .font(.system(size: AppTheme.Typography.caption2))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .padding(0)
    }
    
    private func teamMemberCard(name: String, role: String, projects: Int, color: Color) -> some View {
        CardView {
            HStack(spacing: AppTheme.Layout.spacingM) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Text(name.prefix(1).uppercased())
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(color)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.text)
                    
                    Text(role)
                        .font(.system(size: AppTheme.Typography.subheadline))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    Text("\(projects) \(projects == 1 ? "project" : "projects")")
                        .font(.system(size: AppTheme.Typography.caption1))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .padding(.top, 2)
                }
                
                Spacer()
                
                // Contact button
                Button(action: {}) {
                    Image(systemName: "envelope")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(12)
                        .background(AppTheme.Colors.primary.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private func settingItem(title: String, icon: String) -> some View {
        Button(action: {}) {
            HStack(spacing: AppTheme.Layout.spacingM) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(width: 24)
                
                // Title
                Text(title)
                    .font(.system(size: AppTheme.Typography.body))
                    .foregroundColor(AppTheme.Colors.text)
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
            .padding(AppTheme.Layout.spacingM)
            .background(AppTheme.Colors.background)
        }
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
