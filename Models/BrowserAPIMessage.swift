import Foundation


enum BrowserAPIMethod: String, Codable {
    case getTopSites
    case createTab
    case updateTab
}

struct BrowserAPIMessage: Codable {
    let method: BrowserAPIMethod
    let url: String?
}
