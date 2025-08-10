import SwiftUI

struct OptionsListView: View {
    let options: [String]
    let icons: [String]
    @Binding var selectedIndex: Int?
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 15) {
            ForEach(options.indices, id: \.self) { index in
                Button(action: { onSelect(index) }) {
                    HStack(spacing: 12) {
                        Image(systemName: icons[index])
                            .font(.system(size: 24))
                            .foregroundColor(selectedIndex == index ? .white : AppTheme.Colors.cosmicCyan)

                        Text(options[index])
                            .font(.custom("ZonaPro-SemiBold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .tracking(0.3)
                    }
                    .padding()
                    .frame(height: 60)
                    .background(background(isSelected: selectedIndex == index))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(selectedIndex == index ? Color.white : AppTheme.Colors.cosmicCyan.opacity(0.6), lineWidth: 1.5)
                    )
                    .shadow(color: selectedIndex == index ? AppTheme.Colors.cosmicCyan.opacity(0.6) : Color.white.opacity(0.1), radius: 15, x: 0, y: 8)
                    .scaleEffect(selectedIndex == index ? 1.05 : 1.0)
                }
                .disabled(selectedIndex != nil)
                .animation(.spring(), value: selectedIndex)
            }
        }
        .padding(.horizontal, 20)
    }

    private func background(isSelected: Bool) -> some View {
        Group {
            if isSelected {
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppTheme.Colors.cosmicCyan,
                        AppTheme.Colors.cosmicBlue,
                        AppTheme.Colors.cosmicPurple
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
            }
        }
    }
}


