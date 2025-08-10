import SwiftUI
import Foundation

struct AvatarSelectionView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    let onContinue: () -> Void
    
    // Animation states
    @State private var showContent = false
    @State private var showHeader = false
    @State private var showGrid = false
    @State private var showButton = false
    @State private var glitchEffect = false
    
    var body: some View {
        ZStack {
            // Background will be handled by user
            BasicCosmicBackground()
            
            // Main content
            VStack(spacing: 0) {
                OnboardingHeaderView(stepNumber: "02", panelTitle: "MISSION CREW", rightSubtitle: "Select your avatar")
                .opacity(showContent ? 1.0 : 0)
                .offset(y: showContent ? 0 : -20)
                
                Spacer()
                
                // Main content area
                VStack(spacing: 40) {
                    // Title section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose Your")
                            .font(AppTheme.Space.spaceTitle(48))
                            .fontWeight(.black)
                            .foregroundColor(AppTheme.Colors.spacePureWhite)
                            .tracking(3)
                        
                        Text("Explorer Avatar")
                            .font(AppTheme.Space.spaceTitle(48))
                            .fontWeight(.black)
                            .foregroundColor(AppTheme.Colors.spacePureWhite)
                            .tracking(3)
                        
                        Text("Select the avatar that represents your journey")
                            .font(AppTheme.Space.spaceBody(16))
                            .foregroundColor(AppTheme.Colors.spaceGray)
                            .tracking(0.5)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .opacity(showHeader ? 1.0 : 0)
                    .offset(y: showHeader ? 0 : -30)
                    
                    // Avatar grid
                    AvatarGridView(avatars: Avatar.allAvatars, selectedAvatar: viewModel.selectedAvatar) { avatar in
                        viewModel.selectAvatar(avatar)
                    }
                        .opacity(showGrid ? 1.0 : 0)
                        .offset(y: showGrid ? 0 : 30)
                    
                    // Continue button
                    Button(action: onContinue) {
                        HStack(spacing: 12) {
                            Text("CONTINUE MISSION")
                                .font(AppTheme.Space.spaceCaption(14))
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.Colors.spacePureWhite)
                                .tracking(1)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(AppTheme.Colors.spacePureWhite)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                                .fill(
                                    viewModel.selectedAvatar != nil ? 
                                    AppTheme.Colors.spaceElectricBlue.opacity(0.2) : 
                                    AppTheme.Colors.spaceGray.opacity(0.1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                                        .stroke(
                                            viewModel.selectedAvatar != nil ? 
                                            AppTheme.Colors.spaceElectricBlue : 
                                            AppTheme.Colors.spaceGray,
                                            lineWidth: 2
                                        )
                                )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(viewModel.selectedAvatar == nil)
                    .opacity(showButton ? 1.0 : 0)
                    .offset(y: showButton ? 0 : 20)
                }
                .padding(.bottom, 60)
                
                Spacer()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startSpaceAnimation()
        }
    }
    
    private func startSpaceAnimation() {
        // Main content entrance
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
            showContent = true
        }
        
        // Header entrance
        withAnimation(.easeOut(duration: 1.0).delay(0.8)) {
            showHeader = true
        }
        
        // Grid entrance
        withAnimation(.easeOut(duration: 1.0).delay(1.2)) {
            showGrid = true
        }
        
        // Button entrance
        withAnimation(.easeOut(duration: 1.0).delay(1.6)) {
            showButton = true
        }
        
        // Glitch effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            glitchEffect = true
        }
    }
}

// MARK: - Preview
#Preview {
    AvatarSelectionView(viewModel: VocationalTestViewModel(), onContinue: {})
        .preferredColorScheme(.dark)
}
