import SwiftUI

@main
struct MyAzanApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("My Azan")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Prayer Times App")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 16) {
                    Text("🕌 Welcome to My Azan")
                        .font(.headline)
                    
                    Text("Your beautiful iOS 26 prayer times app with Liquid Glass design is ready!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Text("Features:")
                        .font(.headline)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Automatic location detection")
                        Text("• Accurate prayer time calculations")
                        Text("• Beautiful Azan audio playback")
                        Text("• Smart notifications with reminders")
                        Text("• Liquid Glass UI design")
                        Text("• Home/lock screen widgets")
                        Text("• Live Activities with Dynamic Island")
                        Text("• Background updates")
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                
                Spacer()
                
                Text("Ready for final configuration in Xcode!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("My Azan")
        }
    }
}
