import SwiftUI

// MARK: - Rocket Game Components
struct RocketGameComponents {
    static func rocketPath() -> Path {
        Path { path in
            let width = UIScreen.main.bounds.width
            path.move(to: CGPoint(x: width/2, y: 280))
            for i in 1...8 {
                let xOffset: CGFloat = i % 2 == 0 ? 50 : -50
                let yStep: CGFloat = 240 / 9
                path.addLine(to: CGPoint(x: width/2 + xOffset, y: 280 - CGFloat(i) * yStep))
            }
            path.addLine(to: CGPoint(x: width/2, y: 0))
        }
    }
    
    static func rocketTrailView(accentColor: Color) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<10) { i in
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [.white.opacity(0.7), accentColor.opacity(0.5), .clear]), startPoint: .top, endPoint: .bottom))
                    .frame(width: 20 - CGFloat(i), height: 20 - CGFloat(i))
                    .offset(y: CGFloat(i) * 5)
                    .opacity(1.0 - Double(i) * 0.1)
                    .blur(radius: 0.5)
            }
        }
    }
    
    static func rocketBoostView() -> some View {
        VStack(spacing: 0) {
            ForEach(0..<7) { i in
                let size = 20 - CGFloat(i) * 2
                let opacity = 1.0 - Double(i) * 0.15
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [.yellow, .orange, .red]), startPoint: .top, endPoint: .bottom))
                    .frame(width: size, height: size)
                    .offset(y: CGFloat(i) * 5 + 10)
                    .opacity(opacity)
                    .blur(radius: 1)
            }
        }
    }
    
    static func finalDestinationView(isAnimating: Bool) -> some View {
        ZStack {
            Circle()
                .fill(RadialGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.7), Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0)]), center: .center, startRadius: 0, endRadius: 120))
                .frame(width: 120, height: 120)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.9, blue: 0.5), Color(red: 0.9, green: 0.7, blue: 0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 70, height: 70)
                .overlay(
                    ZStack {
                        Image(systemName: "building.columns").font(.system(size: 24)).foregroundColor(.white.opacity(0.8)).offset(x: -10, y: 5)
                        Image(systemName: "star.fill").font(.system(size: 16)).foregroundColor(.white).offset(x: 15, y: -10).scaleEffect(isAnimating ? 1.2 : 0.8).animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                    }
                )
            Text("Tu Futuro").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white).padding(.horizontal, 12).padding(.vertical, 6).background(Color.black.opacity(0.6)).cornerRadius(10).offset(y: 50)
        }
    }
    
    static func planetView(index: Int, planetColors: [Color], planetGlowIntensity: [Double], currentQuestion: Int) -> some View {
        ZStack {
            Circle().fill(planetColors[index].opacity(0.3)).frame(width: 50, height: 50).blur(radius: 10).opacity(planetGlowIntensity[index])
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [planetColors[index], planetColors[index].opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 30, height: 30)
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(color: planetColors[index].opacity(0.5), radius: 5, x: 0, y: 0)
                .overlay(Text("\(index + 1)").font(.system(size: 12, weight: .bold)).foregroundColor(.white))
        }
        .scaleEffect(currentQuestion == index ? 1.1 : 1.0)
    }
}


