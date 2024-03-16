import Foundation
import WebKit


class ScriptInjector {
    static func setupContentWebViewConfiguration(_ configuration: WKWebViewConfiguration) {
        addMozillaButtonScript(configuration)
    }
    
    static func setupExtensionWebViewConfiguration(_ configuration: WKWebViewConfiguration) {
        addExtensionsAPIScript(configuration)
    }
    
    private static func addMozillaButtonScript(_ configuration: WKWebViewConfiguration) {
        guard let scriptUrl = Bundle.main.url(forResource: "addons_mozilla_org_change_button_title", withExtension: "js") else { return }
        guard let scriptContents = try? String(contentsOf: scriptUrl) else { return }
        
        let script = WKUserScript(source: scriptContents, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
    }
    
    private static func addExtensionsAPIScript(_ configuration: WKWebViewConfiguration) {
        guard let scriptUrl = Bundle.main.url(forResource: "extensions_api", withExtension: "js") else { return }
        guard let scriptContents = try? String(contentsOf: scriptUrl) else { return }
        
        let script = WKUserScript(source: scriptContents, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
    }
}
