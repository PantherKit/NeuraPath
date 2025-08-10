import SwiftUI

struct FinalDestinationView: View {
    @Binding var isAnimating: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.7),
                        Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0)
                    ]), center: .center, startRadius: 0, endRadius: 120)
                )
                .frame(width: 120, height: 120)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)

            Circle()
                .fill(
                    LinearGradient(gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.9, blue: 0.5),
                        Color(red: 0.9, green: 0.7, blue: 0.2)
                    ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 70, height: 70)
                .overlay(
                    ZStack {
                        Image(systemName: "building.columns")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                            .offset(x: -10, y: 5)

                        Image(systemName: "star.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .offset(x: 15, y: -10)
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                    }
                )

            Text("Tu Futuro")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
                .offset(y: 50)
        }
    }
}


