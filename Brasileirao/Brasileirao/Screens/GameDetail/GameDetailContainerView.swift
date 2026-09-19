import SwiftUI

struct GameDetailContainerView: View {
    let gameID: Int

    @StateObject private var viewModel: GameDetailViewModel
    
    init(gameID: Int) {
        self.gameID = gameID
        _viewModel = StateObject(wrappedValue: GameDetailViewModel(gameID: gameID))
    }
    
    var body: some View {
        Group {
            if let gameDTO = viewModel.game {
                let game = Game(from: gameDTO)
                GameDetailView(game: game)
            } else if viewModel.isLoading {
                ProgressView()
                    .navigationTitle(String(localized: "loading_indicator_title"))
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Color.clear
            }
        }
        .task {
            viewModel.loadGameDetails()
        }
    }
}
