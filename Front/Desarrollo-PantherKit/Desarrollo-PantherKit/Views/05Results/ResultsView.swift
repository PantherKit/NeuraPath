//
//  ResultsView.swift
//  Desarrollo-PantherKit
//
//  Created on 5/12/25.
//

import SwiftUI

struct ResultsView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var animateContent = false
    @State private var showingFieldDetail: EngineeringField?
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            if let result = viewModel.testResult {
                resultContent(result)
            } else {
                Text("No results available")
                    .font(.system(size: AppTheme.Typography.headline))
                    .foregroundColor(AppTheme.Colors.text)
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(item: $showingFieldDetail) { field in
            FieldDetailView(field: field)
        }
    }
    
    // MARK: - Result Content
    
    private func resultContent(_ result: TestResult) -> some View {
        ScrollView {
            VStack(spacing: AppTheme.Layout.spacingXL) {
                // Header with avatar
                VStack(spacing: AppTheme.Layout.spacingM) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(result.avatar.color)
                            .frame(width: 100, height: 100)
                            .shadow(color: result.avatar.color.opacity(0.5), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: result.avatar.imageName)
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .padding(.top, AppTheme.Layout.spacingXL)
                    .opacity(animateContent ? 1 : 0)
                    .scaleEffect(animateContent ? 1 : 0.8)
                    
                    // Title
                    Text("Your Engineering Path")
                        .font(.system(size: AppTheme.Typography.title1, weight: .bold))
                        .foregroundColor(AppTheme.Colors.text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(animateContent ? 1 : 0)
                    
                    // Subtitle with primary field
                    Text("You're a perfect match for \(result.primaryField.rawValue)!")
                        .font(.system(size: AppTheme.Typography.title3, weight: .semibold))
                        .foregroundColor(result.primaryField.color)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(animateContent ? 1 : 0)
                }
                
                // Primary field card
                VStack(spacing: AppTheme.Layout.spacingM) {
                    FieldResultCard(
                        field: result.primaryField,
                        score: result.fieldScores[result.primaryField] ?? 0.0,
                        isPrimary: true,
                        action: {
                            showingFieldDetail = result.primaryField
                        }
                    )
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    
                    // Secondary field card
                    FieldResultCard(
                        field: result.secondaryField,
                        score: result.fieldScores[result.secondaryField] ?? 0.0,
                        isPrimary: false,
                        action: {
                            showingFieldDetail = result.secondaryField
                        }
                    )
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                }
                .padding(.horizontal)
                
                // Personality traits
                VStack(spacing: AppTheme.Layout.spacingM) {
                    Text("Your Key Strengths")
                        .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(animateContent ? 1 : 0)
                    
                    // Traits grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Layout.spacingM) {
                        TraitCard(trait: result.primaryTrait, isPrimary: true)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        TraitCard(trait: result.secondaryTrait, isPrimary: false)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                    }
                }
                .padding(.horizontal)
                
                // Feedback
                VStack(spacing: AppTheme.Layout.spacingM) {
                    Text("What This Means For You")
                        .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(animateContent ? 1 : 0)
                    
                    Text(viewModel.generateFeedback())
                        .font(.system(size: AppTheme.Typography.body))
                        .foregroundColor(AppTheme.Colors.text)
                        .padding(AppTheme.Layout.spacingL)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusL)
                                .fill(AppTheme.Colors.secondaryBackground)
                        )
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                }
                .padding(.horizontal)
                
                // Action buttons
                VStack(spacing: AppTheme.Layout.spacingM) {
                    PantherButton(
                        title: "Explore More Fields",
                        icon: "rectangle.grid.2x2",
                        action: {
                            // In a real app, this would navigate to a screen with more information
                            // about all engineering fields
                        }
                    )
                    .opacity(animateContent ? 1 : 0)
                    
                    Button(action: {
                        viewModel.resetTest()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Take the Test Again")
                            .font(.system(size: AppTheme.Typography.body, weight: .medium))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    .padding(.bottom, AppTheme.Layout.spacingL)
                    .opacity(animateContent ? 1 : 0)
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8)) {
            animateContent = true
        }
    }
}

// MARK: - Field Result Card

