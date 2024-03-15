import Foundation


struct HistoryItemModel: Codable, Equatable, Hashable {
    var id: String
    let lastAccessTimestamp: Date
    let title: String
    let url: String
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
