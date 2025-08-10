import SwiftUI

struct CircularTimer: View {
    let timeRemaining: Double
    let totalTime: Double
    let accentColor: Color
    let warningColor: Color

    var body: some View {
        ZStack {
            Circle().stroke(lineWidth: 4).opacity(0.3).foregroundColor(accentColor)
            Circle()
                .trim(from: 0.0, to: CGFloat(max(0, min(1, timeRemaining / totalTime))))
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: timeRemaining)
            Text("\(Int(max(0, timeRemaining)))")
                .font(.custom("ZonaPro-Bold", size: 16))
                .foregroundColor(color)
        }
        .frame(width: 40, height: 40)
    }

    private var color: Color {
        if timeRemaining > totalTime * 0.25 { return accentColor }
        if timeRemaining > totalTime * 0.1 { return .orange }
        return warningColor
    }
}


