import Cocoa


@IBDesignable
class ColoredView: NSView {
    @IBInspectable var backgroundColor: NSColor? {
        didSet {
            self.updateLayer()
        }
    }
    
    override var wantsUpdateLayer: Bool {
        return true
    }
    
    override func updateLayer() {
        super.updateLayer()
        self.layer?.backgroundColor = backgroundColor?.cgColor
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self._init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self._init()
    }
    
    private func _init() {
        self.wantsLayer = true
    }
}
