import SwiftUI

struct AvatarGridView: View {
    let avatars: [Avatar]
    let selectedAvatar: Avatar?
    let onSelect: (Avatar) -> Void

    let columns = [GridItem(.adaptive(minimum: 140), spacing: 16)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(avatars) { avatar in
                AvatarGlassCard(avatar: avatar, isSelected: avatar.id == selectedAvatar?.id) {
                    onSelect(avatar)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}


