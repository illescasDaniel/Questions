import XCTest
@testable import Questions

class QuestionsTests: XCTestCase {

	let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())

	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testQuestionsLabels() {

		let vc = storyboard.instantiateViewControllerWithIdentifier("questionsViewController") as! QuestionViewController

		var answersFromPlist: [String]
		var numberOfQuestions: Int
		var set: [NSDictionary]
		var question: String

		vc.view.reloadInputViews()

		for i in 0..<Quiz.set.count {

			vc.currentSet = i
			vc.viewDidLoad() // ¿?
			set = (vc.set as! [NSDictionary])

			numberOfQuestions = (vc.set as! [NSDictionary]).count

			print("-> Set: ", vc.currentSet)

			for j in 0..<numberOfQuestions {

				answersFromPlist = set[j]["answers"] as! [String]
				question = set[j]["question"] as! String

				// TEST QUESTION
				print("· Question \(j):\nQuestionLabel: \(vc.questionLabel.text!)\nPlistQuestion: \(question)\n")
				XCTAssert(vc.questionLabel.text! == question)

				// TEST ANSWERS
				for k in 0..<vc.answersLabels.count {
					print("·· Answer \(k):\nLabel: \(vc.answersLabels[k].currentTitle!)\nPlist: \(answersFromPlist[k])\n")
					XCTAssert(vc.answersLabels[k].currentTitle! == answersFromPlist[k], "Failed loading answer string \(k) from set \(vc.currentSet)")
				}

				vc.pickQuestion()
			}
		}

	}

	func testSettingsSwitchAction() {

		if let bgMusic = MainViewController.bgMusic {
			
			let settingsVC = storyboard.instantiateViewControllerWithIdentifier("settingsViewController") as! SettingsViewController
			
			settingsVC.view.reloadInputViews()
			
			settingsVC.bgMusicSwitch.setOn(true, animated: true)
			settingsVC.switchBGMusic(UISwitch())
			XCTAssert(bgMusic.playing, "Music not playing when switch is ON")

			settingsVC.bgMusicSwitch.setOn(false, animated: true)
			settingsVC.switchBGMusic(UISwitch())
			XCTAssert(!bgMusic.playing, "Music playing when switch is OFF")
		}
		else {
			XCTFail("Music could not load correctly")
		}
	}

}
