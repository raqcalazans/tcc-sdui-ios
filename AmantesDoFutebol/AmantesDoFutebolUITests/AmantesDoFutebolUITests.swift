import XCTest

final class AmantesDoFutebolUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testHomeShowsServerDrivenTitleAndCreateAction() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()

        XCTAssertTrue(app.navigationBars["Amantes do Futebol"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["addFanButton"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["fanRow_1"].exists)
        attachScreenshot(of: app, named: "SDUI - Lista de fãs")
    }

    @MainActor
    func testCreateActionOpensServerDrivenForm() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()

        let addButton = app.buttons["addFanButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 15))
        addButton.tap()

        XCTAssertTrue(app.navigationBars["Cadastro de fã"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.textFields["name"].exists)
        XCTAssertTrue(app.textFields["email"].exists)
        XCTAssertTrue(app.textFields["birthDateField"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["genderPicker"].exists)
        XCTAssertTrue(app.buttons["Cadastrar fã"].exists)
        attachScreenshot(of: app, named: "SDUI - Cadastro de fã")
    }

    @MainActor
    func testFanRowOpensDetailsAndEditForm() {
        let app = launchApp()
        let fanRow = app.descendants(matching: .any)["fanRow_1"]
        XCTAssertTrue(fanRow.waitForExistence(timeout: 10))
        fanRow.tap()

        XCTAssertTrue(app.navigationBars["Detalhes do fã"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["detailRow_Nome"].exists)
        XCTAssertTrue(app.buttons["editFanButton"].exists)
        attachScreenshot(of: app, named: "SDUI - Detalhes do fã")

        app.buttons["editFanButton"].tap()
        XCTAssertTrue(app.navigationBars["Editar fã"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.textFields["name"].exists)
        attachScreenshot(of: app, named: "SDUI - Edição de fã")
    }

    @MainActor
    func testDeleteFanRemovesItFromTheList() {
        let app = launchApp()
        let fanRow = app.descendants(matching: .any)["fanRow_1"]
        XCTAssertTrue(fanRow.waitForExistence(timeout: 10))
        fanRow.tap()

        let deleteButton = app.buttons["deleteFanButton"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 10))
        deleteButton.tap()
        app.buttons["Excluir fã"].tap()

        XCTAssertTrue(app.staticTexts["Nenhum fã cadastrado"].waitForExistence(timeout: 10))
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        return app
    }

    @MainActor
    private func attachScreenshot(of app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
