import Foundation
import Combine

final class TimerDriver: ObservableObject {
    @Published var tick: Date = Date()
    private var cancellable: AnyCancellable?
    private let interval: TimeInterval

    init(interval: TimeInterval) {
        self.interval = interval
    }

    func start() {
        cancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.tick = date
            }
    }

    func stop() {
        cancellable?.cancel()
        cancellable = nil
    }
}


