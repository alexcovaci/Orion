import Foundation
import Combine
import Zip


class ExtensionsCoordinator: Coordinator {
    private(set) var dependencyContainer: DependencyContainer
    @Published private(set) var extensions: [ExtensionModel] = []
    private var extensionsDirectoryUrl: URL?
    private var extensionsCatalogueUrl: URL?
    
    
    init() {
        fatalError("Always use the designated initializer")
    }
    
    required init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        
        Zip.addCustomFileExtension("xpi")
        
        setup()
        loadExtensions()
    }
    
    func fetchExtensionFromUrl(_ url: URL) async throws -> ExtensionModel {
        let extensionId = UUID().uuidString
        
        guard let extensionDirectory = try await unpackExtensionFromUrl(url, extensionId: extensionId) else { throw CocoaError(.fileWriteUnknown) }
        
        let manifestUrl = extensionDirectory.appending(path: "manifest.json", directoryHint: .notDirectory)
        let jsonData = try Data(contentsOf: manifestUrl)
        let manifest = try JSONDecoder().decode(ExtensionManifestModel.self, from: jsonData)
        
        return ExtensionModel(
            id: extensionId,
            directory: extensionDirectory,
            manifest: manifest
        )
    }
    
    func cleanupFetchedExtension(_ extension: ExtensionModel) {
        try? FileManager.default.removeItem(at: `extension`.directory)
    }
    
    func isExtensionInstalled(_ extension: ExtensionModel) -> Bool {
        return extensions.contains(where: { $0.manifest.id == `extension`.manifest.id })
    }
    
    func installExtension(_ extension: ExtensionModel) {
        guard let extensionsDirectoryUrl else { return }
        
        if isExtensionInstalled(`extension`) { return }
        
        let destinationDirectory = extensionsDirectoryUrl.appending(path: `extension`.id, directoryHint: .isDirectory)
        try? FileManager.default.moveItem(at: `extension`.directory, to: destinationDirectory)
        
        let savedExtension = ExtensionModel(
            id: `extension`.id,
            directory: destinationDirectory,
            manifest: `extension`.manifest
        )
        
        extensions.append(savedExtension)
        saveExtensions()
    }
    
    func removeExtension(_ extension: ExtensionModel) {
        try? FileManager.default.removeItem(at: `extension`.directory)
        extensions.removeAll(where: { $0 == `extension` })
        saveExtensions()
    }
    
    private func setup() {
        guard let documentsDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return }
        
        extensionsDirectoryUrl = documentsDirectory.appending(path: "Extensions", directoryHint: .isDirectory)
        if let extensionsDirectoryUrl {
            try? FileManager.default.createDirectory(at: extensionsDirectoryUrl, withIntermediateDirectories: true, attributes: nil)
            
            extensionsCatalogueUrl = extensionsDirectoryUrl.appending(path: "catalogue.json", directoryHint: .notDirectory)
        }
    }
    
    private func loadExtensions() {
        guard let extensionsCatalogueUrl else { return }
        
        if let jsonData = try? Data(contentsOf: extensionsCatalogueUrl) {
            let extensions = try? JSONDecoder().decode([ExtensionModel].self, from: jsonData)
            self.extensions = extensions ?? []
        }
    }
    
    private func saveExtensions() {
        guard let extensionsCatalogueUrl else { return }
        
        if let jsonData = try? JSONEncoder().encode(extensions) {
            try? jsonData.write(to: extensionsCatalogueUrl)
        }
    }
    
    private func unpackExtensionFromUrl(_ url: URL, extensionId: String) async throws -> URL? {
        let outputDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let originalFileName = url.lastPathComponent
        let destinationFileName = outputDirectory.appending(path: originalFileName, directoryHint: .notDirectory)
        
        try await download(from: url, writeTo: destinationFileName)
        
        let destinationDirectory = outputDirectory.appending(path: extensionId, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true, attributes: nil)
        
        try Zip.unzipFile(
            destinationFileName,
            destination: destinationDirectory,
            overwrite: false,
            password: nil
        )
        
        try FileManager.default.removeItem(at: destinationFileName)
        
        return destinationDirectory
    }
    
    private func download(from url: URL, writeTo destinationUrl: URL) async throws {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Download failed: Server responded with an error")
            return
        }
        
        try data.write(to: destinationUrl)
    }
}
