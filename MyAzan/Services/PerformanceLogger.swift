import Foundation

// Minimal no-op performance logger used to keep logging calls without impacting runtime
enum PerformanceLogger {
    static func resetBaseline(_ label: String) {}
    static func event(_ label: String) {}
    static func start(_ label: String) {}
    static func end(_ label: String) {}
}


