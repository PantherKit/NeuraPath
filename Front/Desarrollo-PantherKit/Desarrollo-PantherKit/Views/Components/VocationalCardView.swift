//
//  VocationalCardView.swift
//  Desarrollo-PantherKit
//
//  Created on 5/12/25.
//

import SwiftUI

struct VocationalCardView: View {
    // Mission and option data
    let mission: Mission
    let onSwipedAway: (MissionOption) -> Void
    
    // UI State
    @State private var dragOffset = CGSize.zero
    @State private var isGone = false
    @State private var isDragging = false
    @State private var cardScale: CGFloat = 0.95
    @State private var cardOpacity: Double = 0
    @State private var showOptions = false
    
    // Animation timing
    @State private var animationDelay = 0.0
    
    // Constants
    private let horizontalLimit: CGFloat = 120
    private let maxRotationDegrees: Double = 12
    private let swipeThreshold: CGFloat = 80
    
    // App theme colors
    private let primaryColor = Color(hex: "D8F3DC") // Nyanza
    private let secondaryColor = Color(hex: "B7E4C7") // Celadon
    
    // Computed properties
    private var rotationAngle: Double {
        let percentage = dragOffset.width / horizontalLimit
        return Double(percentage) * maxRotationDegrees
    }
    
    var body: some View {
        ZStack {
            // Shadow card (background effect)
            RoundedRectangle(cornerRadius: 24)
                .fill(secondaryColor.opacity(0.3))
                .frame(width: UIScreen.main.bounds.width - 60, height: min(UIScreen.main.bounds.height * 0.65, 520))
                .offset(y: isGone || isDragging ? 0 : 40)
                .blur(radius: 8)
                .opacity(isDragging ? 0.3 : 0.7)
                .animation(.easeOut(duration: 0.4), value: isDragging)
            
            // Main card content
            VStack(spacing: 0) {
                // Mission title with animated emoji
                HStack(spacing: 12) {
                    Image(systemName: mission.type.icon)
                        .font(.system(size: 30))
                        .foregroundColor(secondaryColor)
                        .symbolEffect(.bounce, options: .repeating, value: showOptions)
                    
                    Text(mission.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                }
                .padding(.top, 30)
                .padding(.horizontal)
                
                // Mission description
                Text(mission.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .foregroundColor(.black.opacity(0.7))
                
                // Mission icon with animation
                if let imageName = mission.imageName {
                    Image(systemName: imageName)
                        .font(.system(size: 60))
                        .foregroundColor(secondaryColor)
                        .padding(.vertical, 24)
                        .symbolEffect(.pulse, options: .repeating, value: showOptions)
                        .phaseAnimator([1.0, 1.1, 1.0], trigger: showOptions) { content, scale in
                            content
                                .scaleEffect(scale)
                        } animation: { _ in
                            .easeInOut(duration: 2.0)
                        }
                }
                
                Spacer()
                
                // Options section with staggered animation
                VStack(spacing: 12) {
                    ForEach(Array(mission.options.enumerated()), id: \.element.id) { index, option in
                        optionButton(for: option, index: index)
                            .opacity(showOptions ? 1 : 0)
                            .offset(y: showOptions ? 0 : 20)
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.7)
                                .delay(0.2 + Double(index) * 0.1),
                                value: showOptions
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: min(UIScreen.main.bounds.height * 0.7, 550))
            .background(
                ZStack {
                    // Card background with gradient
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryColor, primaryColor.opacity(0.9)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Subtle pattern overlay
                    RoundedRectangle(cornerRadius: 24)
                        .fill(primaryColor)
                        .opacity(0.1)
                        .blur(radius: 1)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(secondaryColor, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 8)
            .rotationEffect(.degrees(rotationAngle))
            .offset(dragOffset)
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        withAnimation(.interactiveSpring()) {
                            isDragging = true
                            let newWidth = value.translation.width
                            let clampedWidth = min(max(newWidth, -horizontalLimit), horizontalLimit)
                            dragOffset = CGSize(width: clampedWidth, height: value.translation.height / 4)
                        }
                    }
                    .onEnded { value in
                        if abs(value.translation.width) > swipeThreshold {
                            // Find the selected option based on swipe direction
                            let selectedIndex = value.translation.width > 0 ? 0 : mission.options.count - 1
                            let selectedOption = mission.options[selectedIndex]
                            
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                isDragging = false
                                let horizontalDirection: CGFloat = value.translation.width > 0 ? 1 : -1
                                dragOffset = CGSize(width: horizontalDirection * 600, height: value.translation.height / 2)
                                isGone = true
                                
                                // Notify parent view of selection after animation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onSwipedAway(selectedOption)
                                }
                            }
                        } else {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                dragOffset = .zero
                                isDragging = false
                            }
                        }
                    }
            )
            
            // Swipe indicators with improved animations
            Group {
                // Right swipe indicator (like)
                VStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 70))
                        .symbolEffect(.bounce, options: .speed(1.5), value: dragOffset.width > 50)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Me interesa")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .opacity(dragOffset.width > 0 ? Double(min(dragOffset.width / horizontalLimit, 1)) : 0)
                .rotationEffect(.degrees(10))
                .position(x: UIScreen.main.bounds.width / 2 + 70, y: 120)
                
                // Left swipe indicator (dislike)
                VStack(spacing: 8) {
                    Image(systemName: "xmark")
                        .font(.system(size: 70, weight: .bold))
                        .symbolEffect(.bounce, options: .speed(1.5), value: dragOffset.width < -50)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red, .red.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("No me interesa")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .opacity(dragOffset.width < 0 ? Double(min(-dragOffset.width / horizontalLimit, 1)) : 0)
                .rotationEffect(.degrees(-10))
                .position(x: UIScreen.main.bounds.width / 2 - 70, y: 120)
            }
        }
        .onAppear {
            // Staggered entrance animations
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(animationDelay)) {
                cardScale = 1.0
                cardOpacity = 1.0
            }
            
