//
//  MainTabView.swift
//  Desarrollo-PantherKit
//
//  Created on 5/11/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var vocationalTestViewModel = VocationalTestViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Vocational Test Tab
            WelcomeView(viewModel: vocationalTestViewModel)
                .tabItem {
                    Label("Discover", systemImage: "lightbulb.fill")
                }
                .tag(0)
            
            // Results Tab (Placeholder)
            resultsPlaceholderView
                .tabItem {
                    Label("Results", systemImage: "chart.bar")
                }
                .tag(1)
            
            // About Tab (Placeholder)
            aboutView
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(2)
        }
        .accentColor(AppTheme.Colors.primary)
    }
    
    // MARK: - Placeholder Views
    
    private var resultsPlaceholderView: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppTheme.Layout.spacingL) {
                    // Header
                    Text("Your Results")
                        .font(.system(size: AppTheme.Typography.largeTitle, weight: .bold))
                        .foregroundColor(AppTheme.Colors.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Take the test prompt
                    CardView {
                        VStack(alignment: .center, spacing: AppTheme.Layout.spacingM) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.Colors.primary)
                                .padding(.bottom, AppTheme.Layout.spacingS)
                            
                            Text("Discover Your Engineering Path")
                                .font(.system(size: AppTheme.Typography.headline, weight: .bold))
                                .foregroundColor(AppTheme.Colors.text)
                                .multilineTextAlignment(.center)
                            
                            Text("Take the interactive test to find out which engineering field matches your interests and personality!")
                                .font(.system(size: AppTheme.Typography.body))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, AppTheme.Layout.spacingS)
                            
                            PantherButton(title: "Start Test", action: {
                                selectedTab = 0
                            })
                        }
                        .padding(AppTheme.Layout.spacingL)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
    }
    
    private var aboutView: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.Layout.spacingL) {
                        // Header
                        Text("About")
                            .font(.system(size: AppTheme.Typography.largeTitle, weight: .bold))
                            .foregroundColor(AppTheme.Colors.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // About the app
                        CardView {
                            VStack(alignment: .leading, spacing: AppTheme.Layout.spacingM) {
                                Text("Engineering Discovery")
                                    .font(.system(size: AppTheme.Typography.title2, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.text)
                                
                                Text("This app is designed to help high school students discover engineering fields that match their interests and personality traits through an interactive, mission-based experience.")
                                    .font(.system(size: AppTheme.Typography.body))
                                    .foregroundColor(AppTheme.Colors.text)
                                
                                Text("How it works")
                                    .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.text)
                                    .padding(.top, AppTheme.Layout.spacingS)
                                
                                Text("• Choose your avatar\n• Complete fun engineering missions\n• Discover your engineering field match\n• Learn about different engineering careers")
                                    .font(.system(size: AppTheme.Typography.body))
                                    .foregroundColor(AppTheme.Colors.text)
                                
                                Text("Privacy")
                                    .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.text)
                                    .padding(.top, AppTheme.Layout.spacingS)
                                
                                Text("We respect your privacy. This app collects anonymous data only for improving the test experience. No personal information is stored or shared.")
                                    .font(.system(size: AppTheme.Typography.body))
                                    .foregroundColor(AppTheme.Colors.text)
                            }
                            .padding(AppTheme.Layout.spacingL)
                        }
                        .padding(.horizontal)
                        
                        // Engineering fields
                        VStack(alignment: .leading, spacing: AppTheme.Layout.spacingM) {
                            Text("Engineering Fields")
                                .font(.system(size: AppTheme.Typography.title2, weight: .bold))
                                .foregroundColor(AppTheme.Colors.text)
                                .padding(.horizontal)
                            
                            ForEach(EngineeringField.allCases) { field in
                                CardView {
                                    HStack(spacing: AppTheme.Layout.spacingM) {
                                        // Icon
                                        ZStack {
                                            Circle()
                                                .fill(field.color.opacity(0.2))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: field.icon)
                                                .font(.system(size: 24))
                                                .foregroundColor(field.color)
                                        }
                                        
                                        // Content
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(field.rawValue)
                                                .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                                                .foregroundColor(AppTheme.Colors.text)
                                            
                                            Text(field.description)
                                                .font(.system(size: AppTheme.Typography.subheadline))
                                                .foregroundColor(AppTheme.Colors.secondaryText)
                                                .lineLimit(2)
                                        }
                                    }
                                    .padding(AppTheme.Layout.spacingM)
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Version info
                        Text("Version 1.0.0")
                            .font(.system(size: AppTheme.Typography.caption1))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .padding(.bottom)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
