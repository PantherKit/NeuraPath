//
//  CardView.swift
//  Desarrollo-PantherKit
//
//  Created by Emiliano Montes on 13/05/25.
//

import SwiftUI
import Foundation

struct QuestionGlassCard: View {
    let card: STEMCard
    let isActive: Bool
    let onSwipedAway: () -> Void
    let onShowDetails: () -> Void
    
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var isGone = false
    @State private var cardGlow = false
    @State private var shimmerOffset: CGFloat = -200
    @State private var iconPulse = false
    
    private let swipeThreshold: CGFloat = 100
    private let maxRotation: Double = 15
    private let toastManager = ToastManager.shared
    
    var rotationAngle: Double {
        Double(dragOffset.width / swipeThreshold) * maxRotation
    }
    
    var body: some View {
        ZStack {
            // Authentic glass morphism card background
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .opacity(0.9)
                .background {
                    // Secondary glass layer for depth
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.thinMaterial)
                        .opacity(0.6)
                }
                .overlay {
                    // Glass tint with cosmic colors
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppTheme.Colors.cosmicCyan.opacity(0.15),
                                    AppTheme.Colors.cosmicBlue.opacity(0.08),
                                    Color.clear,
                                    AppTheme.Colors.cosmicPurple.opacity(0.05)
                                ],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 400
                            )
                        )
                    
                    // Natural light reflection
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.12),
                                    Color.clear,
                                    Color.clear,
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Sophisticated border
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.0
                        )
                    
                    // Shimmer effect
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            EllipticalGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.15),
                                    Color.clear
                                ],
                                center: UnitPoint(
                                    x: 0.3 + (shimmerOffset / UIScreen.main.bounds.width) * 0.4,
                                    y: 0.2
                                ),
                                startRadiusFraction: 0.1,
                                endRadiusFraction: 0.8
                            )
                        )
                        .mask(RoundedRectangle(cornerRadius: 28))
                        .opacity(0.6)
                }
                .shadow(color: Color.black.opacity(0.3), radius: 25, x: 0, y: 12)
                .shadow(color: AppTheme.Colors.cosmicBlue.opacity(0.15), radius: 35, x: 0, y: 18)
            
            // Card content
            VStack(spacing: 0) {
                // Hero image section with cosmic overlay
                ZStack(alignment: .topTrailing) {
                    // Cosmic gradient background
                    LinearGradient(
                        colors: [
                            AppTheme.Colors.cosmicCyan.opacity(0.3),
                            AppTheme.Colors.cosmicBlue.opacity(0.2),
                            AppTheme.Colors.cosmicPurple.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 220)
                    .clipShape(
                        RoundedCorner(radius: 28, corners: [.topLeft, .topRight])
                    )
                    
                    // Cosmic pattern overlay
                    ZStack {
                        ForEach(0..<8, id: \.self) { i in
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            AppTheme.Colors.cosmicCyan.opacity(0.1),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 30
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .position(
                                    x: CGFloat.random(in: 20...300),
                                    y: CGFloat.random(in: 20...200)
                                )
                                .scaleEffect(iconPulse ? 1.2 : 0.8)
                                .animation(
                                    .easeInOut(duration: Double.random(in: 2...4))
                                    .repeatForever(autoreverses: true)
                                    .delay(Double.random(in: 0...2)),
                                    value: iconPulse
                                )
                        }
                    }
                    
                    // Info button with glassmorphism
                    Button(action: onShowDetails) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.white.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                            
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(AppTheme.Colors.cosmicCyan)
                                .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.6), radius: 4, x: 0, y: 0)
                        }
                    }
                    .padding(20)
                }
                
                // Editorial content section
                VStack(alignment: .leading, spacing: 20) {
                    // Title with editorial typography
                    Text(card.title)
                        .font(.custom("ZonaPro-Bold", size: 28))
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .lineSpacing(2)
                        .tracking(0.5)
                        .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.3), radius: 8, x: 0, y: 2)
                    
                    // Subtitle
                    Text(card.subtitle)
                        .font(.custom("ZonaPro-Light", size: 18))
                        .fontWeight(.light)
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(4)
                        .tracking(0.3)
                    
                    // Divider with cosmic gradient
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.Colors.cosmicCyan.opacity(0.4),
                                    AppTheme.Colors.cosmicBlue.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                    
                    // Details with cosmic icons
                    VStack(spacing: 16) {
                        ForEach(card.details.prefix(2), id: \.title) { detail in
                            HStack(alignment: .top, spacing: 16) {
                                // Cosmic icon background
                                ZStack {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    AppTheme.Colors.cosmicCyan.opacity(0.2),
                                                    AppTheme.Colors.cosmicBlue.opacity(0.1),
                                                    Color.clear
                                                ],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 20
                                            )
                                        )
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: detail.icon)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(AppTheme.Colors.cosmicCyan)
                                        .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.6), radius: 4, x: 0, y: 0)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(detail.title)
                                        .font(.custom("ZonaPro-SemiBold", size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .tracking(0.3)
                                    
                                    Text(detail.description)
                                        .font(.custom("ZonaPro-Light", size: 14))
                                        .fontWeight(.light)
                                        .foregroundColor(.white.opacity(0.75))
                                        .lineSpacing(2)
                                        .tracking(0.2)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(24)
                
                Spacer()
            }
            
            // Swipe feedback indicators
            if isDragging {
                VStack {
                    if dragOffset.width > 0 {
                        VStack(spacing: 12) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 80, weight: .medium))
                                .foregroundColor(AppTheme.Colors.cosmicCyan)
                                .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.6), radius: 15, x: 0, y: 0)
                            
                            Text("Interested")
                                .font(.custom("ZonaPro-Bold", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.Colors.cosmicCyan)
                        }
                        .opacity(Double(min(dragOffset.width / swipeThreshold, 1)))
                    } else if dragOffset.width < 0 {
                        VStack(spacing: 12) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 80, weight: .medium))
                                .foregroundColor(AppTheme.Colors.cosmicPurple)
                                .shadow(color: AppTheme.Colors.cosmicPurple.opacity(0.6), radius: 15, x: 0, y: 0)
                            
                            Text("Not for me")
                                .font(.custom("ZonaPro-Bold", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.Colors.cosmicPurple)
                        }
                        .opacity(Double(min(-dragOffset.width / swipeThreshold, 1)))
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .rotationEffect(.degrees(rotationAngle))
        .offset(dragOffset)
        .opacity(isGone ? 0 : 1)
        .scaleEffect(isActive ? 1.0 : 0.9)
        .offset(y: isActive ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isActive)
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    if isActive {
                        withAnimation(.interactiveSpring()) {
                            isDragging = true
                            dragOffset = value.translation
                        }
                    }
                }
                .onEnded { value in
                    if isActive && abs(value.translation.width) > swipeThreshold {
                        withAnimation(.spring()) {
                            isDragging = false
                            let direction: CGFloat = value.translation.width > 0 ? 1 : -1
                            dragOffset = CGSize(width: direction * 500, height: 0)
                            isGone = true
                            
                            // Chance to show a motivational toast when swiping a card
                            let showToastChance = Bool.random()
                            if showToastChance {
                                toastManager.showRandomToast()
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSwipedAway()
                            }
                        }
                    } else {
                        withAnimation(.spring()) {
                            dragOffset = .zero
                            isDragging = false
                        }
                    }
                }
        )
        .onAppear {
            // Start shimmer animation
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false).delay(1.0)) {
                shimmerOffset = UIScreen.main.bounds.width + 200
            }
            
            // Start icon pulse animation
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.5)) {
                iconPulse = true
            }
            
            // Pequeña probabilidad de mostrar un toast al aparecer la tarjeta
            if Bool.random() && isActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if Double.random(in: 0...1) < 0.3 {
                        toastManager.showRandomToast()
                    }
                }
            }
        }
    }
}

