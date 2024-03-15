import Foundation
import Combine


class BrowserCoordinator: Coordinator {
    private(set) var dependencyContainer: DependencyContainer
    private(set) var tabs: [TabModel] = []
    private(set) var history: HistoryService = HistoryService()
    let tabsChange = PassthroughSubject<[TabModel], Never>()
    
    
    init() {
        fatalError("Always use the designated initializer")
    }
    
    required init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
    
    func addTab(_ tab: TabModel) {
        tabs.append(tab)
        tab.createWebKitController(dependencyContainer: dependencyContainer)
        selectTab(tab)
    }
    
    func closeTab(_ tab: TabModel) {
        guard var index = tabs.firstIndex(where: { $0 == tab }) else { return }
        
        let removedTab = tabs.remove(at: index)
        var triggerUpdate = true
        
        if removedTab.isSelected {
            index = max(index - 1, 0)
            if index < tabs.count && tabs.count > 0 {
                let newSelectedTab = tabs[index]
                triggerUpdate = false
                selectTab(newSelectedTab)
            }
        }
        
        if triggerUpdate {
            tabsChange.send(tabs)
        }
    }
    
    func selectTab(_ tab: TabModel) {
        for index in tabs.indices {
            tabs[index].isSelected = tabs[index] == tab
        }
        tabsChange.send(tabs)
    }
    
    func selectedTab() -> TabModel? {
        return tabs.first(where: { $0.isSelected })
    }
}
