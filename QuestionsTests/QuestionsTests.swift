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

		let vc = storyboard.instantiateViewController(withIdentifier: "questionsViewController") as! QuestionsViewController

		var answersFromJson: [String]
		var numberOfQuestions: Int
		var set: [NSDictionary]
		var question: String

		vc.view.reloadInputViews()

		for k in 0..<Quiz.quizzes.count {
			
			for i in 0..<Quiz.quizzes[k].content.count {
				
				vc.currentTopicIndex = k
				vc.currentSetIndex = i
				vc.viewDidLoad()
				
				set = (vc.set as! [NSDictionary])
				
				numberOfQuestions = (vc.set as! [NSDictionary]).count
				
				for j in 0..<numberOfQuestions {
					
					answersFromJson = set[j]["answers"] as! [String]
					question = set[j]["question"] as! String
					
					// TEST QUESTION
					print("· Question \(j):\nQuestionLabel: \(vc.questionLabel.text!)\nJsonQuestion: \(question)\n")
					XCTAssert(vc.questionLabel.text! == question, "Question \(j) string didn't load correctly")
					
					// TEST ANSWERS
					for k in 0..<vc.answerButtons.count {
						print("·· Answer \(k):\nLabel: \(vc.answerButtons[k].currentTitle!)\nJson: \(answersFromJson[k])\n")
						XCTAssert(vc.answerButtons[k].currentTitle! == answersFromJson[k], "Error loading answer string \(k) from set \(vc.currentSetIndex)")
					}
					
					vc.pickQuestion()
				}
			}
		}
	}

	func testSettingsEnabled() {
		
		let settingsVC = storyboard.instantiateViewController(withIdentifier: "settingsViewController") as! SettingsViewController
		settingsVC.view.reloadInputViews()
		
		XCTAssert(Settings.sharedInstance.musicEnabled == settingsVC.bgMusicSwitch.isOn, "Background music switch not working")
		XCTAssert(Settings.sharedInstance.parallaxEnabled == settingsVC.parallaxEffectSwitch.isOn, "Parallax effect switch not working")
		XCTAssert(Settings.sharedInstance.darkThemeEnabled == settingsVC.darkThemeSwitch.isOn, "Dark theme switch not working")
		XCTAssert(Settings.sharedInstance.hapticFeedbackEnabled == settingsVC.hapticFeedbackSwitch.isOn, "Haptic feedback switch not working")
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
