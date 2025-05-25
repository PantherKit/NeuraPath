import SwiftUI

// MARK: - Star Model
struct AnimatedStar: Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    var size: Double
    var brightness: Double
    var speed: Double
}

// MARK: - AnimatedStarField
struct AnimatedStarField: View {
    @State private var stars: [AnimatedStar] = []
    @State private var animationPhase: CGFloat = 0
    
    let numberOfStars: Int
    let backgroundColor: Color
    let starBrightness: Double
    let starDensity: Double
    let starSpeed: Double
    
    init(
        numberOfStars: Int = 100,
        backgroundColor: Color = .black,
        starBrightness: Double = 0.7,
        starDensity: Double = 1.0,
        starSpeed: Double = 1.0
    ) {
        self.numberOfStars = numberOfStars
        self.backgroundColor = backgroundColor
        self.starBrightness = starBrightness
        self.starDensity = starDensity
        self.starSpeed = starSpeed
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo
                backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                // Campo de estrellas
                ForEach(stars) { star in
                    Circle()
                        .fill(Color.white)
                        .opacity(star.brightness * (0.5 + 0.5 * sin(animationPhase * star.speed)))
                        .frame(width: star.size, height: star.size)
                        .position(
                            x: CGFloat(star.x * Double(geometry.size.width)),
                            y: CGFloat(star.y * Double(geometry.size.height))
                        )
                        .blur(radius: 0.2)
                }
            }
            .onAppear {
                // Generar estrellas aleatorias
                generateStars()
                
                // Iniciar animación
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    animationPhase = 6.28 // Aproximadamente 2π
                }
            }
        }
    }
    
    private func generateStars() {
        stars = (0..<numberOfStars).map { _ in
            AnimatedStar(
                x: Double.random(in: 0...1),
                y: Double.random(in: 0...1),
                size: Double.random(in: 1...3) * starDensity,
                brightness: Double.random(in: 0.2...1.0) * starBrightness,
                speed: Double.random(in: 0.5...1.5) * starSpeed
            )
        }
    }
}

// MARK: - Previews
#Preview {
    AnimatedStarField()
} 