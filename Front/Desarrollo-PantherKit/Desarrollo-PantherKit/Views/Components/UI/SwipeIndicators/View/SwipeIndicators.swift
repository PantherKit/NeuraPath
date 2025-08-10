import SwiftUI

// MARK: - Swipe Indicators
struct SwipeIndicators: View {
    let dragOffset: CGSize
    let swipeThreshold: CGFloat
    
    var body: some View {
        Group {
            // Right swipe indicator
            VStack {
                Image(systemName: "arrow.right.circle.fill").font(.system(size: 60)).foregroundColor(.green)
                Text("Opción A").font(.custom("ZonaPro-Bold", size: 16)).fontWeight(.bold).foregroundColor(.green)
            }
            .padding()
            .background { RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial).opacity(0.8) }
            .opacity(dragOffset.width > 0 ? Double(min(dragOffset.width / swipeThreshold, 1)) : 0)
            .position(x: UIScreen.main.bounds.width * 0.75, y: 100)
            
            // Left swipe indicator
            VStack {
                Image(systemName: "arrow.left.circle.fill").font(.system(size: 60)).foregroundColor(.blue)
                Text("Opción B").font(.custom("ZonaPro-Bold", size: 16)).fontWeight(.bold).foregroundColor(.blue)
            }
            .padding()
            .background { RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial).opacity(0.8) }
            .opacity(dragOffset.width < 0 ? Double(min(-dragOffset.width / swipeThreshold, 1)) : 0)
            .position(x: UIScreen.main.bounds.width * 0.25, y: 100)
        }
    }
}


