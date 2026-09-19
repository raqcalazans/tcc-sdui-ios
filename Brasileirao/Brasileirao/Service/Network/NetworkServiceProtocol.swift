protocol NetworkServiceProtocol {
    
    func fetchGames() async throws -> GameScreenDTO
    func fetchSduiScreen(endpoint: String) async throws -> FormScreen
    func submitFanRegistration(endpoint: String, data: [String: String]) async throws
    func fetchGameDetail(id: Int) async throws -> GameDTO
}
