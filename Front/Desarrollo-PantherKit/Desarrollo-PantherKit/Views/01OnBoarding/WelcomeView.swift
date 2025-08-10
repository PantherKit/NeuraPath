import SwiftUI
import Foundation

struct WelcomeView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    let onContinue: () -> Void
    
    // Animation states
    @State private var showContent = false
    @State private var showTitle = false
    @State private var showButton = false
    @State private var glitchEffect = false
    
    var body: some View {
        ZStack {
            // Background will be handled by user (blue planet)
            WelcomeCosmicBackground()
            
            
            // Main content
            VStack(spacing: 0) {
                // Top navigation area
                OnboardingHeaderView(
                    stepNumber: "01",
                    panelTitle: "MISSION CONTROL",
                    rightSubtitle: "Begin your journey"
                )
                .padding(.top, 60)
                .opacity(showContent ? 1.0 : 0)
                .offset(y: showContent ? 0 : -20)
                
                Spacer()
                
                // Bottom content area
                VStack(alignment: .leading, spacing: 16) {
                    // Main title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Neura")
                            .font(AppTheme.Space.spaceTitle(64))
                            .fontWeight(.black)
                            .foregroundColor(AppTheme.Colors.spacePureWhite)
                            .tracking(3)
                        
                        Text("Path")
                            .font(AppTheme.Space.spaceTitle(64))
                            .fontWeight(.black)
                            .foregroundColor(AppTheme.Colors.spacePureWhite)
                            .tracking(3)
                    }
                    .opacity(showTitle ? 1.0 : 0)
                    .offset(y: showTitle ? 0 : 20)
                    
                    // Subtitle
                    Text("Discover your future with STEM careers")
                        .font(AppTheme.Space.spaceBody(16))
                        .foregroundColor(AppTheme.Colors.spaceGray)
                        .tracking(0.5)
                        .opacity(showTitle ? 1.0 : 0)
                        .offset(y: showTitle ? 0 : 20)
                    
                    // Metrics row
                    HStack(spacing: 40) {
                        MetricPanel(label: "Available Paths", value: "180", unit: nil)
                        MetricPanel(label: "Match Rate", value: "94.7", unit: "%")
                    }
                    .opacity(showTitle ? 1.0 : 0)
                    .offset(y: showTitle ? 0 : 20)
                    
                    // Continue button
                    Button(action: onContinue) {
                        HStack(spacing: 12) {
                            Text("BEGIN MISSION")
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
                                .fill(AppTheme.Colors.spaceElectricBlue.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                                        .stroke(AppTheme.Colors.spaceElectricBlue, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .opacity(showButton ? 1.0 : 0)
                    .offset(y: showButton ? 0 : 20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
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
        
        // Title entrance
        withAnimation(.easeOut(duration: 1.0).delay(0.8)) {
            showTitle = true
        }
        
        // Button entrance
        withAnimation(.easeOut(duration: 1.0).delay(1.2)) {
            showButton = true
        }
        
        // Glitch effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            glitchEffect = true
        }
    }
}

// MARK: - Preview
#Preview {
    WelcomeView(viewModel: VocationalTestViewModel(), onContinue: {})
        .preferredColorScheme(.dark)
}
