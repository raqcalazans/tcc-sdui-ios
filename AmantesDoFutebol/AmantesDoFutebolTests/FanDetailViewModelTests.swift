import XCTest
@testable import AmantesDoFutebol

@MainActor
final class FanDetailViewModelTests: XCTestCase {
    func testLoadRequestsFanAndScreenAndResolvesTeamLabel() async {
        let service = MockFanAPIService()
        let viewModel = FanDetailViewModel(fanId: 1, service: service)

        await viewModel.load()

        XCTAssertEqual(service.fetchedFanIDs, [1])
        XCTAssertEqual(viewModel.value(for: component("favoriteTeamId")), "Flamengo")
        XCTAssertEqual(viewModel.value(for: component("birthDate")), "03/02/1990")
        XCTAssertEqual(viewModel.value(for: component("location")), "Rio, RJ, Brasil")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testAgeValueUsesConfiguredAgeFormat() async {
        let service = MockFanAPIService()
        service.fans = [FanTestFixtures.fan(birthDate: "2000-01-01")]
        let viewModel = FanDetailViewModel(fanId: 1, service: service)
        await viewModel.load()
        let expected = FanDateFormatter.age(from: "2000-01-01").map { $0 == 1 ? "1 ano" : "\($0) anos" }

        XCTAssertEqual(viewModel.value(for: component("age")), expected ?? "—")
    }

    func testFrequencyValuesAreLocalized() async {
        let service = MockFanAPIService()
        let viewModel = FanDetailViewModel(fanId: 1, service: service)
        for (stored, displayed) in [("SEMPRE", "Sempre"), ("AS_VEZES", "Às vezes"), ("RARAMENTE", "Raramente"), ("NUNCA", "Nunca")] {
            service.fans = [FanTestFixtures.fan(stadiumFrequency: stored)]
            await viewModel.load()
            XCTAssertEqual(viewModel.value(for: component("stadiumFrequency")), displayed)
        }
    }

    func testLoadFailureSetsMessageAndTeamLookupFailureFallsBackToID() async {
        let service = MockFanAPIService()
        service.shouldFailOptions = true
        let viewModel = FanDetailViewModel(fanId: 4, service: service)

        await viewModel.load()

        XCTAssertEqual(viewModel.value(for: component("favoriteTeamId")), "FLA")
        XCTAssertNil(viewModel.errorMessage)

        service.shouldFailScreens = true
        await viewModel.load()
        XCTAssertEqual(viewModel.errorMessage, "Não foi possível carregar os dados deste fã.")
    }

    func testDeleteDelegatesIDAndPropagatesFailure() async {
        let service = MockFanAPIService()
        let viewModel = FanDetailViewModel(fanId: 12, service: service)
        do {
            try await viewModel.delete()
            XCTAssertEqual(service.deletedFanID, 12)
        } catch {
            XCTFail("Unexpected delete error: \(error)")
        }

        service.shouldFailDelete = true
        do {
            try await viewModel.delete()
            XCTFail("Expected delete to fail")
        } catch {
            XCTAssertEqual(error as? FanTestError, .network)
        }
    }

    private func component(_ id: String) -> ScreenComponent {
        FanTestFixtures.detailScreen.sections.flatMap(\.components).first { $0.id == id }!
    }
}
