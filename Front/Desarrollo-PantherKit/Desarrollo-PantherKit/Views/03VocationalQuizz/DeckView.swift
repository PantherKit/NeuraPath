//
//  DeckView.swift
//  Desarrollo-PantherKit
//
//  Created by Emiliano Montes on 13/05/25.
//

import SwiftUI
import Foundation

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
    
    // Animation states
    @State private var showContent = false
    @State private var showHeader = false
    @State private var showCards = false
    @State private var showProgress = false
    @State private var progressGlow = false
    
    private let swipeThreshold: CGFloat = 100
    
    var body: some View {
        ZStack {
            // Background will be handled by user
            
            // Main content
            VStack(spacing: 0) {
                // Top navigation header
                SpaceNavigationHeader(
                    number: "03",
                    title: "MISSION CONTROL",
                    subtitle: "Answer questions"
                )
                .opacity(showContent ? 1.0 : 0)
                .offset(y: showContent ? 0 : -20)
                
                Spacer()
                
                // Progress indicator
                SpaceProgressIndicator(
                    currentIndex: activeIndex,
                    totalCount: mbtiMode ? mbtiQuestions.count : cards.count,
                    progressGlow: $progressGlow
                )
                .padding(.horizontal, 24)
                .opacity(showProgress ? 1.0 : 0)
                .offset(y: showProgress ? 0 : -20)
                
                Spacer()
                
                // Question cards
                if mbtiMode {
                    mbtiCardView
                        .opacity(showCards ? 1.0 : 0)
                        .offset(y: showCards ? 0 : 30)
                } else {
                    cardStackView
                        .opacity(showCards ? 1.0 : 0)
                        .offset(y: showCards ? 0 : 30)
                }
                
                Spacer()
                
                // Swipe instructions
                if mbtiMode {
                    spaceSwipeInstructions
                        .opacity(showContent ? 1.0 : 0)
                        .offset(y: showContent ? 0 : 20)
                }
            }
            .padding(.bottom, 40)
            
            // Feedback overlay for MBTI
            if showFeedback {
                SpaceFeedbackOverlay(
                    text: feedbackText,
                    color: feedbackColor
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startSpaceAnimation()
            print("DeckView appeared with \(mbtiQuestions.count) MBTI questions")
        }
    }
    
    // MARK: - Space-style Card Stack View
    private var cardStackView: some View {
        ZStack {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                SpaceQuestionCard(
                    card: card,
                    isActive: index == activeIndex,
                    onSwipedAway: handleSwipe,
                    onShowDetails: { selectedCard = card; showDetails = true }
                )
                .zIndex(Double(cards.count - index))
            }
        }
        .frame(width: 340, height: 480)
    }
    
    // MARK: - MBTI Card View
    private var mbtiCardView: some View {
        let stemCard = mbtiQuestions[activeIndex].toSTEMCard()
        
        return ZStack {
            // Use SpaceQuestionCard with the converted STEMCard
            SpaceQuestionCard(
                card: stemCard,
                isActive: true,
                onSwipedAway: { /* handled by gesture */ },
                onShowDetails: { /* no details for MBTI cards */ }
            )
            
            // Space swipe indicators
            SpaceSwipeIndicators(
                dragOffset: dragOffset,
                swipeThreshold: swipeThreshold
            )
        }
        .frame(width: UIScreen.main.bounds.width - 48, height: 520)
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
    
    private var spaceSwipeInstructions: some View {
        HStack(spacing: 60) {
            VStack(spacing: 8) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 24, weight: .medium, design: .default))
                Text("Opción B")
                    .font(AppTheme.Space.spaceCaption(12))
                    .fontWeight(.medium)
            }
            .foregroundColor(AppTheme.Colors.spaceAlertRed)
            
            VStack(spacing: 8) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 24, weight: .medium, design: .default))
                Text("Opción A")
                    .font(AppTheme.Space.spaceCaption(12))
                    .fontWeight(.medium)
            }
            .foregroundColor(AppTheme.Colors.spaceElectricBlue)
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Animation Functions
    private func startSpaceAnimation() {
        // Main content entrance
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
            showContent = true
        }
        
        // Header entrance
        withAnimation(.easeOut(duration: 1.0).delay(0.6)) {
            showHeader = true
        }
        
        // Progress entrance
        withAnimation(.easeOut(duration: 1.0).delay(0.9)) {
            showProgress = true
        }
        
        // Cards entrance
        withAnimation(.easeOut(duration: 1.0).delay(1.2)) {
            showCards = true
        }
        
        // Progress glow animation
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(2.0)) {
            progressGlow = true
        }
    }
    
    // MARK: - Handler Functions
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
            let selectedRight = value.translation.width > 0
            
            guard activeIndex < mbtiQuestions.count else {
                print("Error: activeIndex (\(activeIndex)) out of bounds for mbtiQuestions.count (\(mbtiQuestions.count))")
                return
            }
            
            let currentQuestion = mbtiQuestions[activeIndex]
            let selectedType = selectedRight ? currentQuestion.optionA.type : currentQuestion.optionB.type
            mbtiResults[selectedType, default: 0] += 1
            
            print("MBTI trait selection recorded: \(selectedType)")
            print("Selected \(selectedRight ? "Option A" : "Option B") for question \(activeIndex + 1)")
            
            // Show feedback
            showFeedback = true
            feedbackText = selectedRight ? "Opción A seleccionada" : "Opción B seleccionada"
            feedbackColor = selectedRight ? AppTheme.Colors.spaceElectricBlue : AppTheme.Colors.spaceAlertRed
            
            // Animate card away
            withAnimation(.spring()) {
                dragOffset = CGSize(
                    width: selectedRight ? 1000 : -1000,
                    height: 0
                )
            }
            
            let nextIndex = activeIndex + 1
            let isComplete = nextIndex >= mbtiQuestions.count
            
            print("Next index will be: \(nextIndex), isComplete: \(isComplete)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.dragOffset = .zero
                
                withAnimation(.spring()) {
                    self.showFeedback = false
                }
                
                if !isComplete {
                    print("Moving to next question: \(nextIndex + 1)/\(self.mbtiQuestions.count)")
                    withAnimation(.easeInOut) {
                        self.activeIndex = nextIndex
                    }
                    print("Active index updated to: \(self.activeIndex)")
                } else {
                    print("MBTI test complete, calling completion handler")
                    if let onComplete = self.onMBTIComplete {
                        onComplete(self.mbtiResults)
                    } else {
                        print("Warning: onMBTIComplete is nil")
                    }
                }
            }
        } else {
            withAnimation(.spring()) {
                dragOffset = .zero
            }
        }
    }
}

// MARK: - Preview
#Preview {
    DeckView(
        onComplete: {},
        viewModel: VocationalTestViewModel()
    )
    .preferredColorScheme(.dark)
}
