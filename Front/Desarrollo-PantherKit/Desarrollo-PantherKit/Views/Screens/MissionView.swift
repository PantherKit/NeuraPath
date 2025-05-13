//
//  MissionView.swift
//  Desarrollo-PantherKit
//
//  Created on 5/13/25.
//

import SwiftUI

// MARK: - Mission View
struct MissionView: View {
    @StateObject private var viewModel: MissionViewModel
    
    init(vocationalViewModel: VocationalTestViewModel) {
        _viewModel = StateObject(wrappedValue: MissionViewModel(vocationalViewModel: vocationalViewModel))
    }
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.Layout.spacingL) {
                // Header with progress and timer
                headerView
                
                // Progress bar
                progressBarView
                
                // Challenge icon and title
                challengeIconAndTitleView
                
                // Challenge description
                Text(viewModel.currentChallenge.description)
                    .font(.system(size: AppTheme.Typography.body))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                // Options
                optionsListView
                
                Spacer()
            }
            .padding(.vertical, AppTheme.Layout.spacingL)
            .onAppear {
                viewModel.startTimer()
                viewModel.updateProgressBar()
                viewModel.isAnimating = true
            }
            .onDisappear {
                viewModel.stopTimer()
            }
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .ignoresSafeArea(.all, edges: .bottom)
            
            // Feedback overlay
            if viewModel.showFeedback {
                feedbackOverlayView
            }
            
            // Completion animation overlay
            if viewModel.showCompletionAnimation {
                completionAnimationView
            }
        }
        .fullScreenCover(isPresented: $viewModel.showNextScreen) {
            // Navigate to the results view
            GalaxyResultsView(viewModel: viewModel.vocationalViewModel)
        }
    }
    
    // MARK: - Component Views
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Misión STEM \(viewModel.currentChallengeIndex + 1)/\(viewModel.challenges.count)")
                    .font(.system(size: AppTheme.Typography.headline, weight: .bold))
                    .foregroundColor(AppTheme.Colors.text)
                
                Text(viewModel.currentChallenge.type.category)
                    .font(.system(size: AppTheme.Typography.subheadline))
                    .foregroundColor(viewModel.currentChallenge.type.color)
            }
            
            Spacer()
            
            // Timer display
            ZStack {
                Circle()
                    .stroke(lineWidth: 4)
                    .opacity(0.3)
                    .foregroundColor(viewModel.currentChallenge.type.color)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(viewModel.timeRemaining / viewModel.currentChallenge.timeLimit))
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .foregroundColor(viewModel.timeRemaining > viewModel.currentChallenge.timeLimit * 0.3 ? viewModel.currentChallenge.type.color : AppTheme.Colors.warning)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: viewModel.timeRemaining)
                
                Text("\(Int(viewModel.timeRemaining))")
                    .font(.system(size: AppTheme.Typography.headline, weight: .bold))
                    .foregroundColor(viewModel.timeRemaining > viewModel.currentChallenge.timeLimit * 0.3 ? viewModel.currentChallenge.type.color : AppTheme.Colors.warning)
            }
            .frame(width: 50, height: 50)
        }
        .padding(.horizontal)
    }
    
    private var progressBarView: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .frame(height: 8)
                .opacity(0.3)
                .foregroundColor(viewModel.currentChallenge.type.color)
            
            Rectangle()
                .frame(width: viewModel.progress, height: 8)
                .foregroundColor(viewModel.currentChallenge.type.color)
                .animation(.linear, value: viewModel.progress)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusS))
        .padding(.horizontal)
    }
    
    private var challengeIconAndTitleView: some View {
        VStack(spacing: AppTheme.Layout.spacingM) {
            ZStack {
                Circle()
                    .fill(viewModel.currentChallenge.type.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: viewModel.currentChallenge.type.icon)
                    .font(.system(size: 40))
                    .foregroundColor(viewModel.currentChallenge.type.color)
                    .symbolEffect(.pulse, options: .repeating)
            }
            
            Text(viewModel.currentChallenge.title)
                .font(.system(size: AppTheme.Typography.title2, weight: .bold))
                .foregroundColor(AppTheme.Colors.text)
                .multilineTextAlignment(.center)
                .scaleEffect(viewModel.isAnimating ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: viewModel.isAnimating)
        }
    }
    
    private var optionsListView: some View {
        VStack(spacing: AppTheme.Layout.spacingM) {
            ForEach(viewModel.currentChallenge.options) { option in
                Button(action: {
                    viewModel.selectOption(option)
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusL)
                            .fill(viewModel.selectedOption == option.id ? viewModel.currentChallenge.type.color : AppTheme.Colors.secondaryBackground)
                            .frame(height: 70)
                            .shadow(radius: 5)
                        
                        HStack {
                            Text(option.text)
                                .font(.system(size: AppTheme.Typography.body, weight: .medium))
                                .foregroundColor(viewModel.selectedOption == option.id ? .white : AppTheme.Colors.text)
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                            
                            Spacer()
                            
                            if viewModel.showFeedback && viewModel.selectedOption == option.id {
                                Image(systemName: option.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(.trailing)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .disabled(viewModel.showFeedback)
            }
        }
        .padding(.horizontal)
    }
    
    private var feedbackOverlayView: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack {
                Image(systemName: viewModel.isCorrect ? "star.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(viewModel.isCorrect ? .yellow : .orange)
                    .scaleEffect(viewModel.isAnimating ? 1.2 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: viewModel.isAnimating)
            }
        }
    }
    
    private var completionAnimationView: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.success)
                        .frame(width: 120, height: 120)
                        .shadow(color: AppTheme.Colors.success.opacity(0.5), radius: 10)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .symbolEffect(.bounce, options: .repeating)
                }
                
                Text("¡Misiones Completadas!")
                    .font(.system(size: AppTheme.Typography.title1, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Perfil STEM Completo")
                    .font(.system(size: AppTheme.Typography.headline))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct MissionView_Previews: PreviewProvider {
    static var previews: some View {
        MissionView(vocationalViewModel: VocationalTestViewModel())
    }
}
