import XCTest

final class LaunchProUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.windows["LaunchPro"].exists)
    }
    
    func testSearchField() throws {
        let app = XCUIApplication()
        app.launch()
        let searchField = app.textFields["搜索应用..."]
        XCTAssertTrue(searchField.exists)
    }
}
