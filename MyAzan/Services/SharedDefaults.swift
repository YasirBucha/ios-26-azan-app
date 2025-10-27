import Foundation

@MainActor
enum SharedDefaults {
    private static let suiteName = "group.com.myazan.app"
    private static var cachedShared: UserDefaults?

    private static var sharedContainer: UserDefaults? {
        if let cachedShared {
            return cachedShared
        }

        guard FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName) != nil,
              let defaults = UserDefaults(suiteName: suiteName) else {
            return nil
        }

        cachedShared = defaults
        return defaults
    }

    static func string(forKey key: String) -> String? {
        if let value = sharedContainer?.string(forKey: key) {
            return value
        }
        return UserDefaults.standard.string(forKey: key)
    }

    static func data(forKey key: String) -> Data? {
        if let value = sharedContainer?.data(forKey: key) {
            return value
        }
        return UserDefaults.standard.data(forKey: key)
    }

    static func set(_ value: Any?, forKey key: String) {
        if let value {
            UserDefaults.standard.set(value, forKey: key)
            sharedContainer?.set(value, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
            sharedContainer?.removeObject(forKey: key)
        }
    }
}
