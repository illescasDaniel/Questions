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
		
		var switchState1 = backgroundMusicSwitch.value as! String

		backgroundMusicSwitch.tap()
		
		let switchState2 = backgroundMusicSwitch.value as! String
		
		XCTAssert((switchState1 == "1" && switchState2 == "0") || (switchState1 == "0" && switchState2 == "1"),
		          "Switch button not working")
		
		backgroundMusicSwitch.tap()
		
		switchState1 = backgroundMusicSwitch.value as! String
		
		XCTAssert((switchState1 == "1" && switchState2 == "0") || (switchState1 == "0" && switchState2 == "1"),
		          "Switch button not working")
		
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
