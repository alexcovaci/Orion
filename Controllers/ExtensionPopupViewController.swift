import Cocoa
import WebKit


class ExtensionPopupViewController: NSViewController {
    private var extensionModel: ExtensionModel
    private var webView: WKWebView!
    private var localExtensionSchemeHandler: LocalExtensionSchemeHandler?
    private let browserApiBridge: BrowserAPIBridge
    
    
    init(extensionModel: ExtensionModel, dependencyContainer: DependencyContainer) {
        self.extensionModel = extensionModel
        self.browserApiBridge = BrowserAPIBridge(dependencyContainer: dependencyContainer)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        loadExtension()
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        localExtensionSchemeHandler = LocalExtensionSchemeHandler(
            extensionModel: extensionModel,
            configuration: configuration
        )
        configuration.userContentController = WKUserContentController()
        browserApiBridge.setupBridge(configuration: configuration)
        ScriptInjector.setupExtensionWebViewConfiguration(configuration)
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
        webView._backgroundColor = NSColor.clear
    }
    
    private func loadExtension() {
        if let scheme = localExtensionSchemeHandler?.scheme,
           let popup = extensionModel.manifest.browserAction?.defaultPopup,
           let url = URL(string: "\(scheme)://\(extensionModel.id)/\(popup)") {
            webView.load(URLRequest(url: url))
        }
    }
}
