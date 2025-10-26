import SwiftUI
import UniformTypeIdentifiers

struct AudioManagementView: View {
    @StateObject private var audioFileManager = AudioFileManager.shared
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var audioManager = AudioManager()
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingFilePicker = false
    @State private var showingRenameDialog = false
    @State private var fileToRename: CustomAudioFile?
    @State private var newFileName = ""
    @State private var showingDeleteConfirmation = false
    @State private var fileToDelete: CustomAudioFile?
    
    private var bgColors: [Color] {
        colorScheme == .dark 
            ? [Color.black, Color.blue.opacity(0.1)]
            : [Color.white, Color.blue.opacity(0.05)]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: bgColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Add Audio Button
                        LiquidGlassBackground {
                            Button(action: { showingFilePicker = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Audio File")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        
                        // Audio Files List
                        LiquidGlassBackground {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Audio Files")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                // Default Audio
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(audioFileManager.getDefaultAudioName())
                                    Spacer()
                                    
                                    // Preview Button for Default Audio
                                    Button(action: {
                                        if audioManager.isCurrentlyPlayingDefault() {
                                            audioManager.stopAzan()
                                        } else {
                                            audioManager.previewAudio(useDefault: true)
                                        }
                                    }) {
                                        Image(systemName: audioManager.isCurrentlyPlayingDefault() ? "stop.circle.fill" : "play.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                    
                                    Text("Default")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.2))
                                        .foregroundColor(.green)
                                        .cornerRadius(8)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(12)
                                
                                // Custom Files
                                ForEach(audioFileManager.customAudioFiles) { file in
                                    HStack {
                                        Image(systemName: "music.note")
                                            .foregroundColor(.blue)
                                        Text(file.displayName)
                                        Spacer()
                                        
                                        // Preview Button for Custom Audio
                                        Button(action: {
                                            if audioManager.isCurrentlyPlaying(file.id) {
                                                audioManager.stopAzan()
                                            } else {
                                                audioManager.previewAudio(useDefault: false, customFileId: file.id)
                                            }
                                        }) {
                                            Image(systemName: audioManager.isCurrentlyPlaying(file.id) ? "stop.circle.fill" : "play.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.title2)
                                        }
                                        
                                        Button(action: {
                                            fileToRename = file
                                            newFileName = file.displayName
                                            showingRenameDialog = true
                                        }) {
                                            Image(systemName: "pencil")
                                                .foregroundColor(.blue)
                                        }
                                        Button(action: {
                                            fileToDelete = file
                                            showingDeleteConfirmation = true
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.05))
                                    .cornerRadius(12)
                                }
                                
                                if audioFileManager.customAudioFiles.isEmpty {
                                    Text("No custom audio files.")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                }
                            }
                            .padding()
                        }
                        .padding()
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationTitle("Audio Management")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.mp3, .wav],
                allowsMultipleSelection: false
            ) { result in
                if case .success(let urls) = result, let url = urls.first {
                    presentNameInput(for: url)
                }
            }
            .alert("Rename Audio File", isPresented: $showingRenameDialog) {
                TextField("File Name", text: $newFileName)
                Button("Cancel", role: .cancel) {}
                Button("Rename") {
                    if let file = fileToRename {
                        audioFileManager.updateAudioFileName(file.id, newName: newFileName)
                    }
                }
            } message: {
                Text("Enter a new name for this audio file")
            }
            .alert("Delete Audio File", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let file = fileToDelete {
                        audioFileManager.deleteAudioFile(file.id)
                        if settingsManager.settings.selectedAudioFileId == file.id {
                            settingsManager.updateUseDefaultAudio(true)
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this audio file?")
            }
        }
    }
    
    private func presentNameInput(for url: URL) {
        let alert = UIAlertController(title: "Name Audio File", message: "Enter a name for this audio file", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Audio Name" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                audioFileManager.addAudioFile(url, name: name)
            }
        })
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}
