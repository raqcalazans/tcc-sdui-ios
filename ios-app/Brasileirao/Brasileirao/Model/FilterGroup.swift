import Foundation

final class FilterGroup {
    
    var id: String
    var title: String
    var displayOrder: Int
    var games: [Game] = []

    init(
        title: String,
        displayOrder: Int
    ) {
        self.id = title
        self.title = title
        self.displayOrder = displayOrder
    }
}
