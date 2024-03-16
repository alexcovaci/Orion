import Cocoa


class TabsFlowLayout: NSCollectionViewFlowLayout {
    var minItemWidth: CGFloat = 200
    
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        return true
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView else { return }
        
        let availableWidth = collectionView.enclosingScrollView?.bounds.size.width ?? 0
        let itemCount = collectionView.numberOfItems(inSection: 0)
        let totalSpacing = self.minimumInteritemSpacing * CGFloat(itemCount - 1)
        
        let itemWidth = max((availableWidth - totalSpacing) / CGFloat(itemCount), minItemWidth)
        
        self.itemSize = CGSize(width: itemWidth, height: collectionView.bounds.size.height)
        self.scrollDirection = .horizontal
    }
}
