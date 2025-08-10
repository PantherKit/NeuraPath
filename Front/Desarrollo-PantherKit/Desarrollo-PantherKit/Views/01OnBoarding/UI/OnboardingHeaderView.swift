import SwiftUI

struct OnboardingHeaderView: View {
    let stepNumber: String
    let panelTitle: String
    let rightSubtitle: String

    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Circle()
                    .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.6))
                    .frame(width: 32, height: 32)
                    .overlay(Circle().stroke(AppTheme.Colors.spacePureWhite, lineWidth: 1))
                    .overlay(
                        Text(stepNumber)
                            .font(AppTheme.Space.spaceCaption(12))
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.Colors.spacePureWhite)
                    )

                Text(panelTitle)
                    .font(AppTheme.Space.spaceCaption(10))
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.Colors.spacePureWhite)
                    .tracking(0.5)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                            .fill(AppTheme.Colors.spaceDeepBlack.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Space.panelCornerRadius)
                                    .stroke(AppTheme.Colors.spacePureWhite, lineWidth: 1)
                            )
                    )
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(stepNumber)
                    .font(AppTheme.Space.spaceCaption(12))
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.spacePureWhite)

                Text(rightSubtitle)
                    .font(AppTheme.Space.spaceCaption(10))
                    .foregroundColor(AppTheme.Colors.spaceGray)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.horizontal, 20)
    }
}


