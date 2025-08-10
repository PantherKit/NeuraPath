import SwiftUI

struct DeckViewWrapper: View {
    let onComplete: () -> Void
    @ObservedObject var viewModel: VocationalTestViewModel
    
    var body: some View {
        DeckView(onComplete: onComplete, viewModel: viewModel)
    }
}

extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0.3...1),
            green: .random(in: 0.3...1),
            blue: .random(in: 0.3...1)
        )
    }
}

// MARK: - Preview
struct DeckPreviewView: View {
    @StateObject private var viewModel = VocationalTestViewModel()
    
    var body: some View {
        DeckViewWrapper(
            onComplete: { print("Test completed!") },
            viewModel: viewModel
        )
    }
}

#Preview {
    DeckPreviewView()
}
