import Foundation

// MARK: - STEMCard Model
struct STEMCard: Identifiable, QuestionCardContent {
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

    // QuestionCardContent mapping
    var questionDetails: [QuestionCardDetail] {
        details.map { QuestionCardDetail(icon: $0.icon, title: $0.title, description: $0.description) }
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


