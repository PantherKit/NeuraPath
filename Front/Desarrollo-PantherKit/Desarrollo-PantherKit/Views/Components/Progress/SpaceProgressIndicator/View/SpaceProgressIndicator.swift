import SwiftUI

struct SpaceProgressIndicator: View {
    let currentIndex: Int
    let totalCount: Int
    @Binding var progressGlow: Bool

    var body: some View {
        ProgressCosmicBar(progress: progressValue, progressGlow: $progressGlow)
    }

    private var progressValue: Double {
        guard totalCount > 0 else { return 0 }
        return Double(currentIndex + 1) / Double(totalCount)
    }
}


