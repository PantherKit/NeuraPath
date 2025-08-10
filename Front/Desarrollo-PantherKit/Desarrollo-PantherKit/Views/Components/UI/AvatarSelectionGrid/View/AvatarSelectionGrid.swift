import SwiftUI

// MARK: - Avatar Selection Grid
struct AvatarSelectionGrid: View {
    @ObservedObject var viewModel: VocationalTestViewModel
    @Binding var selectedAvatarGlow: Bool
    
    private let columns = [GridItem(.adaptive(minimum: 140, maximum: 160), spacing: 20)]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 24) {
            ForEach(Avatar.allAvatars) { avatar in
                AvatarGlassCard(
                    avatar: avatar,
                    isSelected: viewModel.selectedAvatar?.id == avatar.id,
                    onSelect: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { viewModel.selectedAvatar = avatar }
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                )
            }
        }
        .padding(.horizontal, 24)
    }
}


