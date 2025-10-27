import Foundation
import SwiftUI

@MainActor
class AudioFileManager: ObservableObject {
    static let shared = AudioFileManager()
    
    @Published var customAudioFiles: [CustomAudioFile] = []
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let customAudioFolder = "CustomAudioFiles"
    private let defaultFileName = "azan_notification.mp3"
    
    // Create custom audio folder if it doesn't exist
    private var customAudioURL: URL {
        let url = documentsURL.appendingPathComponent(customAudioFolder)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }
    
    private init() {
        loadCustomAudioFiles()
    }
    
    // MARK: - Default Audio
    func getDefaultAudioURL() -> URL? {
        // First try to get from app bundle (works on device)
        if let bundleURL = Bundle.main.url(forResource: "azan_notification", withExtension: "mp3") {
            print("✅ Using bundle audio file: \(bundleURL.path)")
            return bundleURL
        }
        
        // Try alternative extensions
        for ext in ["wav", "m4a", "aiff"] {
            if let bundleURL = Bundle.main.url(forResource: "azan_notification", withExtension: ext) {
                print("✅ Using bundle audio file (\(ext)): \(bundleURL.path)")
                return bundleURL
            }
        }
        
        // Fallback for development/simulator - check new folder structure
        let projectPath = "/Users/yb/Development/Azan/MyAzan/Assets/AudioFiles/Default/azan_notification.mp3"
        let projectURL = URL(fileURLWithPath: projectPath)
        
        if FileManager.default.fileExists(atPath: projectURL.path) {
            print("✅ Using project audio file (dev fallback): \(projectURL.path)")
            return projectURL
        }
        
        // Legacy fallback
        let legacyPath = "/Users/yb/Development/Azan/MyAzan/Assets/azan_notification.mp3"
        let legacyURL = URL(fileURLWithPath: legacyPath)
        
        if FileManager.default.fileExists(atPath: legacyURL.path) {
            print("✅ Using legacy project audio file: \(legacyURL.path)")
            return legacyURL
        }
        
        print("❌ Default audio file not found in bundle or project")
        print("❌ Bundle resources: \(Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil) ?? [])")
        return nil
    }
    
    func getDefaultAudioName() -> String {
        return UserDefaults.standard.string(forKey: "defaultAudioName") ?? "Default Azan"
    }
    
    func setDefaultAudioName(_ name: String) {
        UserDefaults.standard.set(name, forKey: "defaultAudioName")
    }
    
    // MARK: - Custom Audio Files
    func loadCustomAudioFiles() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            var loadedFiles: [CustomAudioFile] = []
            
            if let data = UserDefaults.standard.data(forKey: "customAudioFiles"),
               let files = try? JSONDecoder().decode([CustomAudioFile].self, from: data) {
                loadedFiles = files.filter { file in
                    let fileURL = self.customAudioURL.appendingPathComponent(file.fileName)
                    return FileManager.default.fileExists(atPath: fileURL.path)
                }
            }
            
            DispatchQueue.main.async {
                self.customAudioFiles = loadedFiles
                self.saveCustomAudioFiles()
            }
        }
    }
    
    private func saveCustomAudioFiles() {
        if let data = try? JSONEncoder().encode(customAudioFiles) {
            UserDefaults.standard.set(data, forKey: "customAudioFiles")
        }
    }
    
    func addAudioFile(_ url: URL, name: String) {
        // Get file extension from original URL
        let fileExtension = url.pathExtension.isEmpty ? "mp3" : url.pathExtension
        let fileName = UUID().uuidString + "." + fileExtension
        let destinationURL = customAudioURL.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.copyItem(at: url, to: destinationURL)
            
            let customFile = CustomAudioFile(
                id: UUID(),
                fileName: fileName,
                displayName: name
            )
            
            customAudioFiles.append(customFile)
            saveCustomAudioFiles()
            print("✅ Added custom audio file: \(name) (\(fileName))")
        } catch {
            print("❌ Error copying audio file: \(error.localizedDescription)")
        }
    }
    
    func updateAudioFileName(_ id: UUID, newName: String) {
        if let index = customAudioFiles.firstIndex(where: { $0.id == id }) {
            customAudioFiles[index].displayName = newName
            saveCustomAudioFiles()
        }
    }
    
    func deleteAudioFile(_ id: UUID) {
        if let file = customAudioFiles.first(where: { $0.id == id }) {
            let fileURL = customAudioURL.appendingPathComponent(file.fileName)
            
            // Delete file from disk
            try? FileManager.default.removeItem(at: fileURL)
            
            // Remove from list
            customAudioFiles.removeAll { $0.id == id }
            saveCustomAudioFiles()
            print("✅ Deleted custom audio file: \(file.displayName)")
        }
    }
    
    func getAudioURL(for file: CustomAudioFile) -> URL {
        return customAudioURL.appendingPathComponent(file.fileName)
    }
    
    func isDefaultAudio(_ fileName: String) -> Bool {
        return fileName == defaultFileName
    }
}

struct CustomAudioFile: Codable, Identifiable {
    let id: UUID
    let fileName: String
    var displayName: String
}
