import Foundation
import WebKit


class BrowserAPIBridge: NSObject {
    private let bridgeName: String = "extension"
    private var dependencyContainer: DependencyContainer
    @Injected var browserCoordinator: BrowserCoordinator
    
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        self._browserCoordinator.setContainer(dependencyContainer)
    }
    
    func setupBridge(configuration: WKWebViewConfiguration) {
        configuration.userContentController.addScriptMessageHandler(self, contentWorld: .page, name: bridgeName)
    }
}

extension BrowserAPIBridge: WKScriptMessageHandlerWithReply {
    @MainActor
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) async -> (Any?, String?) {
        guard message.name == bridgeName,
              let jsonData = try? JSONSerialization.data(withJSONObject: message.body),
              let parsedMessage = try? JSONDecoder().decode(BrowserAPIMessage.self, from: jsonData)
        else {
            return (nil, nil)
        }
        
        switch parsedMessage.method {
        case .getTopSites:
            let topSites = browserCoordinator.history.topSites().map { historyItem in
                [
                    "title": historyItem.title,
                    "url": historyItem.url
                ]
            }
            return (topSites, nil)
        case .createTab:
            if let url = parsedMessage.url {
                browserCoordinator.addTab(TabModel(url: URL(string: url)))
            }
        case .updateTab:
            if let url = parsedMessage.url {
                browserCoordinator.selectedTab()?.webKitController?.navigateToLocation(url)
            }
        }
        
        return (nil, nil)
    }
}
