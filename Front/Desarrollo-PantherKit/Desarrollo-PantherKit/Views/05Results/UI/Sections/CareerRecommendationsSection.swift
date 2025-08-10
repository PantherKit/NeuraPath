import SwiftUI

struct CareerRecommendationsSection: View {
    let careers: [APICareerRecommendation]
    let onSelect: (APICareerRecommendation) -> Void

    private let accentColor = Color(red: 0.25, green: 0.72, blue: 0.85)

    var body: some View {
        VStack(spacing: 15) {
            sectionHeader(title: "Carreras Recomendadas", icon: "graduationcap.fill")
            VStack(spacing: 12) {
                ForEach(careers.prefix(5)) { career in
                    careerCard(career)
                        .onTapGesture { onSelect(career) }
                }
            }
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: accentColor.opacity(0.2), radius: 15)
        )
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(accentColor)
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func careerCard(_ career: APICareerRecommendation) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(career.nombre)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                HStack {
                    Text(career.universidad)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    Text("•").foregroundColor(.white.opacity(0.5))
                    Text(career.ciudad)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            Spacer()

            ZStack {
                Circle().stroke(Color.gray.opacity(0.3), lineWidth: 3).frame(width: 46, height: 46)
                Circle()
                    .trim(from: 0, to: CGFloat(min(career.matchScore * 20, 1.0)))
                    .stroke(getMatchColor(score: career.matchScore), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 46, height: 46)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(career.matchScore * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.6))
                .font(.system(size: 14, weight: .bold))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.1)))
    }

    private func getMatchColor(score: Double) -> Color {
        let adjusted = score * 20
        if adjusted > 0.8 { return .green }
        if adjusted > 0.5 { return .yellow }
        return .orange
    }
}


