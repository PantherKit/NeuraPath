import SwiftUI

// MARK: - Cosmic Modal
struct CosmicModal<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String
    let showCloseButton: Bool
    let content: () -> Content
    
    init(
        isPresented: Binding<Bool>,
        title: String = "",
        showCloseButton: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.title = title
        self.showCloseButton = showCloseButton
        self.content = content
    }
    
    var body: some View {
        if isPresented {
            ZStack {
                // Backdrop
                WelcomeCosmicBackground()
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(AppTheme.Animation.cosmicSpring) { isPresented = false } }
                
                // Modal content
                VStack(spacing: AppTheme.Layout.spacingL) {
                    // Header
                    if !title.isEmpty || showCloseButton {
                        HStack {
                            if !title.isEmpty {
                                Text(title)
                                    .font(AppTheme.Typography.cosmicTitle(AppTheme.Typography.title2))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            if showCloseButton {
                                Button(action: { withAnimation(AppTheme.Animation.cosmicSpring) { isPresented = false } }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: AppTheme.Typography.title3, weight: .medium))
                                        .foregroundColor(AppTheme.Colors.glassLight)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.Layout.spacingL)
                        .padding(.top, AppTheme.Layout.spacingL)
                    }
                    
                    // Content
                    content()
                        .padding(.horizontal, AppTheme.Layout.spacingL)
                        .padding(.bottom, AppTheme.Layout.spacingL)
                }
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusL)
                        .fill(.regularMaterial)
                        .opacity(AppTheme.Glass.opacityHeavy)
                        .background(RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusL).fill(AppTheme.Colors.cosmicCyan.opacity(0.05)))
                )
                .overlay(RoundedRectangle(cornerRadius: AppTheme.Layout.glassRadiusL).stroke(AppTheme.Glass.primaryBorder, lineWidth: AppTheme.Layout.glassBorderWidthThick))
                .shadow(color: AppTheme.Colors.glowCyan.opacity(0.2), radius: AppTheme.CosmicEffects.glowMediumRadius, x: 0, y: 8)
                .padding(AppTheme.Layout.spacingXL)
                .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity), removal: .scale(scale: 0.9).combined(with: .opacity)))
            }
        }
    }
}


