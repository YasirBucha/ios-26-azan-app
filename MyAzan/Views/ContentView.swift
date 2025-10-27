import SwiftUI

struct ContentView: View {
    @State private var showHome = false
    @Namespace private var logoTransition
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var prayerTimeService: PrayerTimeService
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        ZStack {
            if showHome {
                HomeView(logoTransition: logoTransition)
                    .environmentObject(locationManager)
                    .environmentObject(prayerTimeService)
                    .environmentObject(notificationManager)
                    .environmentObject(settingsManager)
                    .transition(.opacity)
            } else {
                SplashView(showHome: $showHome, logoTransition: logoTransition)
            }
        }
        .animation(.easeInOut(duration: 1.2), value: showHome)
    }
}

struct SplashView: View {
    @Binding var showHome: Bool
    var logoTransition: Namespace.ID
    @State private var gradientOpacity: Double = 0.0
    @State private var logoScale: Double = 0.85
    @State private var logoOpacity: Double = 0.0
    @State private var subtitleOffset: CGFloat = 5.0
    @State private var subtitleOpacity: Double = 0.0
    @State private var haloOpacity: Double = 0.0
    @State private var shimmerOffset: CGFloat = -200
    @State private var shimmerOpacity: Double = 0.0
    @State private var isTransitioning: Bool = false
    @State private var animationTask: Task<Void, Never>?
    @State private var transitionTriggered: Bool = false

    var body: some View {
        ZStack {
            // Splash gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.21, blue: 0.36), // #1a365d
                    Color(red: 0.18, green: 0.35, blue: 0.53)  // #2d5a87
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Animated overlay gradient for transition
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.29, blue: 0.36), // #0d4a5d
                    Color(red: 0.04, green: 0.23, blue: 0.29)  // #0a3a4a
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(isTransitioning ? 0.3 : 0.0)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: isTransitioning)
            
            // Blur overlay for depth
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(gradientOpacity * 0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Mosque Icon with Glass Halo
                ZStack {
                    // Glass halo glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.25), // #4DB8FF40
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .opacity(haloOpacity)
                        .blur(radius: 20)
                    
                    // Soft blur depth beneath logo
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 120, height: 120)
                        .opacity(haloOpacity * 0.3)
                        .blur(radius: 15)
                    
                    // Mosque Icon with matched geometry effect
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.92, green: 0.85, blue: 0.64), // #EBD9A4
                                    Color(red: 0.85, green: 0.77, blue: 0.51)  // #D9C483
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .matchedGeometryEffect(id: "logoIcon", in: logoTransition)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .shadow(color: Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.4), radius: 20, x: 0, y: 10)
                }
                
                // App Name with matched geometry effect
                Text("My Azan")
                    .font(.system(size: 38, weight: .semibold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.92, green: 0.85, blue: 0.64), // #EBD9A4
                                Color(red: 0.85, green: 0.77, blue: 0.51)  // #D9C483
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .matchedGeometryEffect(id: "logoText", in: logoTransition)
                    .opacity(logoOpacity)
                
                // Subtitle with matched geometry effect
                Text("Prayer Times")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.7)) // #C7E3E8
                    .kerning(0.6)
                    .matchedGeometryEffect(id: "subtitle", in: logoTransition)
                    .offset(y: subtitleOffset)
                    .opacity(subtitleOpacity)
            }
            
            // Light refract shimmer effect
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.6),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 200, height: 2)
                .offset(x: shimmerOffset)
                .opacity(shimmerOpacity)
                .blur(radius: 1)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            skipSplash()
        }
        .onAppear {
            beginAnimationSequence()
        }
        .onDisappear {
            animationTask?.cancel()
        }
    }
    
    private func beginAnimationSequence() {
        animationTask?.cancel()
        transitionTriggered = false
        let startTime = Date()
        
        animationTask = Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.6)) {
                gradientOpacity = 1.0
            }
            
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }
            
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75, blendDuration: 0)) {
                logoScale = 1.0
                logoOpacity = 1.0
                haloOpacity = 1.0
            }
            
            try? await Task.sleep(nanoseconds: 220_000_000)
            guard !Task.isCancelled else { return }
            
            withAnimation(.easeOut(duration: 0.4)) {
                subtitleOffset = 0.0
                subtitleOpacity = 1.0
            }
            
            let elapsed = Date().timeIntervalSince(startTime)
            let minimumDisplayDuration = 2.8
            if elapsed < minimumDisplayDuration {
                let remaining = minimumDisplayDuration - elapsed
                let nanos = UInt64(max(remaining, 0) * 1_000_000_000)
                if nanos > 0 {
                    try? await Task.sleep(nanoseconds: nanos)
                    guard !Task.isCancelled else { return }
                }
            }
            
            await performTransition()
        }
    }
    
    @MainActor
    private func performTransition(immediate: Bool = false) async {
        guard !transitionTriggered else { return }
        transitionTriggered = true
        
        if immediate {
            withAnimation(.easeInOut(duration: 1.2)) {
                showHome = true
            }
            animationTask = nil
            return
        }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            shimmerOpacity = 1.0
            shimmerOffset = 200
        }
        
        try? await Task.sleep(nanoseconds: 150_000_000)
        guard !Task.isCancelled else { return }
        
        withAnimation(.easeOut(duration: 0.35)) {
            isTransitioning = true
            logoScale = 1.08
            logoOpacity = 0.0
            haloOpacity = 0.0
            subtitleOpacity = 0.0
            gradientOpacity = 0.0
            shimmerOpacity = 0.0
        }
        
        try? await Task.sleep(nanoseconds: 250_000_000)
        guard !Task.isCancelled else { return }
        
        withAnimation(.easeInOut(duration: 1.2)) {
            showHome = true
        }
        animationTask = nil
    }
    
    private func skipSplash() {
        animationTask?.cancel()
        Task { @MainActor in
            await performTransition(immediate: true)
        }
    }
}

// Helper to use hex colors
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ContentView()
}
