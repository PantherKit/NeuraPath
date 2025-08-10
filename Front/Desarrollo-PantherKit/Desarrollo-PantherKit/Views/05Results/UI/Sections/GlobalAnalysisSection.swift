import SwiftUI

struct GlobalAnalysisSection: View {
    let analysis: DetailedAnalysis
    @Binding var isExpanded: Bool
    private let accentColor = AppTheme.Colors.cosmicCyan

    var body: some View {
        VStack(spacing: 15) {
            sectionHeader
            if isExpanded { content }
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: accentColor.opacity(0.2), radius: 15)
        )
    }

    private var sectionHeader: some View {
        Button(action: { withAnimation { isExpanded.toggle() } }) {
            HStack {
                Image(systemName: "person.text.rectangle").foregroundColor(accentColor)
                Text("Análisis Personalizado")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(accentColor)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            analysisSection(title: "Resumen de tu personalidad", icon: "person.fill", content: analysis.personalitySummary)
            analysisSection(title: "Tus inteligencias destacadas", icon: "brain.head.profile", content: analysis.intelligencesSummary)
            analysisSection(title: "Por qué estas carreras te convienen", icon: "lightbulb.fill", content: analysis.recommendationRationale)
            skillsSection
            opportunitiesChallenges
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 10)
    }

    private func analysisSection(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon).foregroundColor(accentColor).font(.system(size: 18))
                Text(title).font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
            }
            Text(content).font(.system(size: 16)).foregroundColor(.white.opacity(0.9)).lineSpacing(5)
        }
    }

    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "hammer.fill").foregroundColor(accentColor)
                Text("Habilidades a desarrollar").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 8) {
                ForEach(analysis.suggestedSkills, id: \.self) { skill in
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(accentColor.opacity(0.8))
                        Text(skill).font(.system(size: 16)).foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .padding(.leading, 5)
        }
    }

    private var opportunitiesChallenges: some View {
        HStack(alignment: .top, spacing: 15) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "arrow.up.forward.circle.fill").foregroundColor(.green.opacity(0.8))
                    Text("Oportunidades").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(analysis.opportunities, id: \.self) { item in
                        HStack(alignment: .top) {
                            Image(systemName: "plus.circle.fill").foregroundColor(.green.opacity(0.8))
                            Text(item).font(.system(size: 15)).foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .padding(.leading, 5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange.opacity(0.8))
                    Text("Desafíos").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(analysis.challenges, id: \.self) { item in
                        HStack(alignment: .top) {
                            Image(systemName: "exclamationmark.circle.fill").foregroundColor(.orange.opacity(0.8))
                            Text(item).font(.system(size: 15)).foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .padding(.leading, 5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


