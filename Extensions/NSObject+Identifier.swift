import Cocoa


extension NSObject {
    static func identifier() -> String {
        return String(describing: self)
    }
    
    static func userInterfaceIdentifier() -> NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier(identifier())
    }
}
