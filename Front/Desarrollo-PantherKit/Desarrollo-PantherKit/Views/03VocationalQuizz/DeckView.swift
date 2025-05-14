//
//  DeckView.swift
//  Desarrollo-PantherKit
//
//  Created by Emiliano Montes on 13/05/25.
//

import SwiftUI

struct DeckView: View {
    var onComplete: () -> Void
    var mbtiMode: Bool = false
    var mbtiQuestions: [MBTICard] = []
    var onMBTIComplete: (([MBTICard.MBTIType: Int]) -> Void)? = nil
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var cards: [STEMCard] = STEMCard.sampleData
    @State private var activeIndex: Int = 0
    @State private var showDetails = false
    @State private var selectedCard: STEMCard? = nil
    @State private var mbtiResults = [MBTICard.MBTIType: Int]()
    @State private var dragOffset = CGSize.zero
    @State private var showFeedback = false
    @State private var feedbackText = ""
    @State private var feedbackColor = Color.green
    
    // Colores del tema
    private let accentColor = Color(red: 0.25, green: 0.72, blue: 0.85)
    private let secondaryColor = Color(red: 0.2, green: 0.6, blue: 1.0)
    private let swipeThreshold: CGFloat = 100
    private let maxRotation: Double = 15
    
    var rotationAngle: Double {
        Double(dragOffset.width / swipeThreshold) * maxRotation
    }
    
    var body: some View {
        ZStack {
            // Fondo espacial
            spaceBackground
            
            VStack {
                // Header con progreso
                if mbtiMode {
                    mbtiProgressHeader
                } else {
                    progressHeader
                }
                
                Spacer()
                
                // Stack de cards
                if mbtiMode {
                    mbtiCardView
                } else {
                    cardStackView
                }
                
                Spacer()
                
            }
            
            // Feedback overlay para MBTI
            if showFeedback {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .overlay(
                        Text(feedbackText)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(feedbackColor)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                    )
            }
        }
        .sheet(isPresented: $showDetails) {
            if let card = selectedCard {
                CardDetailView(card: card)
            }
        }
        .onAppear {
            print("DeckView appeared with \(mbtiQuestions.count) MBTI questions")
        }
    }
    
    // MARK: - Componentes Comunes
    
