import Foundation
import WebKit


class LocalExtensionSchemeHandler: NSObject, WKURLSchemeHandler {
    let scheme: String = "extension"
    private var extensionModel: ExtensionModel
    
    
    init(extensionModel: ExtensionModel, configuration: WKWebViewConfiguration) {
        self.extensionModel = extensionModel
        super.init()
        configuration.setURLSchemeHandler(self, forURLScheme: scheme)
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let requestUrl = urlSchemeTask.request.url else { return }
        guard let fileUrl = schemeUrlToLocalUrl(requestUrl) else { return }
        
        if let data = try? Data(contentsOf: fileUrl) {
            let response = URLResponse(
                url: requestUrl,
                mimeType: fileUrl.mimeType,
                expectedContentLength: data.count,
                textEncodingName: "utf-8"
            )
            
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        } else {
            urlSchemeTask.didFailWithError(NSError(domain: "LocalResourceError", code: 404, userInfo: nil))
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
    }
    
    private func schemeUrlToLocalUrl(_ url: URL) -> URL? {
        guard url.host() == extensionModel.id else { return nil }
        
        return extensionModel.directory.appending(path: url.path(), directoryHint: .checkFileSystem)
    }
}
