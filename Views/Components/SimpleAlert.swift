import Cocoa


class SimpleAlert {
    typealias Action = ()->()
    private var alert: NSAlert
    private var buttons: [String: Action]
    
    
    init() {
        self.alert = NSAlert()
        self.alert.icon = NSImage(size: .zero)
        self.buttons = [:]
    }
    
    func setMessage(_ message: String) {
        alert.messageText = message
    }
    
    func addButton(_ text: String, action: @escaping Action) {
        alert.addButton(withTitle: text)
        buttons[text] = action
    }
    
    @MainActor
    func beginSheetModal(for window: NSWindow) async {
        let response = await alert.beginSheetModal(for: window)
        let buttonIndex = response.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
        if buttonIndex >= 0 && buttonIndex < alert.buttons.count {
            let buttonText = alert.buttons[buttonIndex].title
            if let buttonAction = buttons[buttonText] {
                buttonAction()
            }
        }
    }
}
