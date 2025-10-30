import SwiftUI

// MARK: - Preview Cache Manager
@MainActor
class PreviewCacheManager: ObservableObject, @unchecked Sendable {
    static let shared = PreviewCacheManager()
    private var cache: [LiveActivityDesign: AnyView] = [:]

    private init() {}

    @MainActor
    func getPreview(for design: LiveActivityDesign) -> AnyView {
        if let cached = cache[design] {
            return cached
        }

        let preview = makePreview(for: design)
        cache[design] = preview
        return preview
    }

    @MainActor
    func preload(_ design: LiveActivityDesign) {
        guard cache[design] == nil else { return }
        cache[design] = makePreview(for: design)
    }

    @MainActor
    func hasCachedPreview(for design: LiveActivityDesign) -> Bool {
        cache[design] != nil
    }

    @MainActor
    func clearCache() {
        cache.removeAll()
    }

    @MainActor
    private func makePreview(for design: LiveActivityDesign) -> AnyView {
        switch design {
        case .liquidGlass:
            return AnyView(LiquidGlassPreview())
        case .minimalist:
            return AnyView(MinimalistPreview())
        case .islamicArt:
            return AnyView(IslamicArtPreview())
        case .timeline:
            return AnyView(TimelinePreview())
        case .circular:
            return AnyView(LiquidGlassPreview()) // Fallback to liquid glass
        }
    }
}

struct LiveActivityGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var selectedDesign: LiveActivityDesign
    @State private var showingSelectionConfirmation = false
    @StateObject private var cacheManager = PreviewCacheManager.shared
    @State private var didPrefetchPreviews = false
    @State private var preloadTask: Task<Void, Never>?

    init(initialDesign: LiveActivityDesign = .liquidGlass) {
        _selectedDesign = State(initialValue: initialDesign)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient matching the app
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.29, blue: 0.36), // #0d4a5d
                        Color(red: 0.04, green: 0.23, blue: 0.29)  // #0a3a4a
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with Back Button
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            Button(action: { dismiss() }) {
                                LiquidGlassIconButton(systemName: "chevron.left", interactive: false)
                            }
                            
                            Text("Live Activity Gallery")
                                .font(.system(size: 26, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .frame(maxWidth: .infinity)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                    
                    // Large Preview Section
                    VStack(spacing: 16) {
                        HStack {
                            Text("Preview")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                showingSelectionConfirmation = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Use \(selectedDesign.displayName)")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedDesignAccentColor)
                                )
                                .shadow(color: selectedDesignAccentColor.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                        }
                        
                        LiveActivityPreviewCard(design: selectedDesign)
                            .id(selectedDesign) // Force recreation when design changes
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    
                    // Compact Horizontal Selection
                    VStack(spacing: 16) {
                        Text("Select Design")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            ForEach(LiveActivityDesign.allCases.filter { $0 != .circular }, id: \.self) { design in
                                CompactDesignCard(
                                    design: design,
                                    isSelected: selectedDesign == design,
                                    onTap: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            selectedDesign = design
                                        }
                                    }
                                )
                                .frame(maxWidth: .infinity)
                                .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 24)
                    
                    // Design Details (Compact)
                    VStack(spacing: 12) {
                        CompactDesignDetailsCard(design: selectedDesign)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onAppear {
            let currentDesign = settingsManager.settings.liveActivityDesign
            if selectedDesign != currentDesign {
                selectedDesign = currentDesign
            }

            guard !didPrefetchPreviews else { return }
            didPrefetchPreviews = true
            let manager = cacheManager
            preloadTask = Task.detached(priority: .background) {
                for design in LiveActivityDesign.allCases {
                    if Task.isCancelled { break }
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    await MainActor.run {
                        manager.preload(design)
                    }
                }
            }
        }
        .alert("Change Live Activity Design", isPresented: $showingSelectionConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Apply") {
                settingsManager.settings.liveActivityDesign = selectedDesign
                dismiss()
            }
        } message: {
            Text("This will change your Live Activity design to \(selectedDesign.displayName). Any active Live Activities will be updated.")
        }
        .onDisappear {
            preloadTask?.cancel()
            preloadTask = nil
        }
    }
    
    private var selectedDesignAccentColor: Color {
        switch selectedDesign.accentColor {
        case "blue": return .blue
        case "teal": return .teal
        case "orange": return .orange
        case "green": return .green
        case "cyan": return .cyan
        default: return .blue
        }
    }
}

