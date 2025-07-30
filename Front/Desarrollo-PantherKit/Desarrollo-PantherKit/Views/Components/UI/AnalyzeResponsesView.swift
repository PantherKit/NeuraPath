import SwiftUI

struct AnalyzeResponsesView: View {
    @State private var progress: Double = 0.0
    @State private var currentPhase = 0
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isRetrying = false
    @State private var retryCount = 0
    @State private var timer: Timer?
    @State private var stars: [AnalyzeStar] = []
    
    let phases = [
        "Procesando tus respuestas...",
        "Analizando tu perfil...",
        "Generando resultados...",
        "Casi listo..."
    ]
    
    let maxRetries = 3
    let onCompletion: () -> Void
    
    struct AnalyzeStar: Identifiable {
        let id = UUID()
        var position: CGPoint
        var scale: CGFloat
        var opacity: Double
        var rotationSpeed: Double
    }
    
    init(onCompletion: @escaping () -> Void) {
        self.onCompletion = onCompletion
    }
    
    var body: some View {
        ZStack {
            // Fondo
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            // Estrellas animadas
            ForEach(stars) { star in
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .position(star.position)
                    .scaleEffect(star.scale)
                    .opacity(star.opacity)
                    .rotationEffect(Angle(degrees: Double.random(in: 0...360)))
            }
            
            VStack(spacing: 30) {
                if showError {
                    // Vista de error
                    errorView
                } else {
                    // Vista de progreso
                    progressView
                }
            }
            .padding()
        }
        .onAppear {
            // Iniciar el proceso
            startProcess()
            
            // Generar estrellas
            generateStars()
            
            // Animar estrellas
            animateStars()
        }
    }
    
    // Vista de progreso
    private var progressView: some View {
        VStack(spacing: 30) {
            // Logo o imagen
            Image(systemName: "wand.and.stars")
                .font(.system(size: 70))
                .foregroundColor(.white)
                .shadow(color: .blue.opacity(0.8), radius: 10)
                .rotationEffect(Angle(degrees: progress * 360))
            
            // Texto de fase actual
            Text(phases[currentPhase])
                .font(.headline)
                .foregroundColor(.white)
                .transition(.opacity)
                .id("phase\(currentPhase)")
            
            // Barra de progreso
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: Color.blue))
                .frame(width: 250)
                .animation(.easeInOut, value: progress)
        }
    }
    
    // Vista de error
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("No se pudo conectar con el servidor")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(errorMessage)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                retryConnection()
            }) {
                Text(isRetrying ? "Reintentando..." : "Reintentar")
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(isRetrying ? Color.gray : Color.blue)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
            }
            .disabled(isRetrying)
            .shadow(color: .blue.opacity(0.5), radius: 5)
        }
    }
    
    // MARK: - Funciones de control
    
    private func startProcess() {
        progress = 0.0
        currentPhase = 0
        retryCount = 0
        showError = false
        
        // Simular progreso en fases
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation {
                if progress < 1.0 {
                    progress += 0.005
                }
                
                // Actualizar fase según progreso
                let newPhase = min(Int(progress * Double(phases.count)), phases.count - 1)
                if newPhase != currentPhase {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentPhase = newPhase
                    }
                }
                
                // Al llegar al 95% del progreso, enviar las respuestas
                if progress >= 0.30 && progress <= 0.31 {
                    sendResponses()
                }
            }
        }
    }
    
    // Simplified response handling - backend communication via ViewModel
    private func sendResponses() {
        // For frontend-only version, just simulate success
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Always complete successfully - real backend communication via ViewModel
            completeProgress()
        }
    }
    
    // Mostrar mensaje de error
    private func showErrorMessage(_ message: String) {
        timer?.invalidate()
        
        withAnimation {
            errorMessage = message
            showError = true
            isRetrying = false
        }
    }
    
    // Reintentar conexión
    private func retryConnection() {
        guard retryCount < maxRetries else {
            showErrorMessage("Se ha excedido el número máximo de intentos. Por favor, verifica tu conexión e inténtalo más tarde.")
            return
        }
        
        withAnimation {
            isRetrying = true
            retryCount += 1
        }
        
        // Reintentar después de un breve retraso
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            startProcess()
        }
    }
    
    // Completar el progreso y llamar al callback
    private func completeProgress() {
        // Asegurar que se muestre el progreso completo
        withAnimation(.easeInOut(duration: 1.0)) {
            progress = 1.0
            currentPhase = phases.count - 1
        }
        
        // Pausar brevemente en 100% y luego continuar
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            timer?.invalidate()
            onCompletion()
        }
    }
    
    // Generar estrellas aleatorias
    private func generateStars() {
        stars = (0..<30).map { _ in
            AnalyzeStar(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                scale: CGFloat.random(in: 0.1...0.3),
                opacity: Double.random(in: 0.1...0.9),
                rotationSpeed: Double.random(in: 0.5...2.0)
            )
        }
    }
    
    // Animar estrellas
    private func animateStars() {
        let baseAnimation = Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)
        
        for i in 0..<stars.count {
            withAnimation(baseAnimation.delay(Double.random(in: 0...2))) {
                stars[i].scale = CGFloat.random(in: 0.1...0.4)
                stars[i].opacity = Double.random(in: 0.3...1.0)
            }
        }
    }
}

#Preview {
    AnalyzeResponsesView {
        print("Completado")
    }
} 