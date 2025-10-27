import SwiftUI

struct LiquidGlassBackground: View {
    let content: AnyView
    
    init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }
    
    var body: some View {
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

struct PrayerCard: View {
    let prayer: PrayerTime
    @Environment(\.colorScheme) var colorScheme
    @State private var cardScale: Double = 1.0
    
    var body: some View {
        LiquidGlassBackground {
            HStack(spacing: 16) {
                // Prayer icon
                Image(systemName: iconForPrayer(prayer.name))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 24)
                
                // Arabic prayer name
                Text(prayer.arabicName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 60, alignment: .leading)
                
                // English prayer name
                Text(prayer.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Time
                Text(prayer.timeString)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .scaleEffect(cardScale)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                cardScale = 0.97
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    cardScale = 1.0
                }
            }
        }
    }
    
    private func iconForPrayer(_ prayerName: String) -> String {
        switch prayerName.lowercased() {
        case "fajr":
            return "sunrise"
        case "dhuhr", "zuhr":
            return "sun.max"
        case "asr":
            return "sun.horizon"
        case "maghrib":
            return "sunset"
        case "isha":
            return "moon"
        default:
            return "clock"
        }
    }
}