import Foundation
import Combine

@MainActor
class GameDetailViewModel: ObservableObject {
    
    @Published var game: GameDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let networkService: NetworkServiceProtocol
    private let gameID: Int

    init(gameID: Int, networkService: NetworkServiceProtocol = NetworkService()) {
        self.gameID = gameID
        self.networkService = networkService
    }

    func loadGameDetails() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                self.game = try await networkService.fetchGameDetail(id: gameID)
            } catch {
                self.errorMessage = "Erro ao carregar detalhes: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}
