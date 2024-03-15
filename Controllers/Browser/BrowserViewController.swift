import Cocoa
import Combine


class BrowserViewController: NSViewController {
    @IBOutlet var toolbar: NSToolbar!
    @IBOutlet weak var goBackToolbarItem: NSToolbarItem!
    @IBOutlet weak var goForwardToolbarItem: NSToolbarItem!
    @IBOutlet weak var locationTextField: NSTextField!
    @IBOutlet weak var tabsView: TabsView!
    @IBOutlet weak var contentView: NSView!
    private var dependencyContainer: DependencyContainer
    private var cancellables = Set<AnyCancellable>()
    private var tabCancellables = Set<AnyCancellable>()
    private var selectedTab: TabModel? = nil
    @Injected var browserCoordinator: BrowserCoordinator
    @Injected var extensionsCoordinator: ExtensionsCoordinator
    
    
    init?(coder: NSCoder, dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        self._browserCoordinator.setContainer(dependencyContainer)
        self._extensionsCoordinator.setContainer(dependencyContainer)
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        openLandingTab()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        setupToolbar()
    }
    
    private func setupBindings() {
        browserCoordinator.tabsChange
            .sink(receiveValue: { [weak self] tabs in
                self?.setupTabBindings()
                self?.updateTabs(tabs)
                self?.updateCurrentWebKitView()
                
                if tabs.count == 0 {
                    self?.openLandingTab()
                }
            })
            .store(in: &cancellables)
        
        extensionsCoordinator.$extensions
            .sink { extensions in
                let names = extensions.map({ $0.manifest.name })
                print("have extensions: \(names)")
            }
            .store(in: &cancellables)
        
        tabsView.onSelect
            .sink { [weak self] tab in
                self?.browserCoordinator.selectTab(tab)
            }
            .store(in: &cancellables)
        
        tabsView.onClose
            .sink { [weak self] tab in
                self?.browserCoordinator.closeTab(tab)
            }
            .store(in: &cancellables)
    }
    
    private func setupTabBindings() {
        tabCancellables.removeAll()
        
        browserCoordinator.selectedTab()?.$url
            .receive(on: RunLoop.main)
            .sink { [weak self] url in
                self?.locationTextField.stringValue = url?.absoluteString ?? ""
            }
            .store(in: &tabCancellables)
        
        browserCoordinator.selectedTab()?.$canGoBack
            .receive(on: RunLoop.main)
            .sink { [weak self] canGoBack in
                self?.goBackToolbarItem.action = canGoBack ? #selector(self?.goBackAction) : nil
            }
            .store(in: &tabCancellables)
        
        browserCoordinator.selectedTab()?.$canGoForward
            .receive(on: RunLoop.main)
            .sink { [weak self] canGoForward in
                self?.goForwardToolbarItem.action = canGoForward ? #selector(self?.goForwardAction) : nil
            }
            .store(in: &tabCancellables)
    }
    
    private func openLandingTab() {
        browserCoordinator.addTab(TabModel(url: URL(string: "https://kagi.com")))
    }
    
    private func updateTabs(_ tabs: [TabModel]) {
        tabsView.update(with: tabs)
    }
    
    private func updateCurrentWebKitView() {
        if selectedTab != browserCoordinator.selectedTab() {
            selectedTab = browserCoordinator.selectedTab()
            contentView.subviews.forEach({ $0.removeFromSuperview()})
            
            if let view = selectedTab?.webKitController?.view {
                contentView.addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: contentView.topAnchor),
                    view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                    view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
                ])
            }
        }
    }
}

extension BrowserViewController {
    private func setupToolbar() {
        view.window?.toolbar = toolbar
        view.window?.toolbarStyle = .unified
        
        locationTextField.focusRingType = .none
    }
    
    @IBAction func goBackAction(_ sender: Any) {
        browserCoordinator.selectedTab()?.webKitController?.goBack()
    }
    
    @IBAction func goForwardAction(_ sender: Any) {
        browserCoordinator.selectedTab()?.webKitController?.goForward()
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        browserCoordinator.selectedTab()?.webKitController?.reload()
    }
    
    @IBAction func newTabAction(_ sender: Any) {
        browserCoordinator.addTab(TabModel(url: URL(string: "https://kagi.com")))
        locationTextField.becomeFirstResponder()
    }
    
    @IBAction func navigateToLocationAction(_ sender: Any) {
        browserCoordinator.selectedTab()?.webKitController?.navigateToLocation(locationTextField.stringValue)
        
        locationTextField.resignFirstResponder()
    }
}
