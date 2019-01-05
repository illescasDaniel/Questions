import XCTest

@available(iOS 9.0, *)
class QuestionsUITests: XCTestCase {
	
    override func setUp() {
        super.setUp()
		XCUIApplication().launch()
    }
    
    func testButtons() {
		
		XCUIDevice.shared.orientation = .portrait
		
		let app = XCUIApplication()
		app.buttons["Settings"].tap()
		app.navigationBars["Settings"].buttons["Questions"].tap()
		app.buttons["Topics"].tap()
		
		let tablesQuery = app.tables
		tablesQuery.cells.firstMatch.tap()
		tablesQuery.cells.firstMatch.tap()
		app.buttons["Pause"].tap()
		app.buttons["Main menu"].tap()
		app.buttons["Community"].tap()
		app.navigationBars["Community"].buttons["Questions"].tap()
	}
}
