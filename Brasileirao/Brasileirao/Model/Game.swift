import Foundation

final class Game {
    
    var id: Int
    var homeGoals: Int?
    var awayGoals: Int?
    var gameDateTime: Date
    var stadium: String
    var isLive: Bool
    var filterGroup: FilterGroup?
    var homeTeam: Team?
    var awayTeam: Team?
    var events: [GameEvent] = []
    
    init(
        id: Int,
        homeTeam: Team,
        awayTeam: Team,
        homeGoals: Int? = nil,
        awayGoals: Int? = nil,
        gameDateTime: Date,
        stadium: String,
        isLive: Bool
    ) {
        self.id = id
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeGoals = homeGoals
        self.awayGoals = awayGoals
        self.gameDateTime = gameDateTime
        self.stadium = stadium
        self.isLive = isLive
    }
}

extension Game {
    convenience init(from dto: GameDTO) {
        self.init(
            id: dto.id,
            homeTeam: Team(from: dto.homeTeam),
            awayTeam: Team(from: dto.awayTeam),
            homeGoals: dto.homeGoals,
            awayGoals: dto.awayGoals,
            gameDateTime: dto.gameDateTime,
            stadium: dto.stadium,
            isLive: dto.isLive
        )
        
        // Mapeia a lista de eventos do DTO para o modelo local
        self.events = dto.events.map { GameEvent(from: $0) }
    }
}
