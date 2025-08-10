import Foundation

protocol ToastPresenting: AnyObject {
    func showRandomToast()
    func dismissCurrentToast()
    func enableToasts(_ enable: Bool)
}


