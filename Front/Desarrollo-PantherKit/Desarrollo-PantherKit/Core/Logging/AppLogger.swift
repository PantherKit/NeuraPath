import Foundation
import os

/// Lightweight logging wrapper around os.Logger with safe fallbacks
struct AppLogger {
    private let subsystem: String
    private let category: String
    private let logger: Any?

    init(subsystem: String = "com.neurapath.front", category: String) {
        self.subsystem = subsystem
        self.category = category
        if #available(iOS 14.0, *) {
            self.logger = Logger(subsystem: subsystem, category: category)
        } else {
            self.logger = nil
        }
    }

    static func make(category: String) -> AppLogger {
        AppLogger(category: category)
    }

    func info(_ message: String) {
        if #available(iOS 14.0, *), let osLogger = logger as? Logger {
            osLogger.info("\(message, privacy: .public)")
        } else {
            print("ℹ️ [\(category)] \(message)")
        }
    }

    func debug(_ message: String) {
        if #available(iOS 14.0, *), let osLogger = logger as? Logger {
            osLogger.debug("\(message, privacy: .public)")
        } else {
            print("🐞 [\(category)] \(message)")
        }
    }

    func error(_ message: String) {
        if #available(iOS 14.0, *), let osLogger = logger as? Logger {
            osLogger.error("\(message, privacy: .public)")
        } else {
            print("❌ [\(category)] \(message)")
        }
    }
}


