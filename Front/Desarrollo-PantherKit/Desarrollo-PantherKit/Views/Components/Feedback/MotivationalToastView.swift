import SwiftUI

struct MotivationalToast: View {
    let fact: MotivationalFact
    let onDismiss: () -> Void
    
    @State private var opacity: Double = 0
    @State private var offset: CGFloat = 100
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icono o avatar
            Image(systemName: fact.icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.3, green: 0.6, blue: 0.9),
                            Color(red: 0.2, green: 0.4, blue: 0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                // Título
                Text(fact.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                // Mensaje
                Text(fact.message)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)
            }
            
            Spacer()
            
            // Botón de cerrar
            Button(action: {
                dismissToast()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.2),
                            Color(red: 0.2, green: 0.2, blue: 0.3)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(0.95)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 16)
        .opacity(opacity)
        .offset(y: offset)
        .onAppear {
            showToast()
            scheduleAutoDismiss()
        }
    }
    
    private func showToast() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            opacity = 1
            offset = 0
        }
    }
    
    private func dismissToast() {
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0
            offset = 100
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
    
    private func scheduleAutoDismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            dismissToast()
        }
    }
}

// Modelo para los datos motivacionales
struct MotivationalFact: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let icon: String
    
    static var random: MotivationalFact {
        return allFacts.randomElement()!
    }
    
    // Colección de datos motivacionales sobre mujeres en STEM
    static let allFacts: [MotivationalFact] = [
        MotivationalFact(
            title: "Ada Lovelace",
            message: "Considerada la primera programadora de la historia, escribió el primer algoritmo para ser procesado por una máquina en 1843.",
            icon: "laptopcomputer"
        ),
        MotivationalFact(
            title: "¿Sabías que?",
            message: "Marie Curie fue la primera persona en recibir dos premios Nobel en distintas disciplinas científicas: Física y Química.",
            icon: "atom"
        ),
        MotivationalFact(
            title: "Katherine Johnson",
            message: "Sus cálculos matemáticos fueron fundamentales para las primeras misiones espaciales de la NASA. Su historia inspiró la película 'Figuras Ocultas'.",
            icon: "airplane"
        ),
        MotivationalFact(
            title: "Dato curioso",
            message: "Grace Hopper, pionera en programación, acuñó el término 'bug' cuando encontró un insecto real causando un error en una computadora.",
            icon: "ladybug"
        ),
        MotivationalFact(
            title: "Hedy Lamarr",
            message: "Además de ser actriz de Hollywood, inventó un sistema de comunicaciones que es la base del WiFi, GPS y Bluetooth que usamos hoy.",
            icon: "wifi"
        ),
        MotivationalFact(
            title: "Rosalyn Yalow",
            message: "Desarrolló la técnica del radioinmunoensayo, revolucionando el diagnóstico médico, a pesar de que inicialmente le negaron un puesto de asistente graduada por ser mujer.",
            icon: "cross.case"
        ),
        MotivationalFact(
            title: "Dato inspirador",
            message: "El 40% de los graduados en matemáticas son mujeres. ¡Las mujeres tienen un papel fundamental en el futuro de STEM!",
            icon: "percent"
        ),
        MotivationalFact(
            title: "Ellen Ochoa",
            message: "Primera mujer hispana en viajar al espacio y ex directora del Centro Espacial Johnson de la NASA.",
            icon: "sparkles"
        ),
        MotivationalFact(
            title: "Ángela Ruiz Robles",
            message: "Maestra e inventora española, creó en 1949 la 'Enciclopedia Mecánica', considerada precursora del libro electrónico actual.",
            icon: "book"
        ),
        MotivationalFact(
            title: "¿Lo sabías?",
            message: "Los equipos diversos que incluyen mujeres tienen un 40% más de probabilidades de desarrollar patentes más innovadoras.",
            icon: "person.3"
        ),
        MotivationalFact(
            title: "Margarita Salas",
            message: "Bioquímica española cuyas investigaciones sobre el ADN han sido fundamentales para la biología molecular. Su patente ha sido la más rentable en la historia del CSIC.",
            icon: "dna"
        ),
        MotivationalFact(
            title: "Mary Jackson",
            message: "Primera ingeniera afroamericana en la NASA, superó barreras de segregación racial para conseguir su título y contribuir a la ingeniería aeroespacial.",
            icon: "paperplane"
        ),
        MotivationalFact(
            title: "Dato motivador",
            message: "Las empresas con mayor representación femenina en ingeniería y tecnología reportan un 34% mayor retorno a los accionistas.",
            icon: "chart.line.uptrend.xyaxis"
        ),
        MotivationalFact(
            title: "¡Tú puedes!",
            message: "Las mujeres en STEM ganan un 35% más que las mujeres en otros campos profesionales. ¡Las carreras STEM abren puertas!",
            icon: "dollarsign.circle"
        ),
        MotivationalFact(
            title: "Frances Allen",
            message: "Primera mujer en ganar el Premio Turing (el 'Nobel de la Computación') por sus contribuciones pioneras a la teoría y práctica de la optimización de compiladores.",
            icon: "gearshape"
        )
    ]
}

// Vista de gestión de Toasts para la aplicación
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var currentToast: MotivationalFact?
    @Published var showToast: Bool = false
    
    private var timer: Timer?
    private var isEnabled: Bool = true
    
    init() {
        // Iniciar el timer para mostrar toasts cada cierto tiempo
        scheduleNextToast(initialDelay: 5.0)
    }
    
    func showRandomToast() {
        guard isEnabled else { return }
        
        // Mostrar un toast aleatorio
        currentToast = MotivationalFact.random
        showToast = true
    }
    
    func dismissCurrentToast() {
        showToast = false
        currentToast = nil
        
        // Programar el siguiente toast
        scheduleNextToast()
    }
    
    func enableToasts(_ enable: Bool) {
        isEnabled = enable
        
        if !enable {
            timer?.invalidate()
            timer = nil
            dismissCurrentToast()
        } else if timer == nil {
            scheduleNextToast()
        }
    }
    
    private func scheduleNextToast(initialDelay: TimeInterval = 0) {
        // Invalidar timer existente
        timer?.invalidate()
        
        // Crear nuevo timer con intervalo aleatorio entre 30 y 90 segundos
        let randomInterval = initialDelay > 0 ? initialDelay : TimeInterval.random(in: 30...90)
        timer = Timer.scheduledTimer(withTimeInterval: randomInterval, repeats: false) { [weak self] _ in
            self?.showRandomToast()
        }
    }
}

// Modificador de vista para añadir toasts a cualquier vista
struct ToastViewModifier: ViewModifier {
    @ObservedObject private var toastManager = ToastManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                Spacer()
                
                if toastManager.showToast, let fact = toastManager.currentToast {
                    MotivationalToast(fact: fact) {
                        toastManager.dismissCurrentToast()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 20)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: toastManager.showToast)
        }
    }
}

// Extensión para facilitar el uso del modificador
extension View {
    func withMotivationalToasts() -> some View {
        self.modifier(ToastViewModifier())
    }
}

// Vista de previsualización
struct MotivationalToast_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button("Mostrar Toast") {
                ToastManager.shared.showRandomToast()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.2))
        .withMotivationalToasts()
    }
} 