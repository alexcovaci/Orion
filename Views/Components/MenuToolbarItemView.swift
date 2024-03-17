import Cocoa


class MenuToolbarItemView: NSView {
    private let toolbarItem: NSToolbarItem!
    private let imageView: NSImageView = NSImageView()
    weak open var target: AnyObject?
    var action: Selector?
    var longPressMenu: NSMenu?
    var image: NSImage? {
        didSet {
            imageView.image = image
        }
    }
    
    
    init(toolbarItem: NSToolbarItem) {
        self.toolbarItem = toolbarItem
        super.init(frame: .zero)
        setupViews()
        setupGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 35),
            widthAnchor.constraint(equalToConstant: 35),
            
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 25),
            imageView.widthAnchor.constraint(equalToConstant: 25),
        ])
    }
    
    private func setupGestureRecognizers() {
        let clickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(viewClicked))
        addGestureRecognizer(clickRecognizer)
        
        let pressRecognizer = NSPressGestureRecognizer(target: self, action: #selector(viewPressed))
        pressRecognizer.buttonMask = 0x1
        pressRecognizer.minimumPressDuration = 0.3
        pressRecognizer.allowableMovement = 10
        addGestureRecognizer(pressRecognizer)
    }
    
    @objc private func viewClicked(_ sender: NSClickGestureRecognizer) {
        if sender.state != .recognized { return }
        
        if let target, let action {
            NSApp.sendAction(action, to: target, from: toolbarItem)
        }
    }
    
    @objc private func viewPressed(_ sender: NSPressGestureRecognizer) {
        if sender.state != .began { return }
        
        if let longPressMenu {
            let location = sender.location(in: self)
            let screenLocation = self.window?.convertPoint(toScreen: self.convert(location, to: nil)) ?? NSPoint.zero
            
            longPressMenu.popUp(positioning: nil, at: screenLocation, in: nil)
        }
    }
}
