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
                        folderStructureInfo
                        addAudioButton
                        audioFilesList
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
                allowedContentTypes: [.mp3, .wav, .audio],
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
    
    // MARK: - View Components
    private var folderStructureInfo: some View {
        LiquidGlassBackground {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.blue)
                    Text("Audio Files Structure")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("Default Audio")
                            .font(.caption)
                        Spacer()
                        Text("Included in app")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("Custom Audio")
                            .font(.caption)
                        Spacer()
                        Text("Stored in Documents")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.leading, 20)
            }
            .padding()
        }
        .padding()
    }
    
    private var addAudioButton: some View {
        LiquidGlassBackground {
            Button(action: { showingFilePicker = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Custom Audio File")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
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
        .padding()
    }
    
    private var audioFilesList: some View {
        LiquidGlassBackground {
            VStack(alignment: .leading, spacing: 16) {
                Text("Audio Files")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                defaultAudioRow
                
                ForEach(audioFileManager.customAudioFiles) { file in
                    customAudioRow(for: file)
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
    }
    
    private var defaultAudioRow: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text(audioFileManager.getDefaultAudioName())
            Spacer()
            
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
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
    
    private func customAudioRow(for file: CustomAudioFile) -> some View {
        HStack {
            Image(systemName: "music.note")
                .foregroundColor(.blue)
            Text(file.displayName)
            Spacer()
            
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
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