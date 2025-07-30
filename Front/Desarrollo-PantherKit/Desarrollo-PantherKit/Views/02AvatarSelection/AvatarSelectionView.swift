import SwiftUI
import Foundation

struct AvatarSelectionView: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    let onContinue: () -> Void
    
    // Enhanced animation states
    @State private var showContent = false
    @State private var showHeader = false
    @State private var showAvatars = false
    @State private var showButton = false
    @State private var sparkleAnimation = false
    @State private var showConstellation = false
    @State private var selectedAvatarGlow = false
    
    var body: some View {
        ZStack {
            // Magazine-style cosmic background
            MagazineCosmicBackground()
            
            // Dynamic Constellation in upper area
            if showConstellation {
                DynamicConstellation()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 80)
            }
            
            // Main content with magazine layout
            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height * 0.25) // Responsive spacing
                    
                    // Editorial header section
                    AvatarSelectionHeader()
                        .opacity(showHeader ? 1.0 : 0)
                        .offset(y: showHeader ? 0 : -40)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Magazine-style avatar grid
                    AvatarSelectionGrid(
                        viewModel: viewModel,
                        selectedAvatarGlow: $selectedAvatarGlow
                    )
                    .opacity(showAvatars ? 1.0 : 0)
                    .offset(y: showAvatars ? 0 : 50)
                    
                    Spacer()
                        .frame(height: 60)
                    
                    // Premium CTA button
                    MagazineCosmicButton(
                        title: "Continue Journey",
                        action: onContinue
                    )
                    .disabled(viewModel.selectedAvatar == nil)
                    .opacity(viewModel.selectedAvatar == nil ? 0.6 : 1.0)
                    .opacity(showButton ? 1.0 : 0)
                    .offset(y: showButton ? 0 : 30)
                    
                    Spacer()
                        .frame(height: 80)
                }
            }
            .scrollIndicators(.hidden)
            
            // Floating sparkles
            if sparkleAnimation {
                ForEach(0..<12, id: \.self) { i in
                    SparkleParticle(index: i)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startMagazineAnimation()
        }
    }
    
    private func startMagazineAnimation() {
        // Elegant entrance sequence
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
            showContent = true
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6)) {
            showHeader = true
        }
        
        withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(1.0)) {
            showAvatars = true
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.5)) {
            showButton = true
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
    }
}

// MARK: - Preview
#Preview {
    AvatarSelectionView(viewModel: VocationalTestViewModel(), onContinue: {})
        .preferredColorScheme(.dark)
}
