import XCTest
@testable import Questions

class QuestionsTests: XCTestCase {

	let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	func testQuestionsLabels() {

		let vc = storyboard.instantiateViewController(withIdentifier: "questionsViewController") as! QuestionViewController

		var answersFromPlist: [String]
		var numberOfQuestions: Int
		var set: [NSDictionary]
		var question: String
		var currentQuiz: [[NSDictionary]]!

		vc.view.reloadInputViews()

		for k in 0..<Quiz.topicsNames.count {
			
			switch k {
				case 0: currentQuiz = Quiz.technology
				case 1: currentQuiz = Quiz.social
				case 2: currentQuiz = Quiz.people
				default: break
			}
			
			for i in 0..<currentQuiz.count {
				
				vc.currentSetIndex = i
				vc.viewDidLoad()
				
				set = (vc.set as! [NSDictionary])
				
				numberOfQuestions = (vc.set as! [NSDictionary]).count
				
				print("-> Set: ", vc.currentSetIndex)
				
				for j in 0..<numberOfQuestions {
					
					answersFromPlist = set[j]["answers"] as! [String]
					question = set[j]["question"] as! String
					
					// TEST QUESTION
					print("· Question \(j):\nQuestionLabel: \(vc.questionLabel.text!)\nPlistQuestion: \(question)\n")
					XCTAssert(vc.questionLabel.text! == question, "Question \(j) string didn't load correctly")
					
					// TEST ANSWERS
					for k in 0..<vc.answersButtons.count {
						print("·· Answer \(k):\nLabel: \(vc.answersButtons[k].currentTitle!)\nPlist: \(answersFromPlist[k])\n")
						XCTAssert(vc.answersButtons[k].currentTitle! == answersFromPlist[k], "Error loading answer string \(k) from set \(vc.currentSetIndex)")
					}
					
					vc.pickQuestion()
				}
			}
		}
	}

	func testSettingsSwitchAction() {

		if let bgMusic = Audio.bgMusic {
			
			let settingsVC = storyboard.instantiateViewController(withIdentifier: "settingsViewController") as! SettingsViewController
			
			settingsVC.view.reloadInputViews()
			
			settingsVC.bgMusicSwitch.setOn(true, animated: true)
			settingsVC.switchBGMusic()
			XCTAssert(bgMusic.isPlaying, "Music not playing when switch is ON")

			settingsVC.bgMusicSwitch.setOn(false, animated: true)
			settingsVC.switchBGMusic()
			XCTAssert(!bgMusic.isPlaying, "Music playing when switch is OFF")
		}
		else {
			XCTFail("Music could not load correctly")
		}
	}
}
