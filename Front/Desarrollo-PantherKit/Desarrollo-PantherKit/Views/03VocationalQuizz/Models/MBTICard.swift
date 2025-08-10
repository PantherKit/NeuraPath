import Foundation

// MARK: - MBTI Card Model
struct MBTICard: Identifiable, QuestionCardContent {
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

    // Conformance to QuestionCardContent
    var title: String { question }
    var subtitle: String { dimension.rawValue }
    var questionDetails: [QuestionCardDetail] {
        [
            QuestionCardDetail(icon: optionA.icon, title: "Opción A (Desliza →)", description: optionA.text),
            QuestionCardDetail(icon: optionB.icon, title: "Opción B (Desliza ←)", description: optionB.text)
        ]
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


