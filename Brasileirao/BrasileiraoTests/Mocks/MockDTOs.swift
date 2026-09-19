import Foundation
@testable import Brasileirao

struct MockDTOs {
    
    // MARK: - Times
    static let teamFLA = TeamDTO(
        id: 1,
        name: "Flamengo",
        acronym: "FLA",
        logoURL: URL(string: "https://s.glbimg.com/es/sde/f/equipes/2014/04/14/flamengo_60x60.png")!,
        description: "Clube de maior torcida do Brasil."
    )
    
    static let teamPAL = TeamDTO(
        id: 2,
        name: "Palmeiras",
        acronym: "PAL",
        logoURL: URL(string: "https://s.glbimg.com/es/sde/f/equipes/2014/04/14/palmeiras_60x60.png")!,
        description: "Time de São Paulo."
    )
    
    static let teamCAM = TeamDTO(
        id: 3,
        name: "Atlético-MG",
        acronym: "CAM",
        logoURL: URL(string: "https://s.glbimg.com/es/sde/f/equipes/2014/04/14/atletico_mg_60x60.png")!,
        description: "O Galo de Minas."
    )
    
    static let teamINT = TeamDTO(
        id: 4,
        name: "Internacional",
        acronym: "INT",
        logoURL: URL(string: "https://s.glbimg.com/es/sde/f/equipes/2014/04/14/internacional_60x60.png")!,
        description: "Time do Rio Grande do Sul."
    )
    
    // MARK: - Jogos Individuais
    static let liveGame = GameDTO(
        id: 101,
        homeTeam: teamFLA,
        awayTeam: teamPAL,
        homeGoals: 1,
        awayGoals: 0,
        gameDateTime: Date(),
        stadium: "Maracanã",
        isLive: true,
        events: []
    )
    
    static let finishedGame = GameDTO(
        id: 102,
        homeTeam: teamCAM,
        awayTeam: teamINT,
        homeGoals: 2,
        awayGoals: 2,
        gameDateTime: Date().addingTimeInterval(-86400),
        stadium: "Arena MRV",
        isLive: false,
        events: []
    )
    
    static let scheduledGame = GameDTO(
        id: 103,
        homeTeam: teamPAL,
        awayTeam: teamCAM,
        homeGoals: nil,
        awayGoals: nil,
        gameDateTime: Date().addingTimeInterval(86400),
        stadium: "Allianz Parque",
        isLive: false,
        events: []
    )
    
    // MARK: - Grupos de Jogos
    static let liveGroup = GameGroupDTO(title: "AO VIVO", games: [liveGame])
    static let scheduledGroup = GameGroupDTO(title: "AGENDADOS", games: [scheduledGame])
    static let finishedGroup = GameGroupDTO(title: "ENCERRADOS", games: [finishedGame])

    // MARK: - Resposta Completa da API
    static let screenDTO = GameScreenDTO(
        screenTitle: "JOGOS",
        groups: [
            liveGroup,
            scheduledGroup,
            finishedGroup
        ]
    )
}
