import SwiftUI

struct CompletionPanel: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            WelcomeCosmicBackground()
            VStack(spacing: 30) {
                Text("¡Misión Cumplida!")
                    .font(.custom("ZonaPro-Bold", size: 36))
                    .foregroundColor(.white)
                    .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.8), radius: 10, x: 0, y: 4)
                    .tracking(1)

                Text("Hemos recopilado información valiosa para conocer tus habilidades y perfil.")
                    .font(.custom("ZonaPro-Light", size: 18))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .tracking(0.3)
                    .padding(.horizontal, 20)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .shadow(color: .green.opacity(0.6), radius: 10)

                Spacer()

                Button(action: onContinue) {
                    Text("Continuar")
                        .font(.custom("ZonaPro-Bold", size: 20))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [AppTheme.Colors.cosmicCyan, AppTheme.Colors.cosmicBlue]),
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .cornerRadius(30)
                        .shadow(color: AppTheme.Colors.cosmicCyan.opacity(0.6), radius: 12, x: 0, y: 6)
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.3), lineWidth: 2))
                }
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
        }
    }
}


