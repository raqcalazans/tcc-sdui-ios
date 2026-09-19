struct GameGroupDTO: Codable, Identifiable {
    var id: String { title } 
    let title: String
    let games: [GameDTO]
}
