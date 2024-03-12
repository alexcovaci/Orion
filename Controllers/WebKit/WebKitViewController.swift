import Cocoa
import WebKit
import WebKit_Private


class WebKitViewController: NSViewController {
    private var webView: WKWebView!
    private var webViewObservations: [NSKeyValueObservation] = []
    private weak var tabModel: TabModel!
    
    
    init(tabModel: TabModel) {
        self.tabModel = tabModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        webViewObservations.forEach({ $0.invalidate() })
        webViewObservations = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        setupObservations()
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: configuration)
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        webView._backgroundColor = NSColor.clear
        
        webView.navigationDelegate = self
        webView._historyDelegate = self
    }
    
    private func setupObservations() {
        webViewObservations.append(
            webView.observe(\.title) { [weak self] _, _ in
                self?.tabModel.title = self?.webView.title
            }
        )
        
        webViewObservations.append(
            webView.observe(\.url) { [weak self] _, _ in
                self?.tabModel.url = self?.webView.url
            }
        )
        
        webViewObservations.append(
            webView.observe(\.canGoBack) { [weak self] _, _ in
                self?.tabModel.canGoBack = self?.webView.canGoBack ?? false
            }
        )
        
        webViewObservations.append(
            webView.observe(\.canGoForward) { [weak self] _, _ in
                self?.tabModel.canGoForward = self?.webView.canGoForward ?? false
            }
        )
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func reload() {
        webView.reload()
    }
    
    func navigateToLocation(_ location: String) {
        func sanitizedURL() -> URL {
            var sanitizedLocation = location
            if !location.starts(with: "http") && !location.contains("://") {
                sanitizedLocation = "http://\(location)"
            }
            
            if sanitizedLocation.isValidURL, let url = URL(string: sanitizedLocation) {
                return url
            } else {
                return URL(string: "https://kagi.com/search?q=\(location)")!
            }
        }
        
        navigateToURL(sanitizedURL())
    }
    
    func navigateToURL(_ url: URL) {
        _ = view
        webView.load(URLRequest(url: url))
    }
}

extension WebKitViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        print("webView decidePolicyFor navigationAction \(navigationAction.request.url)")
        return .allow
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        print("webView decidePolicyFor navigationResponse \(navigationResponse.response.url)")
        return .allow
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webView didFailProvisionalNavigation \(navigation)")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        print("webView didFail \(navigation)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        print("webView didFailProvisionalNavigation \(navigation)")
    }
}

extension WebKitViewController: WKHistoryDelegatePrivate {
    func _webView(_ webView: WKWebView!, didNavigateWith navigationData: WKNavigationData!) {
        print("didNavigateWith :: \(webView.backForwardList.currentItem?.url) -- \(webView.backForwardList.currentItem?.initialURL) -- \(webView.backForwardList.currentItem?.title)")
//        if navigationData.destinationURL == navigationData.originalRequest.url {
//            addHistoryItem(title: navigationData.title, url: navigationData.destinationURL)
//        }
    }
    
    func _webView(_ webView: WKWebView!, didPerformClientRedirectFrom sourceURL: URL!, to destinationURL: URL!) {
        print("didPerformClientRedirectFrom :: \(sourceURL) -- \(destinationURL)")
    }
    
    func _webView(_ webView: WKWebView!, didPerformServerRedirectFrom sourceURL: URL!, to destinationURL: URL!) {
        print("didPerformServerRedirectFrom :: \(sourceURL) -- \(destinationURL)")
    }
    
    func _webView(_ webView: WKWebView!, didUpdateHistoryTitle title: String!, for URL: URL!) {
        print("didUpdateHistoryTitle :: \(title) -- \(URL)")
    }
}
