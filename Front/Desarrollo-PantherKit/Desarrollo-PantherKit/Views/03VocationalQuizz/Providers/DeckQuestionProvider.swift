import Foundation

// Thin per-feature wrapper around ArrayQuestionProvider to keep Deck-related
// dependencies grouped within the feature without duplicating logic.
struct DeckQuestionProvider<Item>: QuestionProviding {
    private let provider: ArrayQuestionProvider<Item>
    private(set) var currentIndex: Int

    init(items: [Item], startIndex: Int = 0) {
        self.provider = ArrayQuestionProvider(items: items, startIndex: startIndex)
        self.currentIndex = provider.currentIndex
    }

    var totalCount: Int { provider.totalCount }
    var isLast: Bool { provider.isLast }

    func current() -> Item? { provider.current() }
    func nextIndex() -> Int { provider.nextIndex() }
    func hasNext() -> Bool { provider.hasNext() }
}


