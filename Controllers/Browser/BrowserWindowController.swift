import Cocoa
import Combine


class BrowserWindowController: NSWindowController {
    private let windowContainer = DependencyContainer()
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        windowContainer.register(service: TabsCoordinator() as TabsCoordinator)
        
        let browserController = NSStoryboard.mainStoryboard
            .instantiateController(identifier: BrowserViewController.identifier()) { [weak self] coder in
            guard let self else { return nil }
            return BrowserViewController(coder: coder, dependencyContainer: self.windowContainer)
        }
        
        contentViewController = browserController
    }
}
