import SwiftUI

struct ResultsLoadingView: View {
    @State private var isRotating = false
    @State private var isPulsing = false
    @State private var currentMessageIndex = 0
    @State private var progress: CGFloat = 0.0

    let loadingMessages = [
        "Analizando tus respuestas...",
        "Calculando tu perfil STEM...",
        "Preparando recomendaciones personalizadas...",
        "¡Casi listo! Preparando tus resultados..."
    ]
    
    let rocketMessages = [
        "🚀 Preparando tu despegue profesional",
        "🧠 Analizando tus habilidades",
        "🔍 Identificando tus fortalezas",
        "💡 Descubriendo tu potencial"
    ]
    
    var body: some View {
        ZStack {
            // Fondo de gradiente 100% opaco
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.91, green: 0.95, blue: 0.98),
                    Color(red: 0.98, green: 0.94, blue: 0.93)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.bottom)

            VStack(spacing: 40) {
                // Cohete animado
                ZStack {
                    Text("🚀")
                        .font(.system(size: 80))
                        .rotationEffect(.degrees(isRotating ? 12 : -12))
                        .offset(y: isPulsing ? -20 : 0)
                        .shadow(color: Color.white.opacity(0.3), radius: 10)
                    
                    if isPulsing {
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.25, green: 0.72, blue: 0.85).opacity(0.5),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 40)
                            .offset(y: 60)
                            .blur(radius: 15)
                    }
                }

                // Mensajes y barra de progreso
                VStack(spacing: 20) {
                    Text(loadingMessages[currentMessageIndex])
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.4))
                        .shadow(color: Color.white.opacity(0.5), radius: 2)
                        .transition(.opacity.combined(with: .scale))
                    
                    Text(rocketMessages[currentMessageIndex])
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.4))
                        .shadow(color: Color.white.opacity(0.5), radius: 2)
                        .transition(.opacity)
                    
                    progressBar
                }
                .padding(.horizontal, 40)
            }
            .padding(.top, 40)
            .padding(.bottom, 60)
        }
        .cornerRadius(30, corners: [.topLeft, .topRight])
        // Eleva el panel al 85% de la altura de pantalla
        .frame(height: UIScreen.main.bounds.height * 0.85, alignment: .bottom)
        .onAppear {
            startAnimations()
            startMessageCycle()
            simulateProgress()
        }
    }
    
    private var progressBar: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.2))
                .frame(height: 12)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.25, green: 0.72, blue: 0.85),
                            Color(red: 0.2, green: 0.6, blue: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: progress * UIScreen.main.bounds.width * 0.7, height: 12)
                .shadow(color: Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.5), radius: 5)
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.black.opacity(0.5))
                .cornerRadius(20)
                .offset(x: progress * UIScreen.main.bounds.width * 0.7 - 20, y: -20)
                .opacity(progress > 0.1 ? 1 : 0)
        }
        .frame(width: UIScreen.main.bounds.width * 0.7)
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            isRotating = true
        }
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) {
            isPulsing = true
        }
    }
    
    private func startMessageCycle() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentMessageIndex = (currentMessageIndex + 1) % loadingMessages.count
            }
        }
    }
    
    private func simulateProgress() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            withAnimation(.linear(duration: 0.1)) {
                if progress < 1.0 {
                    progress += (progress > 0.8 ? 0.03 : 0.01)
                } else {
                    timer.invalidate()
                }
            }
        }
    }
}

#if DEBUG
struct ResultsLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsLoadingView()
    }
}
#endif
