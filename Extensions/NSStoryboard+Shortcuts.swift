import Cocoa


extension NSStoryboard {
    static var mainStoryboard: NSStoryboard {
        NSStoryboard(name: .mainStoryboard, bundle: nil)
    }
}

extension NSStoryboard.Name {
    static var mainStoryboard: NSStoryboard.Name {
        return NSStoryboard.Name("Main")
    }
}
