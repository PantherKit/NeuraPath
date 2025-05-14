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
            title: "Te sientes con más energía cuando…",
            subtitle: "Introversión vs Extroversión",
            details: [
                CardDetail(icon: "person.3.fill", title: "Opción A (Desliza →)", description: "Estás en una expo STEM hablando con muchas personas"),
                CardDetail(icon: "person.fill", title: "Opción B (Desliza ←)", description: "Te encierras a resolver un circuito por tu cuenta")
            ]
        ),
        STEMCard(
            imageName: "brain.head.profile",
            title: "¿Cómo prefieres trabajar en un proyecto final?",
            subtitle: "Introversión vs Extroversión",
            details: [
                CardDetail(icon: "person.3.sequence.fill", title: "Opción A (Desliza →)", description: "En equipo, rebotando ideas"),
                CardDetail(icon: "person.fill.checkmark", title: "Opción B (Desliza ←)", description: "A tu ritmo, sin interrupciones")
            ]
        ),
        STEMCard(
            imageName: "brain.head.profile",
            title: "Prefieres tareas que…",
            subtitle: "Sensorial vs Intuición",
            details: [
                CardDetail(icon: "list.bullet", title: "Opción A (Desliza →)", description: "Tengan pasos claros y específicos"),
                CardDetail(icon: "lightbulb.fill", title: "Opción B (Desliza ←)", description: "Te permitan imaginar soluciones nuevas")
            ]
        ),
        STEMCard(
            imageName: "brain.head.profile",
            title: "¿Qué te interesa más?",
            subtitle: "Sensorial vs Intuición",
            details: [
                CardDetail(icon: "wrench.and.screwdriver.fill", title: "Opción A (Desliza →)", description: "Cómo funcionan las cosas en la realidad"),
                CardDetail(icon: "brain.head.profile", title: "Opción B (Desliza ←)", description: "Las teorías detrás de cómo podrían funcionar")
            ]
        ),
        STEMCard(
            imageName: "brain.head.profile",
            title: "Al tomar decisiones en un equipo…",
            subtitle: "Pensamiento vs Sentimiento",
            details: [
                CardDetail(icon: "chart.bar.fill", title: "Opción A (Desliza →)", description: "Priorizas la lógica del proyecto"),
                CardDetail(icon: "heart.fill", title: "Opción B (Desliza ←)", description: "Te enfocas en cómo se sienten tus compañeros")
            ]
        ),
        STEMCard(
            imageName: "brain.head.profile",
            title: "¿Qué suena más interesante?",
            subtitle: "Pensamiento vs Sentimiento",
            details: [
                CardDetail(icon: "gearshape.2.fill", title: "Opción A (Desliza →)", description: "Optimizar el rendimiento de un sistema"),
                CardDetail(icon: "figure.2.and.child.holdinghands", title: "Opción B (Desliza ←)", description: "Diseñar una solución que impacte a la comunidad")
            ]
        ),
        STEMCard(
            imageName: "brain.head.profile",
            title: "Cuando tienes un reto técnico…",
            subtitle: "Juicio vs Percepción",
            details: [
                CardDetail(icon: "checklist", title: "Opción A (Desliza →)", description: "Planeas y sigues un esquema paso a paso"),
                CardDetail(icon: "shuffle", title: "Opción B (Desliza ←)", description: "Improvisas y vas probando cosas sobre la marcha")
            ]
        ),
        STEMCard(
            imageName: "brain.head.profile",
            title: "¿Cómo organizas tu trabajo?",
            subtitle: "Juicio vs Percepción",
            details: [
                CardDetail(icon: "calendar", title: "Opción A (Desliza →)", description: "Con listas, fechas y estructura"),
                CardDetail(icon: "scribble.variable", title: "Opción B (Desliza ←)", description: "Con ideas generales y flexibilidad")
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
