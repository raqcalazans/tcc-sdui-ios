import Testing
@testable import Brasileirao

class MockNetworkService: NetworkServiceProtocol {
    
    var result: Result<GameScreenDTO, Error>
    
    init(result: Result<GameScreenDTO, Error>) {
        self.result = result
    }
    
    func fetchGames() async throws -> Brasileirao.GameScreenDTO {
        return try result.get()
    }
}
