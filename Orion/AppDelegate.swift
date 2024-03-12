import Cocoa


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowController: BrowserWindowController?
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        windowController = NSStoryboard.mainStoryboard.instantiateController(withIdentifier: BrowserWindowController.identifier()) as? BrowserWindowController
        windowController?.showWindow(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
