import SwiftUI

struct STEMCard: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
    let details: [CardDetail]
    
    struct CardDetail {
        let icon: String
        let title: String
        let description: String
    }
}

// Ejemplo de datos - esto se puede modificar fácilmente después
extension STEMCard {
    static let sampleData: [STEMCard] = [
        STEMCard(
            imageName: "tech1",
            title: "Ingeniería Aeroespacial",
            subtitle: "Explora los fundamentos del diseño de cohetes",
            details: [
                CardDetail(icon: "airplane", title: "Enfoque", description: "Diseño de sistemas de propulsión"),
                CardDetail(icon: "chart.line.uptrend.xyaxis", title: "Habilidades", description: "Matemáticas avanzadas, física"),
                CardDetail(icon: "globe", title: "Aplicaciones", description: "Exploración espacial, aviación")
            ]
        ),
        STEMCard(
            imageName: "tech2",
            title: "Inteligencia Artificial",
            subtitle: "Fundamentos de machine learning",
            details: [
                CardDetail(icon: "brain", title: "Enfoque", description: "Redes neuronales y algoritmos"),
                CardDetail(icon: "number", title: "Habilidades", description: "Programación, estadística"),
                CardDetail(icon: "app.badge", title: "Aplicaciones", description: "Reconocimiento de patrones, automatización")
            ]
        )
    ]
}

struct DeckViewWrapper: View {
    let onComplete: () -> Void
    @ObservedObject var viewModel: VocationalTestViewModel
    
    var body: some View {
        DeckView(onComplete: onComplete)
    }
}

extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0.3...1),
            green: .random(in: 0.3...1),
            blue: .random(in: 0.3...1)
        )
    }
}
