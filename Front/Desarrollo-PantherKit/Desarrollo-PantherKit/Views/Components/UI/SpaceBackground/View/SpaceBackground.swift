import SwiftUI

// MARK: - Space Background
struct SpaceBackground: View {
    let showNebulas: Bool
    let accentColor: Color
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            WelcomeCosmicBackground()
            if showNebulas {
                ForEach(0..<5, id: \.self) { i in
                    let colors: [Color] = [
                        Color(red: 0.5, green: 0.2, blue: 0.8),
                        Color(red: 0.1, green: 0.4, blue: 0.9),
                        Color(red: 0.3, green: 0.8, blue: 0.9)
                    ]
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    colors[i % colors.count].opacity(0.2),
                                    colors[i % colors.count].opacity(0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 300, height: 300)
                        .position(x: CGFloat.random(in: 0..<UIScreen.main.bounds.width), y: CGFloat.random(in: 0..<UIScreen.main.bounds.height))
                        .blur(radius: 60)
                }
            }
        }
    }
}


