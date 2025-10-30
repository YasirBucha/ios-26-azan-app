import SwiftUI

struct SplashScreenView: View {
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
    let namespace: Namespace.ID
    let minimumDisplayDuration: Double
    let onTransitionComplete: () -> Void

    init(namespace: Namespace.ID, minimumDisplayDuration: Double = 0.6, onTransitionComplete: @escaping () -> Void) {
        self.namespace = namespace
        self.minimumDisplayDuration = minimumDisplayDuration
        self.onTransitionComplete = onTransitionComplete
    }
    
    var body: some View {
        ZStack {
            // Static gradient background
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
                // App Logo with Glass Halo
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
                    
                    // App Icon with matched geometry effect
                    Image("AppIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .matchedGeometryEffect(id: "app_logo", in: namespace)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .shadow(color: Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.4), radius: 20, x: 0, y: 10)
                }
                
                // App Name
                Text("My Azan")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8)) // #FFFFFFCC
                    .opacity(logoOpacity)
                
                // Subtitle
                Text("Prayer Times")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.5)) // #C7E3E880
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
            PerformanceLogger.event("SplashScreenView onAppear")
        }
        .onDisappear {
            animationTask?.cancel()
            PerformanceLogger.event("SplashScreenView onDisappear")
        }
    }
    
    private func beginAnimationSequence() {
        animationTask?.cancel()
        transitionTriggered = false
        let startTime = Date()
        PerformanceLogger.event("Splash animation sequence started")
        
        animationTask = Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.4)) {
                gradientOpacity = 1.0
            }
            
            try? await Task.sleep(nanoseconds: 80_000_000)
            guard !Task.isCancelled else { return }
            
            withAnimation(.spring(response: 0.55, dampingFraction: 0.78, blendDuration: 0)) {
                logoScale = 1.0
                logoOpacity = 1.0
                haloOpacity = 1.0
            }
            
            try? await Task.sleep(nanoseconds: 120_000_000)
            guard !Task.isCancelled else { return }
            
            withAnimation(.easeOut(duration: 0.3)) {
                subtitleOffset = 0.0
                subtitleOpacity = 1.0
            }
            
            let elapsed = Date().timeIntervalSince(startTime)
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
        PerformanceLogger.event("Splash performTransition invoked immediate=\(immediate)")
        
        if immediate {
            onTransitionComplete()
            animationTask = nil
            return
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            shimmerOpacity = 1.0
            shimmerOffset = 200
        }
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        guard !Task.isCancelled else { return }
        
        withAnimation(.easeOut(duration: 0.25)) {
            isTransitioning = true
            logoScale = 1.08
            logoOpacity = 0.0
            haloOpacity = 0.0
            subtitleOpacity = 0.0
            gradientOpacity = 0.0
            shimmerOpacity = 0.0
        }
        
        try? await Task.sleep(nanoseconds: 120_000_000)
        guard !Task.isCancelled else { return }
        
        PerformanceLogger.event("Splash transition completed, dismissing splash")
        onTransitionComplete()
        animationTask = nil
    }
    
    private func skipSplash() {
        animationTask?.cancel()
        Task { @MainActor in
            await performTransition(immediate: true)
        }
    }
}

#Preview {
    @Namespace var previewNamespace
    return SplashScreenView(namespace: previewNamespace) {
        print("Transition complete")
    }
}
