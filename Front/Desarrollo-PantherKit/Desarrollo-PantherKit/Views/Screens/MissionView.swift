//
//  MissionView.swift
//  NeuraPath - Simplified Demo Version
//

import SwiftUI

// MARK: - Mission View Simplified
struct MissionView: View {
    let vocationalViewModel: VocationalTestViewModel
    
    // Demo state
    @State private var currentQuestionIndex = 0
    @State private var showCompletion = false
    @State private var timeRemaining: Double = 30.0
    @State private var isAnimating = false
    @State private var selectedAnswer: String? = nil
    
    // Demo questions
    private let demoQuestions = [
        "¿Qué tipo de problemas prefieres resolver?",
        "¿En qué ambiente te sientes más productivo?", 
        "¿Qué herramienta te resulta más interesante?",
        "¿Qué resultado te emociona más?"
    ]
    
    private let demoOptions = [
        ["Problemas matemáticos complejos", "Problemas de comunicación", "Problemas de diseño"],
        ["Laboratorio silencioso", "Oficina colaborativa", "Espacio al aire libre"],
        ["Microscopio", "Computadora", "Herramientas de construcción"],
        ["Un nuevo descubrimiento", "Una app exitosa", "Un dispositivo útil"]
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
                .ignoresSafeArea()
            
            if showCompletion {
                completionView
            } else {
                missionContent
            }
        }
        .onAppear {
            startDemo()
        }
    }
    
    private var missionContent: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Text("🚀 Misión STEM \(currentQuestionIndex + 1)/\(demoQuestions.count)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Exploración Rápida")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
            }
            .padding(.top, 50)
            
            // Progress bar
            ProgressView(value: Double(currentQuestionIndex), total: Double(demoQuestions.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 8)
                .padding(.horizontal)
            
            // Timer
            ZStack {
                Circle()
                    .stroke(lineWidth: 4)
                    .opacity(0.3)
                    .foregroundColor(.blue)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(timeRemaining / 30.0))
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: 270.0))
                
                Text("\(Int(timeRemaining))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)
            
            Spacer()
            
            // Question
            VStack(spacing: 20) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                
                Text(demoQuestions[currentQuestionIndex])
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Options
            VStack(spacing: 15) {
                ForEach(demoOptions[currentQuestionIndex], id: \.self) { option in
                Button(action: {
                        selectAnswer(option)
                    }) {
                        HStack {
                            Text(option)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(selectedAnswer == option ? .white : .white.opacity(0.8))
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(selectedAnswer == option ? Color.blue : Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .disabled(selectedAnswer != nil)
            }
        }
        .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Success animation
                ZStack {
                    Circle()
                    .fill(Color.green)
                        .frame(width: 120, height: 120)
                    .shadow(color: Color.green.opacity(0.5), radius: 10)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
                
            Text("¡Misión Completada!")
                .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
            Text("Perfil STEM Analizado")
                .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            // Continue button
            Button(action: {
                // Navigate to results
                showCompletion = false
            }) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Ver Resultados")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Demo Logic
    
    private func startDemo() {
        isAnimating = true
        timeRemaining = 30.0
        
        // Auto-advance timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // Auto advance if no answer selected
                if selectedAnswer == nil {
                    selectAnswer(demoOptions[currentQuestionIndex].first ?? "")
                }
                timer.invalidate()
            }
        }
    }
    
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        
        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            nextQuestion()
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < demoQuestions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            timeRemaining = 30.0
            startDemo()
        } else {
            // Show completion
            withAnimation(.easeInOut(duration: 1.0)) {
                showCompletion = true
            }
        }
    }
}

#Preview {
        MissionView(vocationalViewModel: VocationalTestViewModel())
}
