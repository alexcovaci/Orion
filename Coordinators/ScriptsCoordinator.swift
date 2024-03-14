import Foundation
import WebKit


class ScriptsCoordinator: Coordinator {
    private(set) var dependencyContainer: DependencyContainer
    
    
    required init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
    
    func setupWebViewConfiguration(_ configuration: WKWebViewConfiguration) {
        addMozillaButtonScript(configuration)
    }
    
    private func addMozillaButtonScript(_ configuration: WKWebViewConfiguration) {
        guard let scriptUrl = Bundle.main.url(forResource: "addons_mozilla_org_change_button_title", withExtension: "js") else { return }
        guard let scriptContents = try? String(contentsOf: scriptUrl) else { return }
        
        let script = WKUserScript(source: scriptContents, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
    }
}
