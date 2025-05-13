import SwiftUI
import UIKit          // ← Necesario para UIViewRepresentable
import Lottie         // ← Asegúrate de tener Lottie 4.x instalado

struct LottieView: UIViewRepresentable {
    /// Nombre del archivo .json dentro del bundle
    var filename: String
    
    /// Modo de reproducción (por defecto solo una vez)
    var loopMode: LottieLoopMode = .playOnce
    
    /// Bloque opcional que se ejecuta cuando la animación termina
    var onFinish: (() -> Void)? = nil

    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: .zero)
        
        // Lottie v4 → usa LottieAnimationView
        let animationView = LottieAnimationView(name: filename)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        // Reproduce la animación y dispara el callback al finalizar
        animationView.play { finished in
            if finished {
                onFinish?()
            }
        }
        
        containerView.addSubview(animationView)
        
        // Ajusta la animación para ocupar todo el contenedor
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Aquí actualizarías la animación si necesitas cambiar algo en runtime
    }
}
