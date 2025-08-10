import Foundation

// MARK: - Unified content contract for Question Cards (LSP)
protocol QuestionCardContent {
    var title: String { get }
    var subtitle: String { get }
    var questionDetails: [QuestionCardDetail] { get }
}

struct QuestionCardDetail: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}


