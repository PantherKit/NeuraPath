import SwiftUI

// MARK: - MBTI Card Model
struct MBTICard: Identifiable {
    let id = UUID()
    let question: String
    let dimension: MBTIDimension
    let optionA: MBTIOption
    let optionB: MBTIOption
    
    // Convert to STEMCard for consistent UI
    func toSTEMCard() -> STEMCard {
        return STEMCard(
            imageName: "brain.head.profile",
            title: question,
            subtitle: dimension.rawValue,
            details: [
                STEMCard.CardDetail(
                    icon: optionA.icon,
                    title: "Opción A (Desliza →)",
                    description: optionA.text
                ),
                STEMCard.CardDetail(
                    icon: optionB.icon,
                    title: "Opción B (Desliza ←)",
                    description: optionB.text
                )
            ]
        )
    }
    
    struct MBTIOption {
        let text: String
        let type: MBTIType
        let icon: String
    }
    
    enum MBTIDimension: String {
        case IE = "Introversión vs Extroversión"
        case SN = "Sensorial vs Intuición"
        case TF = "Pensamiento vs Sentimiento"
        case JP = "Juicio vs Percepción"
    }
    
    enum MBTIType: String {
        case I = "I"
        case E = "E"
        case S = "S"
        case N = "N"
        case T = "T"
        case F = "F"
        case J = "J"
        case P = "P"
    }
}

// MARK: - MBTI Questions Data


// MARK: - STEMCard Model
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

extension STEMCard {
    static let sampleData: [STEMCard] = [
        STEMCard(
            imageName: "brain.head.profile",
            title: "¿Te recargas de energía estando solo o al convivir con otros?",
            subtitle: "Introversión vs Extroversión",
            details: [
                CardDetail(icon: "person.3.fill", title: "Opción A (Desliza →)", description: "Al convivir con otros"),
                CardDetail(icon: "person.fill", title: "Opción B (Desliza ←)", description: "Estando solo")
            ]
        ),
        STEMCard(
            imageName: "brain.head.profile",
            title: "¿Te enfocas más en los hechos concretos o en ideas abstractas?",
            subtitle: "Sensorial vs Intuición",
            details: [
                CardDetail(icon: "list.bullet", title: "Opción A (Desliza →)", description: "En los hechos concretos"),
                CardDetail(icon: "lightbulb.fill", title: "Opción B (Desliza ←)", description: "En ideas abstractas")
            ]
        ),
        STEMCard(
            imageName: "brain.head.profile",
            title: "¿Tomas decisiones más con lógica o con tus emociones?",
            subtitle: "Pensamiento vs Sentimiento",
            details: [
                CardDetail(icon: "chart.bar.fill", title: "Opción A (Desliza →)", description: "Con lógica"),
                CardDetail(icon: "heart.fill", title: "Opción B (Desliza ←)", description: "Con mis emociones")
            ]
        ),
        STEMCard(
            imageName: "brain.head.profile",
            title: "¿Prefieres tener todo planeado o decidir sobre la marcha?",
            subtitle: "Juicio vs Percepción",
            details: [
                CardDetail(icon: "calendar", title: "Opción A (Desliza →)", description: "Tener todo planeado"),
                CardDetail(icon: "shuffle", title: "Opción B (Desliza ←)", description: "Decidir sobre la marcha")
            ]
        )
    ]
}

struct DeckViewWrapper: View {
    let onComplete: () -> Void
    @ObservedObject var viewModel: VocationalTestViewModel
    
    var body: some View {
        DeckView(onComplete: onComplete, viewModel: viewModel)
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

// MARK: - Preview
struct DeckPreviewView: View {
    @StateObject private var viewModel = VocationalTestViewModel()
    
    var body: some View {
        DeckViewWrapper(
            onComplete: { print("Test completed!") },
            viewModel: viewModel
        )
    }
}

#Preview {
    DeckPreviewView()
}
