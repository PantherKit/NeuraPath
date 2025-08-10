import SwiftUI

struct HeaderTimerView: View {
    let title: String
    @Binding var timeRemaining: Double

    private let totalTime: Double = 20.0
    private let accentColor = AppTheme.Colors.cosmicCyan
    private let warningColor = AppTheme.Colors.spaceAlertRed

    private var currentColor: Color {
        if timeRemaining > 5 { return accentColor }
        if timeRemaining > 2 { return .orange }
        return warningColor
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.custom("ZonaPro-Bold", size: 28))
                .foregroundColor(.white)
                .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.6), radius: 8, x: 0, y: 2)

            Spacer()

            ZStack {
                Circle()
                    .stroke(lineWidth: 4)
                    .opacity(0.3)
                    .foregroundColor(accentColor)

                Circle()
                    .trim(from: 0.0, to: CGFloat(max(0, min(1, timeRemaining / totalTime))))
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .foregroundColor(currentColor)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: timeRemaining)

                Text("\(Int(max(0, timeRemaining)))")
                    .font(.custom("ZonaPro-Bold", size: 16))
                    .foregroundColor(currentColor)
            }
            .frame(width: 40, height: 40)
        }
        .padding(.horizontal)
    }
}


