import SwiftUI

struct LoadingProgressView: View {
    let title: String
    let progress: Double
    let accentColor: Color

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(accentColor)
                .rotationEffect(.degrees(progress * 360))
                .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false), value: progress)
            Text(title).font(.headline).foregroundColor(.white)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                .scaleEffect(1.5)
        }
    }
}


