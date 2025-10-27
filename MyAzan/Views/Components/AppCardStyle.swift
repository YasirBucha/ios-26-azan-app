import SwiftUI

// MARK: - App Card Style Component
struct AppCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .white.opacity(0.2), radius: 8, x: 0, y: 4)
            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Convenience Extension
extension View {
    func appCardStyle() -> some View {
        self.modifier(AppCardStyle())
    }
}

// MARK: - Alternative Card Style (Ultra Thin Material)
struct AppCardStyleMaterial: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .white.opacity(0.2), radius: 8, x: 0, y: 4)
            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Convenience Extension for Material Style
extension View {
    func appCardStyleMaterial() -> some View {
        self.modifier(AppCardStyleMaterial())
    }
}

// MARK: - Minimal Card Style (Subtle Border Only)
struct AppCardStyleMinimal: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
    }
}

// MARK: - Convenience Extension for Minimal Style
extension View {
    func appCardStyleMinimal() -> some View {
        self.modifier(AppCardStyleMinimal())
    }
}