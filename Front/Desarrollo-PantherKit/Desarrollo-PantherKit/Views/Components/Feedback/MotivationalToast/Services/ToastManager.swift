import SwiftUI

final class ToastManager: ObservableObject, ToastPresenting {
    static let shared = ToastManager()
    
    @Published var currentToast: MotivationalFact?
    @Published var showToast: Bool = false
    
    private var timer: Timer?
    private var isEnabled: Bool = true
    
    private init() {
        scheduleNextToast(initialDelay: 5.0)
    }
    
    func showRandomToast() {
        guard isEnabled else { return }
        currentToast = MotivationalFact.random
        showToast = true
    }
    
    func dismissCurrentToast() {
        showToast = false
        currentToast = nil
        scheduleNextToast()
    }
    
    func enableToasts(_ enable: Bool) {
        isEnabled = enable
        if !enable {
            timer?.invalidate(); timer = nil
            dismissCurrentToast()
        } else if timer == nil {
            scheduleNextToast()
        }
    }
    
    private func scheduleNextToast(initialDelay: TimeInterval = 0) {
        timer?.invalidate()
        let randomInterval = initialDelay > 0 ? initialDelay : TimeInterval.random(in: 30...90)
        timer = Timer.scheduledTimer(withTimeInterval: randomInterval, repeats: false) { [weak self] _ in
            self?.showRandomToast()
        }
    }
}