    private var spaceBackground: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Estrellas
            ForEach(0..<100) { _ in
                Circle()
                    .fill(Color.white)
                    .frame(width: CGFloat.random(in: 1...3))
                    .opacity(Double.random(in: 0.1...0.8))
                    .position(
                        x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0..<UIScreen.main.bounds.height)
                    )
            }
            
            // Nébulas
            ForEach(0..<3) { i in
                let colors: [Color] = [
                    Color(red: 0.5, green: 0.2, blue: 0.8),
                    Color(red: 0.1, green: 0.4, blue: 0.9),
                    Color(red: 0.3, green: 0.8, blue: 0.9)
                ]
                
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                colors[i % colors.count].opacity(0.2),
                                colors[i % colors.count].opacity(0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 300, height: 300)
                    .position(
                        x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0..<UIScreen.main.bounds.height)
                    )
                    .blur(radius: 60)
            }
        }
    }
    
    // MARK: - Componentes STEM
    
    private var progressHeader: some View {
        HStack {
            Text("Explora Carreras STEM")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(activeIndex + 1)/\(cards.count)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
    }
    
    private var cardStackView: some View {
        ZStack {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                CardView(
                    card: card,
                    isActive: index == activeIndex,
                    onSwipedAway: handleSwipe,
                    onShowDetails: { selectedCard = card; showDetails = true }
                )
                .zIndex(Double(cards.count - index))
            }
        }
        .frame(width: 320, height: 450)
    }
    
    
    // MARK: - Componentes MBTI
    
    private var mbtiProgressHeader: some View {
        HStack {
            Text("Test de Personalidad MBTI")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(activeIndex + 1)/\(mbtiQuestions.count)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
    }
    
    private var mbtiCardView: some View {
        // Convert MBTI question to STEMCard for consistent UI
        let stemCard = mbtiQuestions[activeIndex].toSTEMCard()
        
        return ZStack {
            // Use CardView with the converted STEMCard
            CardView(
                card: stemCard,
                isActive: true,
                onSwipedAway: { /* handled by gesture */ },
                onShowDetails: { /* no details for MBTI cards */ }
            )
            
            // Swipe indicators
            Group {
                // Right swipe indicator
                VStack {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Opción A")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .opacity(dragOffset.width > 0 ? Double(min(dragOffset.width / swipeThreshold, 1)) : 0)
                .position(x: UIScreen.main.bounds.width * 0.75, y: 100)
                
                // Left swipe indicator
                VStack {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Opción B")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .opacity(dragOffset.width < 0 ? Double(min(-dragOffset.width / swipeThreshold, 1)) : 0)
                .position(x: UIScreen.main.bounds.width * 0.25, y: 100)
            }
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 500)
        .rotationEffect(.degrees(rotationAngle))
        .offset(dragOffset)
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    withAnimation(.interactiveSpring()) {
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    handleMBTISwipe(value)
                }
        )
    }
    
    private var mbtiSwipeInstructions: some View {
        HStack(spacing: 50) {
            VStack {
                Image(systemName: "arrow.left")
                    .font(.system(size: 24))
                Text("Opción B")
                    .font(.caption)
            }
            .foregroundColor(.blue)
            
            VStack {
                Image(systemName: "arrow.right")
                    .font(.system(size: 24))
                Text("Opción A")
                    .font(.caption)
            }
            .foregroundColor(.green)
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - Funciones
    
    private func handleSwipe() {
        if activeIndex < cards.count - 1 {
            withAnimation(.spring()) {
                activeIndex += 1
            }
        } else {
            onComplete()
        }
    }
    
    private func swipeCard(accepted: Bool) {
        guard activeIndex < cards.count else { return }
        
        // Aquí podrías registrar la selección del usuario
        if accepted {
            print("Aceptado: \(cards[activeIndex].title)")
        }
        
        withAnimation(.spring()) {
            handleSwipe()
        }
    }
    
    private func mbtiToTrait(_ type: MBTICard.MBTIType) -> PersonalityTrait? {
        switch type {
        case .I: return .detailOriented
        case .E: return .communicator
        case .S: return .practical
        case .N: return .creative
        case .T: return .analytical
        case .F: return .teamPlayer
        case .J: return .problemSolver
        case .P: return .bigPictureThinker
        }
    }
    
  private func handleMBTISwipe(_ value: DragGesture.Value) {
    print("Handling MBTI swipe, current index: \(activeIndex)/\(mbtiQuestions.count)")
    
    if abs(value.translation.width) > swipeThreshold {
        // Determine which option was selected
        let selectedRight = value.translation.width > 0
        
        // Verificar que el índice sea válido
        guard activeIndex < mbtiQuestions.count else {
            print("Error: activeIndex (\(activeIndex)) out of bounds for mbtiQuestions.count (\(mbtiQuestions.count))")
            return
        }
        
        let currentQuestion = mbtiQuestions[activeIndex]
        
        // Record the selected MBTI type
        let selectedType = selectedRight ? currentQuestion.optionA.type : currentQuestion.optionB.type
        mbtiResults[selectedType, default: 0] += 1
        
        if let trait = mbtiToTrait(selectedType) {
            viewModel.updateTraitScore(trait, by: 1.0)
        }
        
        print("Selected \(selectedRight ? "Option A" : "Option B") for question \(activeIndex + 1)")
        
        // Show feedback
        showFeedback = true
        feedbackText = selectedRight ? "Opción A seleccionada" : "Opción B seleccionada"
        feedbackColor = selectedRight ? .green : .blue
        
        // Animate card away
        withAnimation(.spring()) {
            dragOffset = CGSize(
                width: selectedRight ? 1000 : -1000,
                height: 0
            )
        }
        
        // Store the next index to move to
        let nextIndex = activeIndex + 1
        let isComplete = nextIndex >= mbtiQuestions.count
        
        print("Next index will be: \(nextIndex), isComplete: \(isComplete)")
        
        // Reducir el retraso para una respuesta más rápida y asegurar que se ejecute
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Reset drag offset first
            self.dragOffset = .zero
            
            // Hide feedback
            withAnimation(.spring()) {
                self.showFeedback = false
            }
            
            // Check if there are more questions
            if !isComplete {
                print("Moving to next question: \(nextIndex + 1)/\(self.mbtiQuestions.count)")
                // Actualizar el índice inmediatamente
                withAnimation(.easeInOut) {
                    self.activeIndex = nextIndex
                }
                print("Active index updated to: \(self.activeIndex)")
            } else {
                // Test complete
                print("MBTI test complete, calling completion handler")
                // Asegurarse de que el callback se ejecute
                if let onComplete = self.onMBTIComplete {
                    onComplete(self.mbtiResults)
                } else {
                    print("Warning: onMBTIComplete is nil")
                }
            }
        }
    } else {
        // Not enough to trigger a selection, reset position
        withAnimation(.spring()) {
            dragOffset = .zero
        }
    }
}

}
