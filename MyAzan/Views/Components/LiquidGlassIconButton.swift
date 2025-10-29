import SwiftUI

struct LiquidGlassIconButton: View {
    let systemName: String
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white.opacity(0.9))
            .frame(width: 44, height: 44)
            .glassedEffect(in: Circle(), interactive: true)
            .contentShape(Circle())
            .accessibilityLabel(Text(systemName))
    }
}

// MARK: - Backwards Compatibility Extension
extension View {
    @ViewBuilder
    func glassedEffect<S: Shape>(in shape: S, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(interactive ? .clear.interactive() : .clear, in: shape)
        } else {
            // Fallback glass-like implementation for pre-iOS 26
            self.background {
                shape
                    .fill(.ultraThinMaterial)
                    .overlay(
                        shape.stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                    )
                    .shadow(color: .white.opacity(0.2), radius: 6, x: 0, y: 2)
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
            }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [Color(red: 0.05, green: 0.29, blue: 0.36), Color(red: 0.04, green: 0.23, blue: 0.29)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        HStack(spacing: 20) {
            LiquidGlassIconButton(systemName: "gearshape.fill")
            LiquidGlassIconButton(systemName: "chevron.left")
        }
    }
}
