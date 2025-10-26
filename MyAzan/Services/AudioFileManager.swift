import Foundation
import SwiftUI

class AudioFileManager: ObservableObject {
    static let shared = AudioFileManager()
    
    @Published var customAudioFiles: [CustomAudioFile] = []
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let defaultFileName = "azan_notification.mp3"
    
    private init() {
        loadCustomAudioFiles()
    }
    
    // MARK: - Default Audio
    func getDefaultAudioURL() -> URL? {
        // For now, use the file we know exists in the project
        let projectPath = "/Users/yb/Development/Azan/MyAzan/Assets/azan_notification.mp3"
        let projectURL = URL(fileURLWithPath: projectPath)
        
        if FileManager.default.fileExists(atPath: projectURL.path) {
            print("✅ Using project audio file: \(projectURL.path)")
            return projectURL
        }
        
        // Try bundle as fallback
        if let bundleURL = Bundle.main.url(forResource: "azan_notification", withExtension: "mp3") {
            print("✅ Using bundle audio file: \(bundleURL.path)")
            return bundleURL
        }
        
        print("❌ Default audio file not found")
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
        customAudioFiles = []
        
        // Load saved metadata from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "customAudioFiles"),
           let files = try? JSONDecoder().decode([CustomAudioFile].self, from: data) {
            customAudioFiles = files
        }
        
        // Check if files still exist on disk
        customAudioFiles = customAudioFiles.filter { file in
            let fileURL = documentsURL.appendingPathComponent(file.fileName)
            return FileManager.default.fileExists(atPath: fileURL.path)
        }
        
        saveCustomAudioFiles()
    }
    
    private func saveCustomAudioFiles() {
        if let data = try? JSONEncoder().encode(customAudioFiles) {
            UserDefaults.standard.set(data, forKey: "customAudioFiles")
        }
    }
    
    func addAudioFile(_ url: URL, name: String) {
        let fileName = UUID().uuidString + ".mp3"
        let destinationURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.copyItem(at: url, to: destinationURL)
            
            let customFile = CustomAudioFile(
                id: UUID(),
                fileName: fileName,
                displayName: name
            )
            
            customAudioFiles.append(customFile)
            saveCustomAudioFiles()
        } catch {
            print("Error copying audio file: \(error.localizedDescription)")
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
            let fileURL = documentsURL.appendingPathComponent(file.fileName)
            
            // Delete file from disk
            try? FileManager.default.removeItem(at: fileURL)
            
            // Remove from list
            customAudioFiles.removeAll { $0.id == id }
            saveCustomAudioFiles()
        }
    }
    
    func getAudioURL(for file: CustomAudioFile) -> URL {
        return documentsURL.appendingPathComponent(file.fileName)
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
