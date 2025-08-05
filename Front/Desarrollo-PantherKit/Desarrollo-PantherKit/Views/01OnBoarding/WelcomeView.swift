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
            
            // Main content
            VStack(spacing: 0) {
                // Top navigation area
                HStack {
                    // Left side - Navigation panels
                    HStack(spacing: 12) {
                        // Circle with number
                        Circle()
                            .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.6))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.Colors.spacePureWhite, lineWidth: 1)
                            )
                            .overlay(
                                Text("01")
                                    .font(AppTheme.Space.spaceCaption(12))
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppTheme.Colors.spacePureWhite)
                            )
                        
                        // Rectangle with text
                        Text("MISSION CONTROL")
                            .font(AppTheme.Space.spaceCaption(10))
                            .fontWeight(.medium)
                            .foregroundColor(AppTheme.Colors.spacePureWhite)
                            .tracking(0.5)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                                    .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                                            .stroke(AppTheme.Colors.spacePureWhite, lineWidth: 1)
                                    )
                            )
                    }
                    
                    Spacer()
                    
                    // Right side - Number and phrase
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("01")
                            .font(AppTheme.Space.spaceCaption(12))
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.Colors.spacePureWhite)
                        
                        Text("Begin your journey")
                            .font(AppTheme.Space.spaceCaption(10))
                            .foregroundColor(AppTheme.Colors.spaceGray)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .padding(.horizontal, 20)
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
                        SpaceMetricPanel(
                            label: "Available Paths",
                            value: "180",
                            unit: nil
                        )
                        
                        SpaceMetricPanel(
                            label: "Match Rate",
                            value: "94.7",
                            unit: "%"
                        )
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
                    .buttonStyle(SpaceButtonStyle())
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