struct FieldResultCard: View {
    let field: EngineeringField
    let score: Double
    let isPrimary: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: AppTheme.Layout.spacingM) {
                // Header
                HStack {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(field.color.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: field.icon)
                            .font(.system(size: 20))
                            .foregroundColor(field.color)
                    }
                    
                    // Title
                    VStack(alignment: .leading, spacing: 2) {
                        Text(field.rawValue)
                            .font(.system(size: isPrimary ? AppTheme.Typography.headline : AppTheme.Typography.subheadline, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.text)
                        
                        if isPrimary {
                            Text("Primary Match")
                                .font(.system(size: AppTheme.Typography.caption1))
                                .foregroundColor(field.color)
                        } else {
                            Text("Secondary Match")
                                .font(.system(size: AppTheme.Typography.caption1))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                    }
                    
                    Spacer()
                    
                    // Score
                    ZStack {
                        Circle()
                            .stroke(field.color.opacity(0.3), lineWidth: 4)
                            .frame(width: 50, height: 50)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(score))
                            .stroke(field.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 50, height: 50)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int(score * 100))%")
                            .font(.system(size: AppTheme.Typography.caption1, weight: .bold))
                            .foregroundColor(field.color)
                    }
                }
                
                // Description
                Text(field.description)
                    .font(.system(size: AppTheme.Typography.subheadline))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                
                // Real-world examples
                HStack(spacing: AppTheme.Layout.spacingXS) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: AppTheme.Typography.caption2))
                        .foregroundColor(field.color)
                    
                    Text("Examples: \(field.realWorldExample)")
                        .font(.system(size: AppTheme.Typography.caption1))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                
                // Learn more
                HStack {
                    Spacer()
                    
                    Text("Tap to learn more")
                        .font(.system(size: AppTheme.Typography.caption2))
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: AppTheme.Typography.caption2))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .padding(AppTheme.Layout.spacingL)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusL)
                    .fill(isPrimary ? field.color.opacity(0.1) : AppTheme.Colors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusL)
                            .stroke(isPrimary ? field.color.opacity(0.3) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Trait Card

struct TraitCard: View {
    let trait: PersonalityTrait
    let isPrimary: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.spacingS) {
            // Icon
            HStack(spacing: AppTheme.Layout.spacingXS) {
                Image(systemName: trait.icon)
                    .font(.system(size: AppTheme.Typography.subheadline))
                
                Text(trait.rawValue)
                    .font(.system(size: AppTheme.Typography.subheadline, weight: .semibold))
            }
            .foregroundColor(isPrimary ? AppTheme.Colors.primary : AppTheme.Colors.secondary)
            
            // Description
            Text(trait.description)
                .font(.system(size: AppTheme.Typography.caption1))
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .padding(AppTheme.Layout.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusM)
                .fill(isPrimary ? AppTheme.Colors.primary.opacity(0.1) : AppTheme.Colors.secondary.opacity(0.1))
        )
    }
}

// MARK: - Field Detail View

struct FieldDetailView: View {
    let field: EngineeringField
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Layout.spacingL) {
                    // Header
                    VStack(alignment: .center, spacing: AppTheme.Layout.spacingM) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(field.color.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: field.icon)
                                .font(.system(size: 40))
                                .foregroundColor(field.color)
                        }
                        .padding(.top, AppTheme.Layout.spacingL)
                        
                        // Title
                        Text(field.rawValue)
                            .font(.system(size: AppTheme.Typography.title1, weight: .bold))
                            .foregroundColor(AppTheme.Colors.text)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Description
                    VStack(alignment: .leading, spacing: AppTheme.Layout.spacingM) {
                        Text("What is \(field.rawValue)?")
                            .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.text)
                        
                        Text(field.description)
                            .font(.system(size: AppTheme.Typography.body))
                            .foregroundColor(AppTheme.Colors.text)
                    }
                    .padding(.horizontal)
                    
                    // Real-world examples
                    VStack(alignment: .leading, spacing: AppTheme.Layout.spacingM) {
                        Text("Real-World Applications")
                            .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.text)
                        
                        Text(field.realWorldExample)
                            .font(.system(size: AppTheme.Typography.body))
                            .foregroundColor(AppTheme.Colors.text)
                    }
                    .padding(.horizontal)
                    
                    // Career paths
                    VStack(alignment: .leading, spacing: AppTheme.Layout.spacingM) {
                        Text("Career Paths")
                            .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.text)
                        
                        // This would be expanded in a real app with more detailed information
                        Text("Engineers in this field work in various industries including manufacturing, technology, healthcare, and research. They may work as designers, developers, analysts, or project managers.")
                            .font(.system(size: AppTheme.Typography.body))
                            .foregroundColor(AppTheme.Colors.text)
                    }
                    .padding(.horizontal)
                    
                    // Skills needed
                    VStack(alignment: .leading, spacing: AppTheme.Layout.spacingM) {
                        Text("Key Skills")
                            .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.text)
                        
                        // This would be expanded in a real app with more detailed information
                        Text("Problem-solving, critical thinking, technical knowledge, creativity, teamwork, and communication are all important skills for success in this field.")
                            .font(.system(size: AppTheme.Typography.body))
                            .foregroundColor(AppTheme.Colors.text)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: AppTheme.Layout.spacingXL)
                }
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
            }
        }
    }
}

#Preview {
    let viewModel = VocationalTestViewModel()
    viewModel.selectedAvatar = Avatar.allAvatars.first
    viewModel.testResult = TestResult(
        avatar: Avatar.allAvatars.first!,
        fieldScores: [
            .mechatronics: 0.9,
            .robotics: 0.8,
            .computerScience: 0.7,
            .electrical: 0.6,
            .mechanical: 0.5,
            .industrial: 0.4,
            .biomedical: 0.3,
            .environmental: 0.2
        ],
        traitScores: [
            .analytical: 0.9,
            .creative: 0.8,
            .practical: 0.7,
            .teamPlayer: 0.6,
            .detailOriented: 0.5,
            .bigPictureThinker: 0.4,
            .problemSolver: 0.3,
            .communicator: 0.2
        ]
    )
    return ResultsView(viewModel: viewModel, onContinue: {})
}
