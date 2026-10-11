import XCTest
@testable import AmantesDoFutebol

@MainActor
final class FanRegistrationViewModelTests: XCTestCase {
    func testLoadRegistrationScreenAndInitialSelections() async {
        let service = MockFanAPIService()
        let viewModel = FanRegistrationViewModel(service: service)

        await viewModel.load()

        XCTAssertEqual(service.screenPaths, ["/api/v1/ui/fans/registration-screen"])
        XCTAssertEqual(viewModel.screen?.screenTitle, "Cadastro de fã")
        XCTAssertEqual(viewModel.values["favoriteTeamId"], "FLA")
        XCTAssertEqual(viewModel.values["stadiumFrequency"], "NUNCA")
        XCTAssertTrue(viewModel.requiredOptionsAvailable)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadEditScreenPrefillsValuesAndUsesFanID() async {
        let service = MockFanAPIService()
        let viewModel = FanRegistrationViewModel(fanId: 7, service: service)

        await viewModel.load()

        XCTAssertEqual(service.screenPaths, ["/api/v1/ui/fans/7/edit-screen"])
        XCTAssertEqual(service.fetchedFanIDs, [7])
        XCTAssertEqual(viewModel.screen?.screenTitle, "Editar fã")
        XCTAssertEqual(viewModel.values["birthDate"], "03/02/1990")
        XCTAssertTrue(viewModel.isEditing)
    }

    func testLoadScreenFailureSetsMessage() async {
        let service = MockFanAPIService()
        service.shouldFailScreens = true
        let viewModel = FanRegistrationViewModel(service: service)

        await viewModel.load()

        XCTAssertEqual(viewModel.errorMessage, "Não foi possível carregar a tela. Verifique sua conexão e tente novamente.")
        XCTAssertFalse(viewModel.isLoading)
    }

    func testRequiredOptionsFailureDisablesSubmit() async {
        let service = MockFanAPIService()
        service.shouldFailOptions = true
        let viewModel = FanRegistrationViewModel(service: service)

        await viewModel.load()

        XCTAssertFalse(viewModel.requiredOptionsAvailable)
        XCTAssertTrue(viewModel.optionsByComponent["favoriteTeamId"]?.isEmpty == true)
        XCTAssertTrue(viewModel.errorMessage?.contains("opções de Time favorito") == true)
    }

    func testCreateSendsISODateAndAllFormValues() async throws {
        let service = MockFanAPIService()
        let viewModel = FanRegistrationViewModel(service: service)
        await viewModel.load()
        fillForm(viewModel)

        try await viewModel.save()

        XCTAssertEqual(service.createdPayload?["name"], "Ana")
        XCTAssertEqual(service.createdPayload?["email"], "ana@example.com")
        XCTAssertEqual(service.createdPayload?["birthDate"], "1995-08-14")
        XCTAssertEqual(service.createdPayload?["gender"], "Feminino")
        XCTAssertEqual(service.createdPayload?["favoriteTeamId"], "FLA")
        XCTAssertEqual(service.createdPayload?["stadiumFrequency"], "SEMPRE")
        XCTAssertFalse(viewModel.isLoading)
    }

    func testUpdateSendsExistingFanID() async throws {
        let service = MockFanAPIService()
        let viewModel = FanRegistrationViewModel(fanId: 23, service: service)
        await viewModel.load()
        fillForm(viewModel)

        try await viewModel.save()

        XCTAssertEqual(service.updatedFanID, 23)
        XCTAssertEqual(service.updatedPayload?["birthDate"], "1995-08-14")
    }

    func testSaveRejectsMissingRequiredFieldAndInvalidBirthDate() async throws {
        let service = MockFanAPIService()
        let viewModel = FanRegistrationViewModel(service: service)
        await viewModel.load()
        fillForm(viewModel)
        viewModel.values["email"] = "  "

        do {
            try await viewModel.save()
            XCTFail("Expected missing required field error")
        } catch {
            XCTAssertEqual((error as? FanFormError)?.errorDescription, FanFormError.missingRequiredField.errorDescription)
        }

        fillForm(viewModel)
        viewModel.values["birthDate"] = "31/02/1995"
        do {
            try await viewModel.save()
            XCTFail("Expected invalid birth date error")
        } catch {
            XCTAssertEqual((error as? FanFormError)?.errorDescription, FanFormError.invalidBirthDate.errorDescription)
        }
    }

    func testSaveRejectsSelectionOutsideServerOptions() async throws {
        let service = MockFanAPIService()
        let viewModel = FanRegistrationViewModel(service: service)
        await viewModel.load()
        fillForm(viewModel)
        viewModel.values["favoriteTeamId"] = "INVALID"

        do {
            try await viewModel.save()
            XCTFail("Expected invalid selection error")
        } catch {
            XCTAssertEqual((error as? FanFormError)?.errorDescription, FanFormError.invalidSelection("Time favorito").errorDescription)
        }
    }

    func testSaveFailurePropagatesAndResetsLoading() async {
        let service = MockFanAPIService()
        service.shouldFailSave = true
        let viewModel = FanRegistrationViewModel(service: service)
        await viewModel.load()
        fillForm(viewModel)

        do {
            try await viewModel.save()
            XCTFail("Expected network error")
        } catch {
            XCTAssertEqual(error as? FanTestError, .network)
        }
        XCTAssertFalse(viewModel.isLoading)
    }

    private func fillForm(_ viewModel: FanRegistrationViewModel) {
        viewModel.values = [
            "name": "Ana",
            "email": "ana@example.com",
            "birthDate": "14/08/1995",
            "gender": "Feminino",
            "favoriteTeamId": "FLA",
            "city": "Rio",
            "state": "RJ",
            "country": "Brasil",
            "stadiumFrequency": "SEMPRE"
        ]
    }
}
