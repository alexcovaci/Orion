import Cocoa
import Combine


class BrowserViewController: NSViewController {
    @IBOutlet var toolbar: NSToolbar!
    @IBOutlet weak var goBackToolbarItem: NSToolbarItem!
    @IBOutlet weak var goForwardToolbarItem: NSToolbarItem!
    @IBOutlet weak var locationTextFieldView: ProgressTextFieldView!
    @IBOutlet weak var tabsView: TabsView!
    @IBOutlet weak var contentView: NSView!
    private var dependencyContainer: DependencyContainer
    private var cancellables = Set<AnyCancellable>()
    private var tabCancellables = Set<AnyCancellable>()
    private var selectedTab: TabModel? = nil
    private var installedExtensionIds: Set<String> = Set()
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
            .receive(on: RunLoop.main)
            .sink { [weak self] extensions in
                self?.updateToolbarWithExtensions(extensions)
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
                self?.locationTextFieldView.textField.stringValue = url?.absoluteString ?? ""
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
        
        browserCoordinator.selectedTab()?.$loadingProgress
            .receive(on: RunLoop.main)
            .sink { [weak self] loadingProgress in
                self?.locationTextFieldView.updateProgress(loadingProgress)
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
    
    private func updateToolbarWithExtensions(_ extensions: [ExtensionModel]) {
        let newExtensionIds = Set(extensions.map({ $0.id }))
        let addedExtensionIds = newExtensionIds.subtracting(installedExtensionIds)
        let removedExtensionIds = installedExtensionIds.subtracting(newExtensionIds)
        installedExtensionIds = newExtensionIds
        
        removedExtensionIds.forEach { extensionId in
            if let index = toolbar.items.firstIndex(where: { $0.itemIdentifier.rawValue == extensionId }) {
                toolbar.removeItem(at: index)
            }
        }
        
        addedExtensionIds.forEach { extensionId in
            let itemIdentifier = NSToolbarItem.Identifier(extensionId)
            
            if toolbar.items.contains(where: { $0.itemIdentifier == itemIdentifier }) {
                return
            }
            
            toolbar.insertItem(withItemIdentifier: itemIdentifier, at: toolbar.items.count)
        }
    }
    
    @objc func removeExtension(_ sender: NSMenuItem) {
        Task {
            guard let window = self.view.window else { return }
            guard let extensionModel = sender.representedObject as? ExtensionModel else { return }
            
            let alert = SimpleAlert()
            alert.setMessage("Are you sure you want to remove the extension '\(extensionModel.manifest.name ?? "")'?")
            alert.addButton("Remove") { [weak self] in
                guard let self else { return }
                extensionsCoordinator.removeExtension(extensionModel)
            }
            alert.addButton("Cancel") {
            }
            await alert.beginSheetModal(for: window)
        }
    }
}

extension BrowserViewController: NSToolbarDelegate {
    private func setupToolbar() {
        toolbar.delegate = self
        
        view.window?.toolbar = toolbar
        view.window?.toolbarStyle = .unified
        
        locationTextFieldView.textField.action = #selector(navigateToLocationAction(_:))
    }
    
    @objc private func extensionToolbarItemClicked(_ toolbarItem: NSToolbarItem) {
        let extensionId = toolbarItem.itemIdentifier.rawValue
        guard let extensionModel = extensionsCoordinator
            .extensions
            .first(where: { $0.id == extensionId }) else {
            return
        }
        
        if extensionModel.manifest.browserAction?.defaultPopup?.isEmpty ?? true {
            return
        }
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentSize = CGSize(width: 250, height: 400)
        popover.contentViewController = ExtensionPopupViewController(
            extensionModel: extensionModel,
            dependencyContainer: dependencyContainer
        )
        popover.show(relativeTo: toolbarItem)
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
        locationTextFieldView.textField.becomeFirstResponder()
    }
    
    @IBAction func navigateToLocationAction(_ sender: Any) {
        browserCoordinator.selectedTab()?.webKitController?.navigateToLocation(locationTextFieldView.textField.stringValue)
        locationTextFieldView.textField.resignFirstResponder()
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let extensionId = itemIdentifier.rawValue
        guard let extensionModel = extensionsCoordinator.extensions.first(where: { $0.id == extensionId }) else { return nil }
        
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        toolbarItem.isBordered = true
        toolbarItem.label = extensionModel.manifest.name ?? ""
        toolbarItem.paletteLabel = extensionModel.manifest.name ?? ""
        toolbarItem.toolTip = extensionModel.manifest.name ?? ""
        
        var toolbarItemImage: NSImage? = nil
        if let largestImage = extensionModel.manifest.icons?.largestImage {
            let imagePath = extensionModel.directory.appending(path: largestImage, directoryHint: .notDirectory)
            let image = NSImage(contentsOf: imagePath)
            toolbarItemImage = image
        }
        
        let menu = NSMenu()
        let menuItem = NSMenuItem(title: "Remove Extension", action: #selector(removeExtension), keyEquivalent: "")
        menuItem.representedObject = extensionModel
        menuItem.target = self
        menu.addItem(menuItem)
        
        let toolbarItemView = MenuToolbarItemView(toolbarItem: toolbarItem)
        toolbarItemView.image = toolbarItemImage
        toolbarItemView.target = self
        toolbarItemView.action = #selector(extensionToolbarItemClicked(_:))
        toolbarItemView.longPressMenu = menu
        toolbarItem.view = toolbarItemView
        
        return toolbarItem
    }
}
