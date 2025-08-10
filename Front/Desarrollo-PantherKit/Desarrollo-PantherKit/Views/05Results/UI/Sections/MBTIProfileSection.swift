import SwiftUI

struct MBTIProfileSection: View {
    let profile: MBTIProfile
    let accentColor = Color(red: 0.25, green: 0.72, blue: 0.85)
    let secondaryColor = Color(red: 0.2, green: 0.6, blue: 1.0)

    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 30) {
                Text(profile.code)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [accentColor, secondaryColor]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: accentColor.opacity(0.5), radius: 10)
                    )

                VStack(alignment: .leading, spacing: 5) {
                    Text(ResultsView.getMBTIDescription(profile.code))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))

                    Text(ResultsView.getMBTITraits(profile.code))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)

            MBTIWeightsView(weights: profile.weights)
                .frame(height: 100)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: accentColor.opacity(0.2), radius: 15)
        )
    }
}

struct MBTIWeightsView: View {
    let weights: MBTIWeights
    var body: some View {
        HStack(spacing: 15) {
            MBTIDimensionBar(label: "E - I", value: weights.ei, leftColor: .blue, rightColor: .purple)
            MBTIDimensionBar(label: "S - N", value: weights.sn, leftColor: .green, rightColor: .orange)
            MBTIDimensionBar(label: "T - F", value: weights.tf, leftColor: .red, rightColor: .pink)
            MBTIDimensionBar(label: "J - P", value: weights.jp, leftColor: .yellow, rightColor: .teal)
        }
    }
}

struct MBTIDimensionBar: View {
    let label: String
    let value: Double
    let leftColor: Color
    let rightColor: Color
    var body: some View {
        VStack(spacing: 5) {
            ZStack(alignment: .bottom) {
                Capsule().fill(Color.gray.opacity(0.3)).frame(width: 20, height: 70)
                Capsule()
                    .fill(LinearGradient(gradient: Gradient(colors: [leftColor, rightColor]), startPoint: .bottom, endPoint: .top))
                    .frame(width: 20, height: 70 * CGFloat(value))
            }
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// Static helpers now defined in ResultsView


