//
//  MissionView.swift
//  Desarrollo-PantherKit
//
//  Created on 5/12/25.
//

import SwiftUI

struct MissionView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingResults = false
    @State private var animateOptions = false
    @State private var selectedOption: MissionOption?
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                loadingView
            } else if let mission = viewModel.currentMission {
                missionContent(mission)
            } else {
                Text("No missions available")
                    .font(.system(size: AppTheme.Typography.headline))
                    .foregroundColor(AppTheme.Colors.text)
            }
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showingResults) {
            QuickDecisionView(viewModel: viewModel)
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: AppTheme.Layout.spacingL) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Preparing your missions...")
                .font(.system(size: AppTheme.Typography.body))
                .foregroundColor(AppTheme.Colors.text)
        }
    }
    
    // MARK: - Mission Content
    
    private func missionContent(_ mission: Mission) -> some View {
        VStack(spacing: 0) {
            // Header with progress
            VStack(spacing: AppTheme.Layout.spacingS) {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusS)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusS)
                            .fill(AppTheme.Colors.primary)
                            .frame(width: geometry.size.width * viewModel.progress, height: 8)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal)
                
                // Mission count
                HStack {
                    Button(action: {
                        if viewModel.canGoBack {
                            withAnimation {
                                viewModel.previousMission()
                            }
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            
                            Text(viewModel.canGoBack ? "Previous" : "Exit")
                                .font(.system(size: AppTheme.Typography.subheadline))
                        }
                        .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    Spacer()
                    
                    Text("Mission \(viewModel.currentMissionIndex + 1) of \(viewModel.missions.count)")
                        .font(.system(size: AppTheme.Typography.subheadline))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    
                    Spacer()
                    
                    // Placeholder to balance the layout
                    Text("        ")
                        .font(.system(size: AppTheme.Typography.subheadline))
                        .opacity(0)
                }
                .padding(.horizontal)
            }
            .padding(.top, AppTheme.Layout.spacingL)
            
            ScrollView {
                VStack(spacing: AppTheme.Layout.spacingL) {
                    // Mission type badge
                    HStack(spacing: AppTheme.Layout.spacingXS) {
                        Image(systemName: mission.type.icon)
                            .font(.system(size: AppTheme.Typography.caption1))
                        
                        Text(mission.type.rawValue.capitalized)
                            .font(.system(size: AppTheme.Typography.caption1, weight: .medium))
                    }
                    .padding(.horizontal, AppTheme.Layout.spacingM)
                    .padding(.vertical, 6)
                    .background(AppTheme.Colors.secondary.opacity(0.2))
                    .foregroundColor(AppTheme.Colors.secondary)
                    .cornerRadius(AppTheme.Layout.cornerRadiusM)
                    .padding(.top, AppTheme.Layout.spacingL)
                    
                    // Mission title
                    Text(mission.title)
                        .font(.system(size: AppTheme.Typography.title2, weight: .bold))
                        .foregroundColor(AppTheme.Colors.text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Mission description
                    Text(mission.description)
                        .font(.system(size: AppTheme.Typography.body))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Mission image (if available)
                    if let imageName = mission.imageName {
                        Image(systemName: imageName)
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.Colors.primary.opacity(0.8))
                            .padding()
                    }
                    
                    // Options
                    VStack(spacing: AppTheme.Layout.spacingM) {
                        ForEach(mission.options) { option in
                            OptionCardView(
                                option: option,
                                isSelected: viewModel.isOptionSelected(option, for: mission),
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.selectOption(option, for: mission)
                                        selectedOption = option
                                    }
                                }
                            )
                            .opacity(animateOptions ? 1 : 0)
                            .offset(y: animateOptions ? 0 : 20)
                            .animation(
                                .easeOut(duration: 0.4).delay(Double(mission.options.firstIndex(where: { $0.id == option.id }) ?? 0) * 0.1),
                                value: animateOptions
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: AppTheme.Layout.spacingXL)
                }
            }
            
            // Navigation buttons
            HStack {
                Spacer()
                
                PantherButton(
                    title: viewModel.isLastMission ? "See Results" : "Next Mission",
                    icon: viewModel.isLastMission ? "flag.checkered" : "arrow.right",
                    isDisabled: !viewModel.canGoNext,
                    action: {
                        if viewModel.isLastMission {
                            showingResults = true
                        } else {
                            withAnimation {
                                viewModel.nextMission()
                                animateOptions = false
                                
                                // Reset animation for next mission
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation {
                                        animateOptions = true
                                    }
                                }
                            }
                        }
                    }
                )
            }
            .padding()
            .background(
                Rectangle()
                    .fill(AppTheme.Colors.background)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -4)
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    animateOptions = true
                }
            }
        }
    }
}

// MARK: - Option Card View

struct OptionCardView: View {
    let option: MissionOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: AppTheme.Layout.spacingM) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppTheme.Colors.primary : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: 16, height: 16)
                    }
                }
                .padding(.top, 2)
                
                // Option text
                Text(option.text)
                    .font(.system(size: AppTheme.Typography.body))
                    .foregroundColor(AppTheme.Colors.text)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(AppTheme.Layout.spacingM)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusM)
                    .fill(isSelected ? AppTheme.Colors.primary.opacity(0.1) : AppTheme.Colors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusM)
                            .stroke(isSelected ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MissionView(viewModel: VocationalTestViewModel())
}
