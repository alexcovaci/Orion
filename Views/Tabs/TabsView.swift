import Cocoa
import Combine


struct TabViewModel {
    let tab: TabModel
    var cancellables = Set<AnyCancellable>()
}

@IBDesignable
class TabsView: NSView {
    @IBOutlet var tabsContainerView: NSView!
    @IBOutlet weak var tabsCollectionView: NSCollectionView!
    private var cancellables = Set<AnyCancellable>()
    private var tabs: [TabViewModel] = []
    let onSelect = PassthroughSubject<TabModel, Never>()
    let onClose = PassthroughSubject<TabModel, Never>()
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    private func _init() {
        Bundle.main.loadNibNamed(String(describing: TabsView.self), owner: self, topLevelObjects: nil)
        
        addSubview(tabsContainerView)
        tabsContainerView.frame = bounds
        tabsContainerView.autoresizingMask = [.width, .height]
        
        let nib = NSNib(nibNamed: NSNib.Name(TabCollectionViewItem.identifier()), bundle: nil)
        tabsCollectionView.register(nib, forItemWithIdentifier: TabCollectionViewItem.userInterfaceIdentifier())
    }
    
    func update(with newTabs: [TabModel]) {
        var itemsToInsert = Set<IndexPath>()
        var itemsToDelete = Set<IndexPath>()
        
        let newIDs = Set(newTabs.map { $0.id })
        let oldIDs = Set(tabs.map { $0.tab.id })
        
        let idsToInsert = newIDs.subtracting(oldIDs)
        let idsToDelete = oldIDs.subtracting(newIDs)
        
        for (index, viewModel) in tabs.enumerated() {
            if idsToDelete.contains(viewModel.tab.id) {
                itemsToDelete.insert(IndexPath(item: index, section: 0))
            }
        }
        
        tabs = newTabs.map { TabViewModel(tab: $0) }
        
        for (index, tabModel) in newTabs.enumerated() {
            if idsToInsert.contains(tabModel.id) {
                itemsToInsert.insert(IndexPath(item: index, section: 0))
            }
        }
        
        tabsCollectionView.performBatchUpdates {
            tabsCollectionView.deleteItems(at: itemsToDelete)
            tabsCollectionView.insertItems(at: itemsToInsert)
        }
    }
}

extension TabsView: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabs.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let item = collectionView.makeItem(
            withIdentifier: TabCollectionViewItem.userInterfaceIdentifier(),
            for: indexPath
        ) as? TabCollectionViewItem else {
            fatalError("Expected to instantiate TabCollectionViewItem.")
        }
        
        guard indexPath.item >= 0 && indexPath.item < tabs.count else {
            fatalError("Tab index out of bounds.")
        }
        
        var tab = tabs[indexPath.item]
        item.configure(with: tab.tab)
        
        item.onSelect
            .sink { [weak self] _ in
                self?.onSelect.send(tab.tab)
            }
            .store(in: &tab.cancellables)
        
        item.onClose
            .sink { [weak self] _ in
                self?.onClose.send(tab.tab)
            }
            .store(in: &tab.cancellables)
        
        return item
    }
}
