import XCTest

class QuestionsUITests: XCTestCase {
	
    override func setUp() {
        super.setUp()
        XCUIApplication().launch()
    }
    
    func testButtons() {
		
		XCUIDevice.sharedDevice().orientation = .Portrait
		
		let app = XCUIApplication()
		app.buttons["SETTINGS"].tap()
		
		let tablesQuery = app.tables
		let backgroundMusicSwitch = tablesQuery.switches["Background music"]
		backgroundMusicSwitch.tap()
		backgroundMusicSwitch.tap()
		
		app.navigationBars["Settings"].buttons["Main menu"].tap()
		app.buttons["INSTRUCTIONS"].tap()

		app.alerts["Instructions"].collectionViews.buttons["OK"].tap()
		app.buttons["START GAME"].tap()
		app.tables.staticTexts["Social"].tap()
		
		let pauseButton = app.buttons["Pause"]
		pauseButton.tap()
		app.buttons["Go back"].tap()
		app.tables.staticTexts["Technology"].tap()
		pauseButton.tap()
		app.buttons["Main menu"].tap()
    }
	
}
