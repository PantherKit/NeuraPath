import SwiftUI

struct AnalysisLoadingView: View {
    var body: some View {
        VStack(spacing: 15) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.cosmicCyan))
                .scaleEffect(1.2)
            Text("Obteniendo análisis personalizado...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.2), radius: 15)
        )
    }
}


