import Cocoa
import Combine


class BrowserWindowController: NSWindowController {
    private let windowContainer = DependencyContainer()
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        registerCoordinators()
        
        let browserController = NSStoryboard.mainStoryboard
            .instantiateController(identifier: BrowserViewController.identifier()) { [weak self] coder in
            guard let self else { return nil }
            return BrowserViewController(coder: coder, dependencyContainer: self.windowContainer)
        }
        
        contentViewController = browserController
    }
    
    private func registerCoordinators() {
        windowContainer.register(service: BrowserCoordinator.self)
        windowContainer.register(service: ExtensionsCoordinator.self)
    }
}
