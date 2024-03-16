import Foundation
import Combine


class HistoryService {
    @Published private(set) var history: [HistoryItemModel] = []
    private var historyCatalogueUrl: URL?
    
    
    init() {
        setup()
        loadHistory()
    }
    
    func addHistoryItem(title: String, url: String) {
        let historyItem = HistoryItemModel(
            id: UUID().uuidString,
            lastAccessTimestamp: Date(),
            title: title,
            url: url
        )
        
        if let firstItem = history.first, firstItem.url == historyItem.url {
            history.replaceSubrange(0..<1, with: [historyItem])
        } else {
            history.insert(historyItem, at: 0)
        }
        
        saveHistory()
    }
    
    func topSites() -> [HistoryItemModel] {
        var itemVisits: [HistoryItemModel: Int] = [:]
        
        for item in history {
            let existingKey = itemVisits.keys.first(where: { $0.url == item.url })
            if let existingKey {
                itemVisits[existingKey, default: 0] += 1
            } else {
                itemVisits[item, default: 0] += 1
            }
        }
        
        return itemVisits.sorted(by: { $0.value > $1.value }).map({ $0.key })
    }
    
    private func setup() {
        guard let documentsDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return }
        
        let directoryUrl = documentsDirectory.appending(path: "History", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        
        historyCatalogueUrl = directoryUrl.appending(path: "catalogue.json", directoryHint: .notDirectory)
    }
    
    private func loadHistory() {
        guard let historyCatalogueUrl else { return }
        
        if let jsonData = try? Data(contentsOf: historyCatalogueUrl) {
            let extensions = try? JSONDecoder().decode([HistoryItemModel].self, from: jsonData)
            self.history = extensions ?? []
        }
    }
    
    private func saveHistory() {
        guard let historyCatalogueUrl else { return }
        
        if let jsonData = try? JSONEncoder().encode(history) {
            try? jsonData.write(to: historyCatalogueUrl)
        }
    }
}
