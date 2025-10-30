import Foundation
import QuartzCore

#if DEBUG
enum PerformanceLogger {
    private static var appLaunchTimestamp: CFTimeInterval = CACurrentMediaTime()

    static func resetBaseline(_ label: String) {
        appLaunchTimestamp = CACurrentMediaTime()
        event("Baseline reset: \(label)")
    }

    static func event(_ name: String, file: StaticString = #file, line: UInt = #line) {
        let delta = CACurrentMediaTime() - appLaunchTimestamp
        let fileName = (String(describing: file) as NSString).lastPathComponent
        let formatted = String(format: "%.3f", delta)
        print("🕒 [Perf +\(formatted)s] \(name) (\(fileName):\(line))")
    }
}
#else
enum PerformanceLogger {
    static func resetBaseline(_ label: String) {}
    static func event(_ name: String, file: StaticString = #file, line: UInt = #line) {}
}
#endif
