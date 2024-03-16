import Foundation
import UniformTypeIdentifiers


extension URL {
    var mimeType: String {
        if let utType = UTType(filenameExtension: self.pathExtension) {
            return utType.preferredMIMEType ?? "application/octet-stream"
        }
        return "application/octet-stream"
    }
}
