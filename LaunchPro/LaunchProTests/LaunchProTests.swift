import XCTest
@testable import LaunchPro

final class LaunchProTests: XCTestCase {
    func testApplicationScanner() throws {
        let scanner = ApplicationScanner.shared
        let expectation = XCTestExpectation(description: "Scan apps")
        scanner.scan { apps in
            XCTAssertGreaterThan(apps.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testAppController() throws {
        let controller = AppController.shared
        XCTAssertEqual(controller.gridSize, 6)
        XCTAssertEqual(controller.iconSize, 80.0)
    }
    
    func testThemeModel() throws {
        XCTAssertEqual(AppTheme.default.name, "默认")
        XCTAssertEqual(AppTheme.yearOfHorse.backgroundColor, "#C41E3A")
    }
}
