import SwiftUI

// MARK: - MBTI Swipe Instructions
struct MBTISwipeInstructions: View {
    var body: some View {
        HStack(spacing: 60) {
            VStack(spacing: 8) {
                Image(systemName: "arrow.left").font(.system(size: 24, weight: .medium))
                Text("Opción B").font(.custom("ZonaPro-Light", size: 14)).fontWeight(.medium)
            }
            .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Image(systemName: "arrow.right").font(.system(size: 24, weight: .medium))
                Text("Opción A").font(.custom("ZonaPro-Light", size: 14)).fontWeight(.medium)
            }
            .foregroundColor(.green)
        }
        .padding(.bottom, 40)
    }
}