            // Delay showing options for a smoother entrance
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay + 0.3) {
                withAnimation {
                    showOptions = true
                }
            }
        }
    }
    
    // Helper function to create option buttons with improved design
    private func optionButton(for option: MissionOption, index: Int) -> some View {
        Button(action: {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isGone = true
                dragOffset = CGSize(width: 300, height: 0)
                
                // Notify parent view of selection after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSwipedAway(option)
                }
            }
        }) {
            HStack {
                Text("\(index + 1).")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black.opacity(0.6))
                    .frame(width: 24)
                
                Text(option.text)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.5))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(secondaryColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Custom button style for option buttons
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - VocationalCardSwipeView
struct VocationalCardSwipeView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var showResults = false
    
    // App theme colors
    private let primaryColor = Color(hex: "D8F3DC") // Nyanza
    private let secondaryColor = Color(hex: "B7E4C7") // Celadon
    
    var body: some View {
        ZStack {
            // Background
            primaryColor.opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                // Header
                VStack(spacing: 8) {
                    Text("Descubre tu vocación")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("Desliza para elegir tus preferencias")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding(.top, 20)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 8)
                            .fill(secondaryColor)
                            .frame(width: geometry.size.width * viewModel.progress, height: 8)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Mission count
                HStack {
                    Spacer()
                    Text("Pregunta \(viewModel.currentMissionIndex + 1) de \(viewModel.missions.count)")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.7))
                    Spacer()
                }
                .padding(.top, 5)
                
                // Card view - centered with more space
                if let mission = viewModel.currentMission {
                    VocationalCardView(
                        mission: mission,
                        onSwipedAway: { option in
                            // Select the option
                            viewModel.selectOption(option, for: mission)
                            
                            // Move to next mission or show results
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if viewModel.isLastMission {
                                    showResults = true
                                } else {
                                    viewModel.nextMission()
                                }
                            }
                        }
                    )
                    .padding(.vertical, 10)
                } else {
                    Text("No hay más preguntas")
                        .font(.title)
                        .foregroundColor(.black)
                }
                
                // Swipe instructions
                HStack(spacing: 30) {
                    VStack {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24))
                        Text("No me interesa")
                            .font(.caption)
                    }
                    .foregroundColor(.black.opacity(0.7))
                    
                    VStack {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 24))
                        Text("Me interesa")
                            .font(.caption)
                    }
                    .foregroundColor(.black.opacity(0.7))
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

// MARK: - Preview
struct VocationalCardView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = VocationalTestViewModel()
        
        return Group {
            if let mission = Mission.sampleMissions.first {
                VocationalCardView(
                    mission: mission,
                    onSwipedAway: { _ in }
                )
                .previewLayout(.sizeThatFits)
                .padding()
                .background(Color.gray.opacity(0.1))
            }
            
            VocationalCardSwipeView(viewModel: viewModel)
        }
    }
}
