//
//  CareerSwipeView.swift
//  Desarrollo-PantherKit
//
//  Created on 5/12/25.
//

import SwiftUI

struct CareerSwipeView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var showNextScreen = false
    @State private var showFeedback = false
    @State private var feedbackText = ""
    @State private var feedbackColor = Color.green
    
    private let careers = EngineeringField.allCases
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.Layout.spacingL) {
                // Header
                HStack {
                    Text("Descubre tu carrera")
                        .font(.system(size: AppTheme.Typography.title1, weight: .bold))
                        .foregroundColor(AppTheme.Colors.text)
                    
                    Spacer()
                    
                    // Progress
                    Text("\(currentIndex + 1)/\(careers.count)")
                        .font(.system(size: AppTheme.Typography.headline))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                .padding(.horizontal)
                
                // Progress bar
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(height: 8)
                        .opacity(0.3)
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width - 32 * CGFloat(currentIndex + 1) / CGFloat(careers.count), height: 8)
                        .foregroundColor(AppTheme.Colors.primary)
                        .animation(.linear, value: currentIndex)
                }
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusS))
                .padding(.horizontal)
                
                Spacer()
                
                // Swipe card
                ZStack {
                    // Background card (next card)
                    if currentIndex < careers.count - 1 {
                        careerCard(for: careers[currentIndex + 1])
                            .scaleEffect(0.9)
                            .opacity(0.5)
                    }
                    
                    // Current card
                    if currentIndex < careers.count {
                        careerCard(for: careers[currentIndex])
                            .offset(offset)
                            .rotationEffect(.degrees(Double(offset.width / 20)))
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        offset = gesture.translation
                                    }
                                    .onEnded { gesture in
                                        withAnimation(.spring()) {
                                            if offset.width > 100 {
                                                // Swipe right - like
                                                offset.width = 500
                                                likeCareer()
                                            } else if offset.width < -100 {
                                                // Swipe left - dislike
                                                offset.width = -500
                                                dislikeCareer()
                                            } else {
                                                // Reset
                                                offset = .zero
                                            }
                                        }
                                    }
                            )
                    }
                }
                .frame(height: 450)
                .padding(.horizontal)
                
                Spacer()
                
                // Swipe buttons
                HStack(spacing: AppTheme.Layout.spacingXL) {
                    // Dislike button
                    Button(action: {
                        withAnimation(.spring()) {
                            offset.width = -500
                            dislikeCareer()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Circle().fill(Color.red))
                            .shadow(radius: 5)
                    }
                    
                    // Like button
                    Button(action: {
                        withAnimation(.spring()) {
                            offset.width = 500
                            likeCareer()
                        }
                    }) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Circle().fill(Color.green))
                            .shadow(radius: 5)
                    }
                }
                .padding(.bottom, AppTheme.Layout.spacingL)
            }
            .padding(.vertical, AppTheme.Layout.spacingL)
            .navigationBarHidden(true)
            
            // Feedback overlay
            if showFeedback {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack {
                    Text(feedbackText)
                        .font(.system(size: AppTheme.Typography.title2, weight: .bold))
                        .foregroundColor(feedbackColor)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusM)
                                .fill(Color.white)
                                .shadow(radius: 10)
                        )
                }
            }
        }
        .navigationDestination(isPresented: $showNextScreen) {
            GalaxyResultsView(viewModel: viewModel)
        }
    }
    
    private func careerCard(for field: EngineeringField) -> some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusL)
                .fill(field.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusL)
                        .stroke(field.color, lineWidth: 2)
                )
                .shadow(radius: 10)
            
            // Like/Dislike indicators
            ZStack {
                // Dislike indicator
                Text("NO ME INTERESA")
                    .font(.system(size: AppTheme.Typography.title3, weight: .bold))
                    .foregroundColor(.red)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusM)
                            .stroke(Color.red, lineWidth: 3)
                    )
                    .rotationEffect(.degrees(-30))
                    .opacity(offset.width < -50 ? 1 : 0)
                    .animation(.easeInOut, value: offset)
                    .padding(.top, -180)
                    .padding(.leading, -100)
                
                // Like indicator
                Text("ME INTERESA")
                    .font(.system(size: AppTheme.Typography.title3, weight: .bold))
                    .foregroundColor(.green)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Layout.cornerRadiusM)
                            .stroke(Color.green, lineWidth: 3)
                    )
                    .rotationEffect(.degrees(30))
                    .opacity(offset.width > 50 ? 1 : 0)
                    .animation(.easeInOut, value: offset)
                    .padding(.top, -180)
                    .padding(.trailing, -100)
            }
            
            // Card content
            VStack(spacing: AppTheme.Layout.spacingL) {
                // Icon
                ZStack {
                    Circle()
                        .fill(field.color.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: field.icon)
                        .font(.system(size: 50))
                        .foregroundColor(field.color)
                }
                .padding(.top, AppTheme.Layout.spacingL)
                
                // Title
                Text(field.rawValue)
                    .font(.system(size: AppTheme.Typography.title1, weight: .bold))
                    .foregroundColor(AppTheme.Colors.text)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(field.description)
                    .font(.system(size: AppTheme.Typography.body))
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Layout.spacingL)
                
                // Real world examples
                VStack(alignment: .leading, spacing: AppTheme.Layout.spacingS) {
                    Text("Ejemplos del mundo real:")
                        .font(.system(size: AppTheme.Typography.headline, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.text)
                    
                    Text(field.realWorldExample)
                        .font(.system(size: AppTheme.Typography.subheadline))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
                .padding(.horizontal, AppTheme.Layout.spacingL)
                .padding(.top, AppTheme.Layout.spacingM)
                
                Spacer()
                
                // Swipe instructions
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Desliza para decidir")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: AppTheme.Typography.caption1))
                .foregroundColor(AppTheme.Colors.secondaryText)
                .padding(.bottom, AppTheme.Layout.spacingM)
            }
        }
    }
    
    private func likeCareer() {
        let field = careers[currentIndex]
        viewModel.updateFieldScore(field, by: 1.0)
        
        showFeedback = true
        feedbackText = "¡Te interesa \(field.rawValue)!"
        feedbackColor = .green
        
        moveToNextCard()
    }
    
    private func dislikeCareer() {
        let field = careers[currentIndex]
        viewModel.updateFieldScore(field, by: -0.5)
        
        showFeedback = true
        feedbackText = "No te interesa \(field.rawValue)"
        feedbackColor = .red
        
        moveToNextCard()
    }
    
    private func moveToNextCard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showFeedback = false
            
            if currentIndex < careers.count - 1 {
                currentIndex += 1
                offset = .zero
            } else {
                // All cards swiped, move to results
                showNextScreen = true
            }
        }
    }
}

struct CareerSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        CareerSwipeView(viewModel: VocationalTestViewModel())
    }
}
