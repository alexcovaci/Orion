import Cocoa
import Combine


class TabCollectionViewItem: NSCollectionViewItem {
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var closeButton: NSButton!
    private var cancellables = Set<AnyCancellable>()
    let onSelect = PassthroughSubject<Void, Never>()
    let onClose = PassthroughSubject<Void, Never>()
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cancellables.removeAll()
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
                self?.view.layer?.backgroundColor = (model.isSelected ? NSColor.clear : NSColor.controlBackgroundColor).cgColor
            }
            .store(in: &cancellables)
    }
    
    @IBAction func selectButtonAction(_ sender: Any) {
        onSelect.send()
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        onClose.send()
    }
}
