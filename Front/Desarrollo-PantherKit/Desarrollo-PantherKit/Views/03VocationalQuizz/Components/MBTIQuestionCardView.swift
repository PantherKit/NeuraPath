import SwiftUI

struct MBTIQuestionCardView: View {
    let question: MBTICard
    let swipePolicy: SwipeHandlingPolicy
    @Binding var dragOffset: CGSize

    var body: some View {
        ZStack {
            GenericQuestionGlassCard(content: question, isActive: true, onSwipedAway: {}, onShowDetails: {})
            SwipeIndicators(
                dragOffset: dragOffset,
                swipeThreshold: swipePolicy.swipeThreshold
            )
        }
        .frame(width: UIScreen.main.bounds.width - 48, height: 520)
    }
}