// MARK: - Compact Design Card
struct CompactDesignCard: View {
    let design: LiveActivityDesign
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: onTap) {
                VStack(spacing: 8) {
                    // Design icon
                    Image(systemName: design.iconName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSelected ? .white : designAccentColor)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(isSelected ? designAccentColor : designAccentColor.opacity(0.2))
                        )
                    
                    // Selection indicator
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(designAccentColor)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isSelected ? designAccentColor : Color.white.opacity(0.2),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Design name below the button
            Text(design.displayName)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var designAccentColor: Color {
        switch design.accentColor {
        case "blue": return .blue
        case "teal": return .teal
        case "orange": return .orange
        case "green": return .green
        case "cyan": return .cyan
        default: return .blue
        }
    }
}

// MARK: - Live Activity Preview Card
struct LiveActivityPreviewCard: View {
    let design: LiveActivityDesign
    @StateObject private var cacheManager = PreviewCacheManager.shared
    @State private var preview: AnyView?
    @State private var loadTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 16) {
            // Live Activity preview - Direct display
            if let preview {
                preview
                    .frame(maxWidth: .infinity) // Full width like real Live Activity
                    .frame(height: 120) // Actual Live Activity height
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.2))
                    )
                    .glassedEffect(in: RoundedRectangle(cornerRadius: 20), interactive: false)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
        .onAppear {
            loadPreview(showPlaceholder: false)
        }
        .onChange(of: design) { _ in
            let shouldShowPlaceholder = !cacheManager.hasCachedPreview(for: design)
            loadPreview(showPlaceholder: shouldShowPlaceholder)
        }
        .onDisappear {
            loadTask?.cancel()
            loadTask = nil
        }
    }

    private func loadPreview(showPlaceholder: Bool) {
        loadTask?.cancel()
        loadTask = nil

        if showPlaceholder {
            withAnimation(.easeOut(duration: 0.1)) {
                preview = nil
            }
        }

        let currentDesign = design
        loadTask = Task { @MainActor in
            let result = cacheManager.getPreview(for: currentDesign)
            if Task.isCancelled { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                preview = result
            }
        }
    }
}

// MARK: - Compact Design Details Card
struct CompactDesignDetailsCard: View {
    let design: LiveActivityDesign
    
    var body: some View {
        VStack(spacing: 8) {
            // Top row
            HStack(spacing: 16) {
                DetailItem(title: "Style", value: design.style)
                DetailItem(title: "Animation", value: design.animationLevel)
            }
            
            // Bottom row
            HStack(spacing: 16) {
                DetailItem(title: "Battery", value: design.batteryImpact)
                DetailItem(title: "Best For", value: design.bestFor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(designAccent.opacity(0.5))
        )
        .glassedEffect(in: RoundedRectangle(cornerRadius: 20), interactive: false)
    }

    private var designAccent: Color {
        switch design.accentColor {
        case "blue": return .blue
        case "teal": return .teal
        case "orange": return .orange
        case "green": return .green
        case "cyan": return .cyan
        default: return .blue
        }
    }
}

struct DetailItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview Components
struct LiquidGlassPreview: View {
    var body: some View {
        ZStack {
            // Liquid glass background
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.29, blue: 0.36),
                            Color(red: 0.04, green: 0.23, blue: 0.29)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .opacity(0.4)
                )
            
            VStack(spacing: 8) {
                HStack {
                    Text("MY AZAN")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.3, green: 0.72, blue: 1.0))
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("الفجر")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Fajr")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("5:30 AM")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("in 2h 15m")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                HStack {
                    Text("Progress to Next Prayer")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("New York")
                        .font(.system(size: 8, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.3, green: 0.72, blue: 1.0),
                                        Color(red: 0.0, green: 1.0, blue: 0.88)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * 0.45, height: 4)
                    }
                }
                .frame(height: 4)
            }
            .padding(12)
        }
    }
}

