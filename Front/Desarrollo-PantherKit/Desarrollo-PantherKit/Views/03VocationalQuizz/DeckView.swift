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
    
    // Enhanced animation states
    @State private var showContent = false
    @State private var showHeader = false
    @State private var showCards = false
    @State private var sparkleAnimation = false
    @State private var showConstellation = false
    @State private var progressGlow = false
    
    private let swipeThreshold: CGFloat = 100
    private let maxRotation: Double = 15
    
    var rotationAngle: Double {
        Double(dragOffset.width / swipeThreshold) * maxRotation
    }
    
    var body: some View {
        ZStack {
            // Magazine-style cosmic background
            MagazineCosmicBackground()
            
            // Dynamic Constellation in upper area
            if showConstellation {
                DynamicConstellation()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 60)
            }
            
            // Main content with magazine layout
            VStack(spacing: 0) {
                // Editorial header section
                VocationalQuizHeader(
                    currentIndex: activeIndex,
                    totalCount: mbtiMode ? mbtiQuestions.count : cards.count,
                    mbtiMode: mbtiMode,
                    progressGlow: $progressGlow
                )
                .opacity(showHeader ? 1.0 : 0)
                .offset(y: showHeader ? 0 : -40)
                
                Spacer()
                
                // Magazine-style card stack
                if mbtiMode {
                    mbtiCardView
                        .opacity(showCards ? 1.0 : 0)
                        .offset(y: showCards ? 0 : 50)
                } else {
                    cardStackView
                        .opacity(showCards ? 1.0 : 0)
                        .offset(y: showCards ? 0 : 50)
                }
                
                Spacer()
                
                // Swipe instructions
                if mbtiMode {
                    mbtiSwipeInstructions
                        .opacity(showContent ? 1.0 : 0)
                        .offset(y: showContent ? 0 : 30)
                }
            }
            .padding(.horizontal, 24)
            
            // Feedback overlay for MBTI
            if showFeedback {
                CosmicFeedbackOverlay(
                    text: feedbackText,
                    color: feedbackColor
                )
            }
            
            // Floating sparkles
            if sparkleAnimation {
                ForEach(0..<15, id: \.self) { i in
                    SparkleParticle(index: i)
                }
            }
        }
        .onAppear {
            startMagazineAnimation()
            print("DeckView appeared with \(mbtiQuestions.count) MBTI questions")
        }
    }
    
    // MARK: - Magazine-style Card Stack View
    private var cardStackView: some View {
        ZStack {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                QuestionGlassCard(
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
            // Use QuestionGlassCard with the converted STEMCard
            QuestionGlassCard(
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
                        .font(.custom("ZonaPro-Bold", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                        .opacity(0.8)
                }
                .opacity(dragOffset.width > 0 ? Double(min(dragOffset.width / swipeThreshold, 1)) : 0)
                .position(x: UIScreen.main.bounds.width * 0.75, y: 100)
                
                // Left swipe indicator
                VStack {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Opción B")
                        .font(.custom("ZonaPro-Bold", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                        .opacity(0.8)
                }
                .opacity(dragOffset.width < 0 ? Double(min(-dragOffset.width / swipeThreshold, 1)) : 0)
                .position(x: UIScreen.main.bounds.width * 0.25, y: 100)
            }
        }
        .frame(width: UIScreen.main.bounds.width - 48, height: 520)
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
        HStack(spacing: 60) {
            VStack(spacing: 8) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 24, weight: .medium))
                Text("Opción B")
                    .font(.custom("ZonaPro-Light", size: 14))
                    .fontWeight(.medium)
            }
            .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 24, weight: .medium))
                Text("Opción A")
                    .font(.custom("ZonaPro-Light", size: 14))
                    .fontWeight(.medium)
            }
            .foregroundColor(.green)
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Animation Functions
    private func startMagazineAnimation() {
        // Elegant entrance sequence
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
            showContent = true
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6)) {
            showHeader = true
        }
        
        withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(1.0)) {
            showCards = true
        }
        
        // Sparkles appear after main content
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            sparkleAnimation = true
        }
        
        // Constellation appears elegantly
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 1.5)) {
                showConstellation = true
            }
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
            feedbackColor = selectedRight ? .green : .blue
            
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

