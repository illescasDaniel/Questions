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
		app.buttons["SETTINGS"].tap()
		app.navigationBars["Settings"].buttons["Main menu"].tap()
		app.buttons["READ QR CODE"].tap()
		app.navigationBars["Questions.QRScannerView"].buttons["Main menu"].tap()
		app.buttons["START GAME"].tap()
		
		let tablesQuery = app.tables
		tablesQuery.staticTexts["Technology"].tap()
		tablesQuery.staticTexts["Set 0"].tap()
		app.buttons["Pause"].tap()
		app.buttons["Main menu"].tap()
	}
}
