import SwiftUI

struct ToastViewModifier: ViewModifier {
    @ObservedObject private var toastManager = ToastManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                Spacer()
                if toastManager.showToast, let fact = toastManager.currentToast {
                    MotivationalToast(fact: fact) { toastManager.dismissCurrentToast() }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 20)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: toastManager.showToast)
        }
    }
}

extension View {
    func withMotivationalToasts() -> some View {
        self.modifier(ToastViewModifier())
    }
}


