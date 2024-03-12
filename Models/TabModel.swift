import Foundation
import Combine


class TabModel: Identifiable, Equatable {
    private var cancellables = Set<AnyCancellable>()
    private(set) var webKitController: WebKitViewController!
    let id: String = UUID().uuidString
    @Published var isSelected: Bool = false
    @Published var title: String? = nil
    @Published var url: URL?
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    
    
    static func == (lhs: TabModel, rhs: TabModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(url: URL? = nil) {
        self.url = url
        self.webKitController = WebKitViewController(tabModel: self)
        
        if let url {
            webKitController.navigateToURL(url)
        }
    }
}
