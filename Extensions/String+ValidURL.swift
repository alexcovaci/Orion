import Foundation


extension String {
    var isValidURL: Bool {
        guard let url = URL(string: self), let host = url.host else {
            return false
        }
        
        if url.scheme == nil {
            return false
        }
        
        let hostContainsDot = host.contains(".")
        
        return hostContainsDot
    }
}
