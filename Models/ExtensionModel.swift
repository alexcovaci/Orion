import Foundation


struct ExtensionModel: Codable, Identifiable, Equatable {
    let id: String
    let directory: URL
    let manifest: ExtensionManifestModel
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
