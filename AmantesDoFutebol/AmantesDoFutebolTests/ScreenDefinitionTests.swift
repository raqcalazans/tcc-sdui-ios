import XCTest
@testable import AmantesDoFutebol

final class ScreenDefinitionTests: XCTestCase {
    func testDecodesServerDrivenFormAndItsOptionSources() {
        let screen = FanTestFixtures.formScreen()
        let components = screen.sections.flatMap(\.components)
        let teamPicker = components.first { $0.id == "favoriteTeamId" }
        let genderPicker = components.first { $0.id == "gender" }

        XCTAssertEqual(screen.screenTitle, "Cadastro de fã")
        XCTAssertEqual(screen.screenType, "FORM")
        XCTAssertEqual(teamPicker?.optionsSource?.path, "/api/v1/teams")
        XCTAssertEqual(genderPicker?.options?.map(\.label), ["Feminino", "Masculino", "Não Binário"])
        XCTAssertTrue(components.first { $0.id == "birthDate" }?.required == true)
    }

    func testDecodesListAndDestructiveDetailAction() {
        let listComponent = FanTestFixtures.listScreen.sections[0].components[0]
        let deleteAction = FanTestFixtures.detailScreen.actions.first { $0.id == "deleteFan" }

        XCTAssertEqual(listComponent.type, "FAN_LIST")
        XCTAssertEqual(listComponent.titleField, "name")
        XCTAssertEqual(listComponent.subtitleOptionsSource?.labelField, "name")
        XCTAssertEqual(deleteAction?.role, "DELETE")
        XCTAssertEqual(deleteAction?.requiresConfirmation, true)
    }

    func testMissingRequiredContractKeyFailsDecoding() {
        let invalidJSON = Data("{\"screenId\":\"x\"}".utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(ScreenDefinition.self, from: invalidJSON))
    }
}
