//
//  QuickDecisionView.swift
//  Desarrollo-PantherKit
//
//  Created on 5/12/25.
//

import SwiftUI

struct QuickDecisionView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var timeRemaining: Double = 5.0
    @State private var timer: Timer?
    @State private var currentQuestion = 0
    @State private var selectedOption: Int?
    @State private var showFeedback = false
    @State private var feedbackImage = "star.fill"
    @State private var feedbackColor = Color.yellow
    @State private var isAnimating = false
    @State private var progress: CGFloat = 0.0
    @State private var showNextScreen = false
    
    private let questions = [
        "¿Prefieres construir o programar?",
        "¿Trabajar solo o en equipo?",
        "¿Resolver problemas teóricos o prácticos?",
        "¿Diseñar o analizar?",
        "¿Innovar o perfeccionar?"
    ]
    
    private let options = [
        ["Construir", "Programar"],
        ["Solo", "En equipo"],
        ["Teóricos", "Prácticos"],
        ["Diseñar", "Analizar"],
        ["Innovar", "Perfeccionar"]
    ]
    
    private let optionIcons = [
        ["hammer.fill", "laptopcomputer"],
        ["person", "person.3"],
        ["brain", "wrench.and.screwdriver"],
        ["paintbrush.pointed", "chart.bar"],
        ["lightbulb", "gearshape.2"]
    ]
    
    private let traits = [
        [PersonalityTrait.practical, PersonalityTrait.analytical],
        [PersonalityTrait.detailOriented, PersonalityTrait.teamPlayer],
        [PersonalityTrait.bigPictureThinker, PersonalityTrait.problemSolver],
        [PersonalityTrait.creative, PersonalityTrait.analytical],
        [PersonalityTrait.creative, PersonalityTrait.detailOriented]
    ]
    
    private let fields = [
        [EngineeringField.mechanical, EngineeringField.computerScience],
        [EngineeringField.electrical, EngineeringField.industrial],
        [EngineeringField.computerScience, EngineeringField.mechatronics],
        [EngineeringField.biomedical, EngineeringField.industrial],
        [EngineeringField.robotics, EngineeringField.mechanical]
    ]
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.Layout.spacingL) {
                // Header with progress
                HStack {
                    Text("Decisión Rápida")
                        .font(.system(size: AppTheme.Typography.title1, weight: .bold))
                        .foregroundColor(AppTheme.Colors.text)
                    
                    Spacer()
                    
                    // Timer display
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 4)
                            .opacity(0.3)
                            .foregroundColor(AppTheme.Colors.primary)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(timeRemaining / 5.0))
                            .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                            .foregroundColor(timeRemaining > 2 ? AppTheme.Colors.primary : AppTheme.Colors.warning)
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(.linear, value: timeRemaining)
                        
                        Text("\(Int(timeRemaining))")
                            .font(.system(size: AppTheme.Typography.headline, weight: .bold))
                            .foregroundColor(timeRemaining > 2 ? AppTheme.Colors.primary : AppTheme.Colors.warning)
                    }
                    .frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                
                // Progress bar
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(height: 8)
                        .opacity(0.3)
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    Rectangle()
                        .frame(width: progress, height: 8)
                        .foregroundColor(AppTheme.Colors.primary)
                        .animation(.linear, value: progress)
                }
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusS))
                .padding(.horizontal)
                
                // Mission progress
                Text("Misión \(currentQuestion + 1) de 5")
                    .font(.system(size: AppTheme.Typography.subheadline))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                
                Spacer()
                
                // Question
                Text(questions[currentQuestion])
                    .font(.system(size: AppTheme.Typography.title2, weight: .bold))
                    .foregroundColor(AppTheme.Colors.text)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimating)
                    .onAppear {
                        isAnimating = true
                    }
                
                Spacer()
                
                // Options
                VStack(spacing: AppTheme.Layout.spacingL) {
                    ForEach(0..<2) { index in
                        Button(action: {
                            selectOption(index)
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusL)
                                    .fill(selectedOption == index ? AppTheme.Colors.primary : AppTheme.Colors.secondaryBackground)
                                    .frame(height: 80)
                                    .shadow(radius: 5)
                                
                                HStack {
                                    Image(systemName: optionIcons[currentQuestion][index])
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedOption == index ? .white : AppTheme.Colors.primary)
                                    
                                    Text(options[currentQuestion][index])
                                        .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                                        .foregroundColor(selectedOption == index ? .white : AppTheme.Colors.text)
                                }
                            }
                        }
                        .disabled(showFeedback)
                        .scaleEffect(selectedOption == index && showFeedback ? 1.05 : 1.0)
                        .animation(.spring(), value: selectedOption)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical, AppTheme.Layout.spacingL)
            .onAppear {
                startTimer()
                updateProgressBar()
            }
            .onDisappear {
                timer?.invalidate()
            }
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .ignoresSafeArea(.all, edges: .bottom)
            
            // Feedback overlay
            if showFeedback {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack {
                    Image(systemName: feedbackImage)
                        .font(.system(size: 80))
                        .foregroundColor(feedbackColor)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
                }
            }
        }
        // Temporalmente comentado hasta que se defina la siguiente vista
        // .fullScreenCover(isPresented: $showNextScreen) {
        //     // Aquí irá la siguiente vista
        // }
        .onAppear {
            // Asegurarse de que la vista se muestra correctamente después de la transición
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Haptic feedback para indicar que la nueva vista está lista
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        }
    }
    
    private func startTimer() {
        timeRemaining = 5.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                // Time's up, auto-select if user hasn't chosen
                if selectedOption == nil {
                    selectOption(Int.random(in: 0...1))
                }
            }
        }
    }
    
    private func updateProgressBar() {
        withAnimation {
            progress = UIScreen.main.bounds.width - 32 * CGFloat(currentQuestion + 1) / 5.0
        }
    }
    
    private func selectOption(_ index: Int) {
        selectedOption = index
        timer?.invalidate()
        
        // Record the selection
        let selectedTrait = traits[currentQuestion][index]
        let selectedField = fields[currentQuestion][index]
        
        viewModel.updateTraitScore(selectedTrait, by: 0.8)
        viewModel.updateFieldScore(selectedField, by: 0.8)
        
        // Show feedback
        showFeedback = true
        
        // Set feedback style based on selection
        if index == 0 {
            feedbackImage = "star.fill"
            feedbackColor = .yellow
        } else {
            feedbackImage = "bolt.fill"
            feedbackColor = .blue
        }
        
        // Move to next question or finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showFeedback = false
            
            if currentQuestion < questions.count - 1 {
                currentQuestion += 1
                selectedOption = nil
                updateProgressBar()
                startTimer()
            } else {
                // All questions answered, move to next screen
                showNextScreen = true
            }
        }
    }
}

struct QuickDecisionView_Previews: PreviewProvider {
    static var previews: some View {
        QuickDecisionView(viewModel: VocationalTestViewModel())
    }
}
