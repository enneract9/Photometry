import SwiftUI
import UniformTypeIdentifiers

extension ModelStorage where Self == DefaultModelStorage {
    static var `default`: Self {
        DefaultModelStorage()
    }
}

@Observable                                                                 // TODO: Протоколу не нужно @Observable ???
final class DefaultModelStorage: ModelStorage {
    enum StorageError: Error {
        case folderCreationError
        case unsupportedFileExtension
        case modelCopyError
        case noAccess
    }
    
    var urls: [URL] = []
    private let fileManager: FileManager = .default
    private let modelsFolder: URL = .documentsDirectory.appendingPathComponent("Models/")
    
    init() {
        do {                                                                // TODO: Ошибки обработать бы
            try createFolderIfNeeded(at: modelsFolder)
            try load()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addModel(url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw StorageError.noAccess
        }
        guard
            let type = UTType(filenameExtension: url.pathExtension),        // TODO: && url.isFileURL ???
            supportedFileExtensions.contains(type)
        else {
            throw StorageError.unsupportedFileExtension
        }
        
        let newModelURL = modelsFolder
            .appendingPathComponent(url.lastPathComponent)
//            .appendingPathExtension(url.pathExtension)
        
        try fileManager.copyItem(at: url, to: newModelURL)
        
        url.stopAccessingSecurityScopedResource()
        
        guard fileManager.fileExists(atPath: newModelURL.path) else {
            throw StorageError.modelCopyError
        }
        urls.append(newModelURL)
    }
    
    func removeModel(url: URL) throws {
        try fileManager.removeItem(at: url)
        urls.removeAll { $0 == url }
    }
    
    private func createFolderIfNeeded(at url: URL) throws {
        var isDirectory: ObjCBool = false
        
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue {
            return
        }
        try fileManager.createDirectory(
            atPath: url.path,
            withIntermediateDirectories: true
        )
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue else {
            throw StorageError.folderCreationError
        }
    }
    
    private func load() throws {
        urls = try fileManager.contentsOfDirectory(
            at: modelsFolder,
            includingPropertiesForKeys: nil
        )
        .filter {
            if let type = UTType(filenameExtension: $0.pathExtension) {
                supportedFileExtensions.contains(type)
            } else {
                false
            }
        }
    }
}
