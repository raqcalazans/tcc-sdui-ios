import Testing
@testable import Brasileirao

@MainActor
struct GameListViewModelTests {

    let group1 = GameGroupDTO(title: "1ª RODADA", games: [])
    let group2 = GameGroupDTO(title: "2ª RODADA", games: [])
    let group3 = GameGroupDTO(title: "3ª RODADA", games: [])
    
    @Test("Cycle forward through groups")
    func testSelectNextGroup_ShouldCycleForwardCorrectly() {
        // Arrange
        let viewModel = GameListViewModel()
        viewModel.groups = [group1, group2, group3]
        viewModel.selectedGroupIndex = 0
        
        // Act
        viewModel.selectNextGroup()
        
        // Assert
        #expect(viewModel.selectedGroupIndex == 1)
        #expect(viewModel.currentGroup?.title == "2ª RODADA")
    }
    
    @Test("Cycle forward should wrap around from end to start")
    func testSelectNextGroup_WhenAtEnd_ShouldWrapToStart() {
        // Arrange
        let viewModel = GameListViewModel()
        viewModel.groups = [group1, group2, group3]
        viewModel.selectedGroupIndex = 2
        
        // Act
        viewModel.selectNextGroup()
        
        // Assert
        #expect(viewModel.selectedGroupIndex == 0)
        #expect(viewModel.currentGroup?.title == "1ª RODADA")
    }

    @Test("Cycle backward through groups")
    func testSelectPreviousGroup_ShouldCycleBackwardCorrectly() {
        // Arrange
        let viewModel = GameListViewModel()
        viewModel.groups = [group1, group2, group3]
        viewModel.selectedGroupIndex = 1
        
        // Act
        viewModel.selectPreviousGroup()
        
        // Assert
        #expect(viewModel.selectedGroupIndex == 0)
        #expect(viewModel.currentGroup?.title == "1ª RODADA")
    }

    @Test("Cycle backward should wrap around from start to end")
    func testSelectPreviousGroup_WhenAtStart_ShouldWrapToEnd() {
        // Arrange
        let viewModel = GameListViewModel()
        viewModel.groups = [group1, group2, group3]
        viewModel.selectedGroupIndex = 0
        
        // Act
        viewModel.selectPreviousGroup()
        
        // Assert
        #expect(viewModel.selectedGroupIndex == 2)
        #expect(viewModel.currentGroup?.title == "3ª RODADA")
    }
//    
//    @Test("Sync games should update groups on successful network fetch")
//    func testSyncGames_Success() async {
//        // Arrange
//        let mockScreenDTO = MockDTOs.screenDTO
//        let mockNetworkService = MockNetworkService(result: .success(mockScreenDTO))
//        
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try! ModelContainer(for: Game.self, Team.self, GameEvent.self, FilterGroup.self, configurations: config)
//        
//        let viewModel = GameListViewModel(networkService: mockNetworkService)
//        viewModel.modelContext = container.mainContext
//
//        // Act
//        await viewModel.syncGames()
//
//        // Assert
//        #expect(viewModel.isLoading == false)
//        #expect(viewModel.errorMessage == nil)
//        #expect(viewModel.groups.count == mockScreenDTO.groups.count)
//        #expect(viewModel.groups.first?.title == "AO VIVO")
//    }
//
//    @Test("Sync games should set error message on network failure")
//    func testSyncGames_Failure() async {
//        // Arrange
//        let mockNetworkService = MockNetworkService(result: .failure(TestError.networkFailed))
//        
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try! ModelContainer(for: Game.self, Team.self, GameEvent.self, FilterGroup.self, configurations: config)
//        
//        let viewModel = GameListViewModel(networkService: mockNetworkService)
//        viewModel.modelContext = container.mainContext
//
//        // Act
//        await viewModel.syncGames()
//
//        // Assert
//        #expect(viewModel.isLoading == false)
//        #expect(viewModel.groups.isEmpty == true)
//        #expect(viewModel.errorMessage != nil)
//        #expect(viewModel.errorMessage?.contains("network request failed") == true)
//    }
}