struct CardDetailView: View {
    let card: STEMCard
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Cosmic background
            MagazineCosmicBackground()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Hero image section
                    ZStack {
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.cosmicCyan.opacity(0.4),
                                AppTheme.Colors.cosmicBlue.opacity(0.3),
                                AppTheme.Colors.cosmicPurple.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 280)
                        
                        VStack {
                            Spacer()
                            Text(card.title)
                                .font(.custom("ZonaPro-Bold", size: 36))
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(2)
                                .tracking(0.5)
                                .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.4), radius: 15, x: 0, y: 5)
                                .padding(24)
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.8)
                                }
                        }
                    }
                    
                    // Content section
                    VStack(alignment: .leading, spacing: 24) {
                        Text(card.subtitle)
                            .font(.custom("ZonaPro-Light", size: 20))
                            .fontWeight(.light)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                            .tracking(0.3)
                            .padding(.top, 24)
                        
                        ForEach(card.details, id: \.title) { detail in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 16) {
                                    // Cosmic icon
                                    ZStack {
                                        Circle()
                                            .fill(
                                                RadialGradient(
                                                    colors: [
                                                        AppTheme.Colors.cosmicCyan.opacity(0.2),
                                                        AppTheme.Colors.cosmicBlue.opacity(0.1),
                                                        Color.clear
                                                    ],
                                                    center: .center,
                                                    startRadius: 0,
                                                    endRadius: 25
                                                )
                                            )
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: detail.icon)
                                            .font(.system(size: 22, weight: .medium))
                                            .foregroundColor(AppTheme.Colors.cosmicCyan)
                                            .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.6), radius: 6, x: 0, y: 0)
                                    }
                                    
                                    Text(detail.title)
                                        .font(.custom("ZonaPro-Bold", size: 20))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .tracking(0.3)
                                }
                                
                                Text(detail.description)
                                    .font(.custom("ZonaPro-Light", size: 16))
                                    .fontWeight(.light)
                                    .foregroundColor(.white.opacity(0.75))
                                    .lineSpacing(4)
                                    .tracking(0.2)
                                    .padding(.leading, 66)
                            }
                        }
                        
                        // Cosmic action button
                        MagazineCosmicButton(
                            title: "Interested in this area",
                            action: {
                                presentationMode.wrappedValue.dismiss()
                            }
                        )
                        .padding(.top, 32)
                    }
                    .padding(24)
                }
            }
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.white.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(20)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    QuestionGlassCard(
        card: STEMCard.sampleData[0],
        isActive: true,
        onSwipedAway: {},
        onShowDetails: {}
    )
    .preferredColorScheme(.dark)
}