struct MinimalistPreview: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("MY AZAN")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("New York")
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 4) {
                Text("الفجر")
                    .font(.system(size: 16, weight: .light, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Fajr")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("5:30 AM")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text("Prayer Time")
                        .font(.system(size: 8, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("in 2h 15m")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("remaining")
                        .font(.system(size: 8, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 2)
                        .cornerRadius(1)
                    
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * 0.45, height: 2)
                        .cornerRadius(1)
                }
            }
            .frame(height: 2)
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct IslamicArtPreview: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.95, blue: 0.98),
                            Color(red: 0.92, green: 0.94, blue: 0.97)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
                    
                    Text("MY AZAN")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.4))
                    
                    Spacer()
                    
                    Text("New York")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                }
                
                HStack {
                    Circle().frame(width: 3, height: 3).foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
                    Text("الفجر")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.3))
                    Circle().frame(width: 3, height: 3).foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
                }
                
                Text("Fajr")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.5))
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.8, green: 0.6, blue: 0.2), lineWidth: 1)
                        .frame(width: 80, height: 40)
                    
                    VStack(spacing: 2) {
                        Text("5:30 AM")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.3))
                        
                        Text("in 2h 15m")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                    }
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(red: 0.8, green: 0.6, blue: 0.2).opacity(0.2))
                            .frame(height: 3)
                            .cornerRadius(1.5)
                        
                        Rectangle()
                            .fill(Color(red: 0.8, green: 0.6, blue: 0.2))
                            .frame(width: geometry.size.width * 0.45, height: 3)
                            .cornerRadius(1.5)
                    }
                }
                .frame(height: 3)
            }
            .padding(10)
        }
    }
}

struct TimelinePreview: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Prayer Times")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("New York")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("الفجر")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Fajr")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("5:30 AM")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text("in 2h 15m")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(8)
            .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
            
            VStack(spacing: 4) {
                HStack {
                    Circle().fill(Color.accentColor).frame(width: 4, height: 4)
                    Text("Fajr").font(.system(size: 8, weight: .medium)).foregroundColor(.primary)
                    Spacer()
                    Text("5:30 AM").font(.system(size: 8, weight: .medium, design: .monospaced)).foregroundColor(.primary)
                }
                
                HStack {
                    Circle().fill(Color.secondary.opacity(0.5)).frame(width: 4, height: 4)
                    Text("Dhuhr").font(.system(size: 8, weight: .medium)).foregroundColor(.secondary)
                    Spacer()
                    Text("12:15 PM").font(.system(size: 8, weight: .medium, design: .monospaced)).foregroundColor(.secondary)
                }
                
                HStack {
                    Circle().fill(Color.secondary.opacity(0.5)).frame(width: 4, height: 4)
                    Text("Asr").font(.system(size: 8, weight: .medium)).foregroundColor(.secondary)
                    Spacer()
                    Text("3:45 PM").font(.system(size: 8, weight: .medium, design: .monospaced)).foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct CircularProgressPreview: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.3, blue: 0.5),
                            Color(red: 0.05, green: 0.2, blue: 0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                HStack {
                    Text("MY AZAN")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("New York")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 60, height: 60)
                    
                    VStack(spacing: 2) {
                        Text("الفجر")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("5:30 AM")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("in 2h 15m")
                            .font(.system(size: 7, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    Text("45%")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding(10)
        }
    }
}


#Preview {
    LiveActivityGalleryView()
}
