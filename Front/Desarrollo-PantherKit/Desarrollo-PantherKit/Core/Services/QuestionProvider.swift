import Foundation

// MARK: - Question Provider Protocol
protocol QuestionProviding {
    associatedtype Item
    var currentIndex: Int { get }
    var totalCount: Int { get }
    var isLast: Bool { get }
    func current() -> Item?
    func nextIndex() -> Int
    func hasNext() -> Bool
}

// MARK: - Array-backed Provider (safe indices)
struct ArrayQuestionProvider<Item>: QuestionProviding {
    private let items: [Item]
    private(set) var currentIndex: Int

    init(items: [Item], startIndex: Int = 0) {
        self.items = items
        self.currentIndex = max(0, min(startIndex, items.count == 0 ? 0 : items.count - 1))
    }

    var totalCount: Int { items.count }

    var isLast: Bool { max(0, currentIndex) >= max(0, items.count - 1) }

    func current() -> Item? {
        guard currentIndex >= 0, currentIndex < items.count else { return nil }
        return items[currentIndex]
    }

    func nextIndex() -> Int {
        guard items.count > 0 else { return 0 }
        return min(currentIndex + 1, items.count - 1)
    }

    func hasNext() -> Bool {
        currentIndex + 1 < items.count
    }
}


