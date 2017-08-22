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

		guard let vc = storyboard.instantiateViewController(withIdentifier: "questionsViewController") as? QuestionsViewController else { return }
		
		var answersFromJson: [String]
		var question: String

		vc.view.reloadInputViews()

		for k in 0..<Quiz.quizzes.count {
			
			for i in 0..<Quiz.quizzes[k].content.quiz.count {
				
				vc.currentTopicIndex = k
				vc.currentSetIndex = i
				vc.viewDidLoad()
				
				for j in 0..<vc.set.count {
					
					answersFromJson = vc.set[j].answers
					question = vc.set[j].question
					
					// TEST QUESTION
					
					if let text = vc.questionLabel.text {
						print("· Question \(j):\nQuestionLabel: \(text)\nJsonQuestion: \(question)\n")
						XCTAssert(text == question, "Question \(j) string didn't load correctly")
					}
					else { XCTAssert(true, "Question \(j) string didn't load correctly (nil)") }
					
					// TEST ANSWERS
					for k in 0..<vc.answerButtons.count {
						print("·· Answer \(k):\nLabel: \(vc.answerButtons[k].currentTitle!)\nJson: \(answersFromJson[k])\n")
						
						if let title = vc.answerButtons[k].currentTitle {
							XCTAssert(title == answersFromJson[k], "Error loading answer string \(k) from set \(vc.currentSetIndex)")
						}
						else { XCTAssert(true, "Error loading answer string \(k) from set \(vc.currentSetIndex) (nil)") }
					}
					
					vc.pickQuestion()
				}
			}
		}
	}

	func testSettingsEnabled() {
		
		guard let settingsVC = storyboard.instantiateViewController(withIdentifier: "settingsViewController") as? SettingsViewController else { return }
		settingsVC.view.reloadInputViews()
		
		XCTAssert(Settings.shared.musicEnabled == settingsVC.bgMusicSwitch.isOn, "Background music switch not working")
		XCTAssert(Settings.shared.parallaxEnabled == settingsVC.parallaxEffectSwitch.isOn, "Parallax effect switch not working")
		XCTAssert(Settings.shared.darkThemeEnabled == settingsVC.darkThemeSwitch.isOn, "Dark theme switch not working")
		XCTAssert(Settings.shared.hapticFeedbackEnabled == settingsVC.hapticFeedbackSwitch.isOn, "Haptic feedback switch not working")
	}
	
	func testSettingsSwitchAction() {
		
		if let bgMusic = Audio.bgMusic,
			let settingsVC = storyboard.instantiateViewController(withIdentifier: "settingsViewController") as? SettingsViewController {
			
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