// MARK: - Vocational Quiz Header
struct VocationalQuizHeader: View {
    let currentIndex: Int
    let totalCount: Int
    let mbtiMode: Bool
    @Binding var progressGlow: Bool
    
    private var progressPercentage: Double {
        Double(currentIndex + 1) / Double(totalCount)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Main title with editorial typography
            VStack(spacing: 16) {
                Text(mbtiMode ? "Discover Your\nPersonality Type" : "Explore STEM\nCareer Paths")
                    .font(.custom("ZonaPro-Bold", size: 36))
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .tracking(0.5)
                    .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.3), radius: 15, x: 0, y: 5)
                
                // Elegant subtitle
                Text(mbtiMode ? "Understanding your MBTI preferences\nhelps us match you with the perfect STEM career" : "Swipe through career options to discover\nwhat resonates with your interests")
                    .font(.custom("ZonaPro-Light", size: 16))
                    .fontWeight(.light)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .tracking(0.5)
            }
            
            // Magazine-style progress section
            VStack(spacing: 16) {
                // Progress metrics
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Progress")
                            .font(.custom("ZonaPro-Light", size: 12))
                            .fontWeight(.regular)
                            .foregroundColor(.white.opacity(0.65))
                            .tracking(0.5)
                        
                        Text("\(currentIndex + 1) of \(totalCount)")
                            .font(.custom("ZonaPro-Bold", size: 20))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .tracking(-1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("Completion")
                            .font(.custom("ZonaPro-Light", size: 12))
                            .fontWeight(.regular)
                            .foregroundColor(.white.opacity(0.65))
                            .tracking(0.5)
                        
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.custom("ZonaPro-Bold", size: 24))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .tracking(-1)
                    }
                }
                
                // Cosmic progress bar
                ProgressCosmicBar(progress: progressPercentage, progressGlow: $progressGlow)
            }
        }
        .padding(32)
        .background {
            // Authentic glass morphism
            ZStack {
                // Base glass layer
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.6)
                
                // Secondary glass layer for depth
                RoundedRectangle(cornerRadius: 24)
                    .fill(.thinMaterial)
                    .opacity(0.3)
                
                // Glass tint with cosmic colors
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.Colors.cosmicCyan.opacity(0.06),
                                AppTheme.Colors.cosmicBlue.opacity(0.03),
                                Color.clear,
                                AppTheme.Colors.cosmicPurple.opacity(0.02)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 300
                        )
                    )
                
                // Natural light reflection
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.06),
                                Color.clear,
                                Color.clear,
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Sophisticated border
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
            .shadow(color: Color.black.opacity(0.3), radius: 25, x: 0, y: 12)
            .shadow(color: AppTheme.Colors.cosmicBlue.opacity(0.15), radius: 35, x: 0, y: 18)
        }
    }
}

// MARK: - Progress Cosmic Bar
struct ProgressCosmicBar: View {
    let progress: Double
    @Binding var progressGlow: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress bar background
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 8)
                .overlay(
                    // Progress fill
                    HStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppTheme.Colors.cosmicCyan.opacity(0.8),
                                        AppTheme.Colors.cosmicBlue.opacity(0.6)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: UIScreen.main.bounds.width * 0.6 * progress)
                            .scaleEffect(x: progress, anchor: .leading)
                            .shadow(
                                color: progressGlow ? 
                                AppTheme.Colors.cosmicCyan.opacity(0.6) : 
                                AppTheme.Colors.cosmicCyan.opacity(0.3),
                                radius: progressGlow ? 8 : 4, x: 0, y: 0
                            )
                        
                        Spacer()
                    }
                )
                .overlay(
                    // Glass overlay
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                )
        }
    }
}

// MARK: - Cosmic Feedback Overlay
struct CosmicFeedbackOverlay: View {
    let text: String
    let color: Color
    
    var body: some View {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(color)
                        .shadow(color: color.opacity(0.6), radius: 10, x: 0, y: 0)
                    
                    Text(text)
                        .font(.custom("ZonaPro-Bold", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(color)
                        .multilineTextAlignment(.center)
                }
                .padding(32)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .opacity(0.9)
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                }
            )
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
