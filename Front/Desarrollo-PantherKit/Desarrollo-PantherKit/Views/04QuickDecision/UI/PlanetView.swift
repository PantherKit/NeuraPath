import SwiftUI

struct PlanetView: View {
    let index: Int
    let color: Color
    @Binding var glow: Double
    let isCurrent: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 50, height: 50)
                .blur(radius: 10)
                .opacity(glow)

            Circle()
                .fill(
                    LinearGradient(gradient: Gradient(colors: [color, color.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 30, height: 30)
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(color: color.opacity(0.5), radius: 5, x: 0, y: 0)
                .overlay(
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                )
        }
        .scaleEffect(isCurrent ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 1.0), value: glow)
    }
}


