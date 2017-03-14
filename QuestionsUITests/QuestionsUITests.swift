import XCTest

@available(iOS 9.0, *)
class QuestionsUITests: XCTestCase {
	
    override func setUp() {
        super.setUp()

		XCUIApplication().launch()
    }
    
    func testButtons() {
		
		XCUIDevice.shared().orientation = .portrait

		let app = XCUIApplication()
		app.buttons["SETTINGS"].tap()
		
		let tablesQuery = app.tables
		tablesQuery.buttons["Licenses"].tap()
		app.navigationBars["Licenses"].buttons["Settings"].tap()
		tablesQuery.buttons["Reset game"].tap()
		app.sheets.buttons["Cancel"].tap()
		app.navigationBars["Settings"].buttons["Main menu"].tap()
		app.buttons["INSTRUCTIONS"].tap()
		app.alerts["Instructions"].buttons["OK"].tap()
		app.buttons["START GAME"].tap()
		tablesQuery.staticTexts["Technology"].tap()
		tablesQuery.staticTexts["Set 0"].tap()
		app.buttons["Pause"].tap()
		app.buttons["Go back"].tap()
		app.navigationBars["Technology"].buttons["Topics"].tap()
		app.navigationBars["Topics"].buttons["Main menu"].tap()
    }
}
