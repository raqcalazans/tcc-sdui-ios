import XCTest
@testable import AmantesDoFutebol

@MainActor
final class FanListViewModelTests: XCTestCase {
    func testLoadSortsFansAndMapsFavoriteTeamNames() async {
        let service = MockFanAPIService()
        service.fans = [FanTestFixtures.fan(id: 9), FanTestFixtures.fan(id: 2, favoriteTeamId: "PAL")]
        let viewModel = FanListViewModel(service: service)

        await viewModel.load()

        XCTAssertEqual(viewModel.fans.map(\.id), [2, 9])
        XCTAssertEqual(viewModel.teamNames["FLA"], "Flamengo")
        XCTAssertEqual(viewModel.teamNames["PAL"], "Palmeiras")
        XCTAssertEqual(viewModel.screen?.screenTitle, "Amantes do Futebol")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testScreenFailureSetsErrorAndResetsLoading() async {
        let service = MockFanAPIService()
        service.shouldFailScreens = true
        let viewModel = FanListViewModel(service: service)

        await viewModel.load()

        XCTAssertEqual(viewModel.errorMessage, "Não foi possível carregar os fãs. Verifique sua conexão e tente novamente.")
        XCTAssertFalse(viewModel.isLoading)
    }

    func testFanFailureSetsError() async {
        let service = MockFanAPIService()
        service.shouldFailFans = true
        let viewModel = FanListViewModel(service: service)

        await viewModel.load()

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.fans.isEmpty)
    }

    func testTeamOptionsFailureDoesNotDiscardFansOrFailList() async {
        let service = MockFanAPIService()
        service.shouldFailOptions = true
        let viewModel = FanListViewModel(service: service)

        await viewModel.load()

        XCTAssertEqual(viewModel.fans.count, 1)
        XCTAssertTrue(viewModel.teamNames.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
}
