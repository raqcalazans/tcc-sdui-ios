import Foundation

@MainActor
class GameListViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var groups: [GameGroupDTO] = []
    @Published var selectedGroupIndex: Int = 0
    
    private let networkService: NetworkServiceProtocol
    
    var currentGroup: GameGroupDTO? {
        return groups.indices.contains(selectedGroupIndex) ? groups[selectedGroupIndex] : nil
    }
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func syncGames() async {
        defer { isLoading = false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let screenDTO = try await networkService.fetchGames()
            
            self.groups = screenDTO.groups
            
        } catch {
            errorMessage = "Falha ao sincronizar os jogos: \(error.localizedDescription)"
        }
    }

    func selectNextGroup() {
        guard !groups.isEmpty else { return }
        selectedGroupIndex = (selectedGroupIndex + 1) % groups.count
    }

    func selectPreviousGroup() {
        guard !groups.isEmpty else { return }
        selectedGroupIndex = (selectedGroupIndex - 1 + groups.count) % groups.count
    }
}
