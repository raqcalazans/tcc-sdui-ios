import Foundation
@testable import AmantesDoFutebol

enum FanTestFixtures {
    static let teamOptions = [
        ScreenOption(id: "FLA", label: "Flamengo"),
        ScreenOption(id: "PAL", label: "Palmeiras")
    ]

    static func fan(
        id: Int = 1,
        name: String = "Ana Silva",
        birthDate: String = "1990-02-03",
        favoriteTeamId: String = "FLA",
        stadiumFrequency: String = "SEMPRE"
    ) -> Fan {
        Fan(
            id: id,
            name: name,
            email: "ana@example.com",
            birthDate: birthDate,
            gender: "Feminino",
            favoriteTeamId: favoriteTeamId,
            city: "Rio",
            state: "RJ",
            country: "Brasil",
            stadiumFrequency: stadiumFrequency
        )
    }

    static let listScreen = decode(FanScreenJSONFixtures.list)

    static func formScreen(title: String = "Cadastro de fã", actionTitle: String = "Cadastrar fã") -> ScreenDefinition {
        decode(title == "Editar fã" ? FanScreenJSONFixtures.edit : FanScreenJSONFixtures.registration)
    }

    static let detailScreen = decode(FanScreenJSONFixtures.detail)

    private static func decode(_ json: String) -> ScreenDefinition {
        try! JSONDecoder().decode(ScreenDefinition.self, from: Data(json.utf8))
    }
}

final class MockFanAPIService: FanAPIServiceProtocol {
    var fans: [Fan] = [FanTestFixtures.fan()]
    var options = FanTestFixtures.teamOptions
    var shouldFailScreens = false
    var shouldFailFans = false
    var shouldFailFan = false
    var shouldFailOptions = false
    var shouldFailSave = false
    var shouldFailDelete = false
    var screenPaths: [String] = []
    var fetchedFanIDs: [Int] = []
    var createdPayload: [String: String]?
    var updatedPayload: [String: String]?
    var updatedFanID: Int?
    var deletedFanID: Int?

    func fetchScreen(path: String) async throws -> ScreenDefinition {
        screenPaths.append(path)
        if shouldFailScreens { throw FanTestError.network }
        if path.hasSuffix("/list-screen") { return FanTestFixtures.listScreen }
        if path.hasSuffix("/detail-screen") { return FanTestFixtures.detailScreen }
        if path.hasSuffix("/edit-screen") { return FanTestFixtures.formScreen(title: "Editar fã", actionTitle: "Salvar alterações") }
        return FanTestFixtures.formScreen()
    }

    func fetchFans() async throws -> [Fan] {
        if shouldFailFans { throw FanTestError.network }
        return fans
    }

    func fetchFan(id: Int) async throws -> Fan {
        fetchedFanIDs.append(id)
        if shouldFailFan { throw FanTestError.network }
        return fans.first(where: { $0.id == id }) ?? FanTestFixtures.fan(id: id)
    }

    func fetchOptions(path: String, valueField: String, labelField: String) async throws -> [ScreenOption] {
        if shouldFailOptions { throw FanTestError.network }
        return options
    }

    func createFan(payload: [String: String]) async throws -> Fan {
        if shouldFailSave { throw FanTestError.network }
        createdPayload = payload
        return FanTestFixtures.fan()
    }

    func updateFan(id: Int, payload: [String: String]) async throws -> Fan {
        if shouldFailSave { throw FanTestError.network }
        updatedFanID = id
        updatedPayload = payload
        return FanTestFixtures.fan(id: id)
    }

    func deleteFan(id: Int) async throws {
        if shouldFailDelete { throw FanTestError.network }
        deletedFanID = id
    }
}

enum FanTestError: Error, Equatable {
    case network
}
