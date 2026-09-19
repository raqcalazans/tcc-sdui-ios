import SwiftUI
import Kingfisher

enum GameViewStyle {
    case row
    case header
}

struct GameView: View {
    
    let homeTeamDTO: TeamDTO
    let awayTeamDTO: TeamDTO
    let stadium: String
    let gameDateTime: Date
    let homeGoals: Int?
    let awayGoals: Int?
    let groupTitle: String
    let isLive: Bool
    let style: GameViewStyle

    init?(game: Game, style: GameViewStyle) {
        guard let homeTeam = game.homeTeam,
              let awayTeam = game.awayTeam else {
            return nil
        }

        self.homeTeamDTO = TeamDTO(id: homeTeam.id, name: homeTeam.name, acronym: homeTeam.acronym, logoURL: homeTeam.logoURL, description: homeTeam.teamDescription)
        self.awayTeamDTO = TeamDTO(id: awayTeam.id, name: awayTeam.name, acronym: awayTeam.acronym, logoURL: awayTeam.logoURL, description: awayTeam.teamDescription)
        
        self.stadium = game.stadium
        self.gameDateTime = game.gameDateTime
        self.homeGoals = game.homeGoals
        self.awayGoals = game.awayGoals
        self.groupTitle = game.filterGroup?.title ?? ""
        self.isLive = game.isLive
        self.style = style
    }
    
    init(gameDTO: GameDTO, groupTitle: String, style: GameViewStyle) {
        self.homeTeamDTO = gameDTO.homeTeam
        self.awayTeamDTO = gameDTO.awayTeam
        self.stadium = gameDTO.stadium
        self.gameDateTime = gameDTO.gameDateTime
        self.homeGoals = gameDTO.homeGoals
        self.awayGoals = gameDTO.awayGoals
        self.groupTitle = groupTitle
        self.isLive = gameDTO.isLive
        self.style = style
    }

    var body: some View {
        VStack(spacing: style == .header ? 20 : 12) {
            HStack {
                Text(stadium.components(separatedBy: ",").first ?? stadium)
                Text("game_details_separator")
                Text(gameDateTime.gameDayDisplay)
                Text("game_details_separator")
                Text(gameDateTime.gameTimeDisplay)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 16) {
                Text(homeTeamDTO.acronym)
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                KFImage(homeTeamDTO.logoURL)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                
                VStack {
                    if let homeGoals = homeGoals, let awayGoals = awayGoals {
                        Text("\(homeGoals) x \(awayGoals)")
                            .font(style == .header ? .largeTitle : .title2)
                            .fontWeight(.bold)
                    } else {
                        Text("game_score_separator")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    if isLive {
                        Text("live_badge_title")
                            .font(.caption).bold().foregroundColor(.red)
                    }
                }
                
                KFImage(awayTeamDTO.logoURL)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)

                Text(awayTeamDTO.acronym)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            
            if style == .row {
                Text("get_details_button")
                   .font(.system(size: 12, weight: .bold))
                   .foregroundColor(Color(red: 0.1, green: 0.7, blue: 0.3))
            }
        }
        .padding(.vertical, style == .header ? 20 : 8)
    }
}
