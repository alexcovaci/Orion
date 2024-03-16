import Cocoa
import Combine


class TabCollectionViewItem: NSCollectionViewItem {
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var closeButton: NSButton!
    private var cancellables = Set<AnyCancellable>()
    private var trackingArea: NSTrackingArea?
    private var tabIsSelected: Bool = false
    private var exitCheckTimer: Timer?
    let onSelect = PassthroughSubject<Void, Never>()
    let onClose = PassthroughSubject<Void, Never>()
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.alphaValue = 0
        setupTrackingArea()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        setupTrackingArea()
    }
    
    func configure(with model: TabModel) {
        model.$title
            .receive(on: RunLoop.main)
            .sink { [weak self] title in
                self?.titleTextField.stringValue = title ?? ""
            }
            .store(in: &cancellables)
        
        model.$isSelected
            .receive(on: RunLoop.main)
            .sink { [weak self] isSelected in
                self?.tabIsSelected = isSelected
                self?.view.layer?.backgroundColor = (model.isSelected ? NSColor.clear : NSColor.controlBackgroundColor).cgColor
            }
            .store(in: &cancellables)
    }
    
    private func setupTrackingArea() {
        if let existingTrackingArea = trackingArea {
            self.view.removeTrackingArea(existingTrackingArea)
        }
        
        let options: NSTrackingArea.Options = [.activeAlways, .mouseEnteredAndExited]
        trackingArea = NSTrackingArea(rect: self.view.bounds, options: options, owner: self, userInfo: nil)
        self.view.addTrackingArea(trackingArea!)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        
        exitCheckTimer?.invalidate()
        exitCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            let mouseLocation = view.window?.mouseLocationOutsideOfEventStream ?? NSPoint.zero
            let localPoint = view.convert(mouseLocation, from: nil)
            
            if !view.bounds.contains(localPoint) {
                mouseExited(with: NSEvent())
            }
        }
        
        NSAnimationContext.runAnimationGroup { [weak self] context in
            guard let self else { return }
            
            context.duration = 0.2
            
            closeButton.animator().alphaValue = 1.0
            
            if !tabIsSelected, let color = view.layer?.backgroundColor {
                view.layer?.backgroundColor = NSColor(cgColor: color)?.withAlphaComponent(0.5).cgColor
            }
        }
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        
        exitCheckTimer?.invalidate()
        exitCheckTimer = nil
        
        NSAnimationContext.runAnimationGroup { [weak self] context in
            guard let self else { return }
            
            context.duration = 0.2
            
            closeButton.animator().alphaValue = 0.0
            
            if !tabIsSelected, let color = view.layer?.backgroundColor {
                view.layer?.backgroundColor = NSColor(cgColor: color)?.withAlphaComponent(1.0).cgColor
            }
        }
    }
    
    @IBAction func selectButtonAction(_ sender: Any) {
        onSelect.send()
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        onClose.send()
    }
}
