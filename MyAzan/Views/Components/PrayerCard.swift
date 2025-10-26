import SwiftUI

struct LiquidGlassBackground: View {
    let content: AnyView
    
    init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }
    
    var body: some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct PrayerCard: View {
    let prayer: PrayerTime
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        LiquidGlassBackground {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(prayer.arabicName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(prayer.isNext ? .primary : .secondary)
                    
                    Text(prayer.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(prayer.timeString)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(prayer.isNext ? .primary : .secondary)
                    
                    if prayer.isNext {
                        Text("Next Prayer")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.blue.opacity(0.1), in: Capsule())
                    }
                }
            }
            .padding()
        }
        .scaleEffect(prayer.isNext ? 1.02 : 1.0)
        .animation(.smooth(duration: 0.3), value: prayer.isNext)
    }
}
