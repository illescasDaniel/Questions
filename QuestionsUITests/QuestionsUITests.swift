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
		app.navigationBars["Settings"].buttons["Main menu"].tap()
		app.buttons["INSTRUCTIONS"].tap()
		app.alerts["Instructions"].buttons["OK"].tap()
		
		app.buttons["START GAME"].tap()
		
		let tablesQuery = app.tables
		tablesQuery.staticTexts["Social"].tap()
		
		let pauseButton = app.buttons["Pause"]
		pauseButton.tap()
		app.buttons["Go back"].tap()
		tablesQuery.staticTexts["Technology"].tap()
		pauseButton.tap()
		app.buttons["Main menu"].tap()
		
    }
}
