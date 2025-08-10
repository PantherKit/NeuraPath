import SwiftUI

struct MultipleIntelligencesSection: View {
    let scores: MIScores
    private let accentColor = AppTheme.Colors.cosmicCyan

    var body: some View {
        VStack(spacing: 15) {
            header
            bars
                .padding(.horizontal, 10)
                .padding(.vertical, 15)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: accentColor.opacity(0.2), radius: 15)
        )
    }

    private var header: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 20))
                .foregroundColor(accentColor)
            Text("Tus Inteligencias Múltiples")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var bars: some View {
        VStack(spacing: 8) {
            intelligenceBar(label: "Lingüística", value: scores.linguistic, color: .blue)
            intelligenceBar(label: "Lógico-Matemática", value: scores.logicalMath, color: .green)
            intelligenceBar(label: "Espacial", value: scores.spatial, color: .orange)
            intelligenceBar(label: "Corporal-Kinestésica", value: scores.bodilyKinesthetic, color: .red)
            intelligenceBar(label: "Musical", value: scores.musical, color: .purple)
            intelligenceBar(label: "Interpersonal", value: scores.interpersonal, color: .pink)
            intelligenceBar(label: "Intrapersonal", value: scores.intrapersonal, color: .yellow)
            intelligenceBar(label: "Naturalista", value: scores.naturalist, color: .teal)
        }
    }

    private func intelligenceBar(label: String, value: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 140, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.gray.opacity(0.3)).cornerRadius(5)
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [color.opacity(0.7), color]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(5)
                        .frame(width: geometry.size.width * CGFloat(value))
                }
            }
            .frame(height: 14)

            Text("\(Int(value * 100))")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 30)
        }
        .frame(height: 24)
    }
}


