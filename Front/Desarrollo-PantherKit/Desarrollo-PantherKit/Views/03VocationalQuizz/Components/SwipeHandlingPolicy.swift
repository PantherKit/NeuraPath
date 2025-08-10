import CoreGraphics

// MARK: - Swipe Handling Policy
protocol SwipeHandlingPolicy {
    var swipeThreshold: CGFloat { get }
}

struct DefaultSwipePolicy: SwipeHandlingPolicy {
    let swipeThreshold: CGFloat
    init(threshold: CGFloat = 100) { self.swipeThreshold = threshold }
}


