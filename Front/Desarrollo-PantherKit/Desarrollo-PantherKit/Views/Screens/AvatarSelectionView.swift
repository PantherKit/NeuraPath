//
//  AvatarSelectionView.swift
//  Desarrollo-PantherKit
//
//  Created on 5/13/25.
//

import SwiftUI

struct AvatarSelectionView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @State private var showingTest = false
    @State private var animateTitle = false
    @State private var animateSubtitle = false
    @State private var animateAvatars = false
    @State private var animateButton = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.Layout.spacingL) {
                // Header
                VStack(spacing: AppTheme.Layout.spacingM) {
                    Text("Choose Your Avatar")
                        .font(.system(size: AppTheme.Typography.title1, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(animateTitle ? 1 : 0)
                        .offset(y: animateTitle ? 0 : -20)
                    
                    Text("Your avatar will accompany you through your engineering discovery journey!")
                        .font(.system(size: AppTheme.Typography.body))
                        .foregroundColor(AppTheme.Colors.text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(animateSubtitle ? 1 : 0)
                }
                .padding(.top, AppTheme.Layout.spacingXL)
                
                // Avatar selection
                VStack(spacing: AppTheme.Layout.spacingL) {
                    // Avatar grid
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 120), spacing: AppTheme.Layout.spacingM)], spacing: AppTheme.Layout.spacingL) {
                        ForEach(Avatar.allAvatars) { avatar in
                            AvatarSelectionItemView(
                                avatar: avatar,
                                isSelected: viewModel.selectedAvatar?.id == avatar.id,
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.selectedAvatar = avatar
                                    }
                                    // Haptic feedback
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .opacity(animateAvatars ? 1 : 0)
                .offset(y: animateAvatars ? 0 : 30)
                
                Spacer()
                
                // Start button
                PantherButton(
                    title: "Start Your Journey",
                    icon: "rocket",
                    isDisabled: viewModel.selectedAvatar == nil,
                    action: {
                        showingTest = true
                    }
                )
                .padding(.horizontal)
                .opacity(animateButton ? 1 : 0)
                .offset(y: animateButton ? 0 : 20)
                .padding(.bottom, AppTheme.Layout.spacingXL)
            }
        }
        .onAppear {
            startAnimations()
        }
        .navigationDestination(isPresented: $showingTest) {
            VocationalSwipeView(viewModel: viewModel)
        }
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            animateTitle = true
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            animateSubtitle = true
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.8)) {
            animateAvatars = true
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(1.2)) {
            animateButton = true
        }
    }
}

struct AvatarSelectionItemView: View {
    let avatar: Avatar
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Layout.spacingS) {
                ZStack {
                    Circle()
                        .fill(isSelected ? avatar.color : Color.gray.opacity(0.1))
                        .frame(width: 80, height: 80)
                        .shadow(color: isSelected ? avatar.color.opacity(0.5) : Color.clear, radius: 8, x: 0, y: 4)
                    
                    Image(systemName: avatar.imageName)
                        .font(.system(size: 36))
                        .foregroundColor(isSelected ? .white : AppTheme.Colors.secondaryText)
                }
                
                Text(avatar.name)
                    .font(.system(size: AppTheme.Typography.subheadline, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? avatar.color : AppTheme.Colors.text)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    AvatarSelectionView(viewModel: VocationalTestViewModel())
}
