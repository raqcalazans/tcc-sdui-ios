import XCTest

final class AmantesDoFutebolUITestsLaunchTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchAndCaptureHomeScreen() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertTrue(app.navigationBars["Amantes do Futebol"].waitForExistence(timeout: 15))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "SDUI - Tela inicial"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
