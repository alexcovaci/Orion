import Cocoa
import WebKit
import WebKit_Private


class WebKitViewController: NSViewController {
    private var dependencyContainer: DependencyContainer
    private var webView: WKWebView!
    private var webViewObservations: [NSKeyValueObservation] = []
    private weak var tabModel: TabModel!
    @Injected var browserCoordinator: BrowserCoordinator
    @Injected var extensionsCoordinator: ExtensionsCoordinator
    
    
    init(tabModel: TabModel, dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        self._browserCoordinator.setContainer(dependencyContainer)
        self._extensionsCoordinator.setContainer(dependencyContainer)
        
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
        configuration.userContentController = WKUserContentController()
        ScriptInjector.setupContentWebViewConfiguration(configuration)
        webView = WKWebView(frame: .zero, configuration: configuration)
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        webView.isInspectable = true
        webView._applicationNameForUserAgent = "Orion"
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
        
        webViewObservations.append(
            webView.observe(\.estimatedProgress) { [weak self] _, _ in
                self?.tabModel.loadingProgress = self?.webView.estimatedProgress ?? 0.0
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
                sanitizedLocation = "https://\(location)"
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
        webView.customUserAgent = UserAgentImpersonator.userAgentForHostname(navigationAction.request.url?.host())?.userAgent
        
        if let url = navigationAction.request.url {
            if url.host() == "addons.mozilla.org" && url.lastPathComponent.hasSuffix(".xpi") {
                Task {
                    guard let window = self.view.window else { return }
                    
                    do {
                        let fetchedExtension = try await extensionsCoordinator.fetchExtensionFromUrl(url)
                        guard let name = fetchedExtension.manifest.name else { return }
                        
                        if extensionsCoordinator.isExtensionInstalled(fetchedExtension) {
                            extensionsCoordinator.cleanupFetchedExtension(fetchedExtension)
                            
                            let alert = SimpleAlert()
                            alert.setMessage("This extension is already installed.")
                            alert.addButton("Ok", action: {})
                            await alert.beginSheetModal(for: window)
                            
                            return
                        }
                        
                        let alert = SimpleAlert()
                        alert.setMessage("Would you like to add the web extension '\(name)'?")
                        alert.addButton("Add") { [weak self] in
                            guard let self else { return }
                            extensionsCoordinator.installExtension(fetchedExtension)
                        }
                        alert.addButton("Cancel") { [weak self] in
                            guard let self else { return }
                            extensionsCoordinator.cleanupFetchedExtension(fetchedExtension)
                        }
                        await alert.beginSheetModal(for: window)
                    } catch {
                        let alert = SimpleAlert()
                        alert.setMessage("Something went wrong, please try again.")
                        alert.addButton("Ok", action: {})
                        await alert.beginSheetModal(for: window)
                    }
                }
                
                return .cancel
            }
        }
        
        return .allow
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        return .allow
    }
}

extension WebKitViewController: WKHistoryDelegatePrivate {
    func _webView(_ webView: WKWebView!, didUpdateHistoryTitle title: String!, for URL: URL!) {
        guard let urlString = webView.backForwardList.currentItem?.url.absoluteString else { return }
        browserCoordinator.history.addHistoryItem(title: title, url: urlString)
    }
}
