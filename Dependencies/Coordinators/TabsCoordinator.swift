import Foundation
import Combine


class TabsCoordinator {
    private(set) var tabs: [TabModel] = []
    let tabsChange = PassthroughSubject<[TabModel], Never>()
    
    
    func addTab(_ tab: TabModel) {
        tabs.append(tab)
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
