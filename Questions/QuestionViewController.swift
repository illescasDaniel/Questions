import UIKit
import Foundation
import AVFoundation
import CoreGraphics

class QuestionViewController: UIViewController {
	
	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet var answersLabels: [UIButton]!
	@IBOutlet var pauseButton: UIButton!

	@IBOutlet var pauseMenu: UIView!
	@IBOutlet var goBack: UIButton!
	@IBOutlet var muteMusic: UIButton!
	@IBOutlet var mainMenu: UIButton!

	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var endOfQuestions: UILabel!

	static var completedSets = Settings.valueForKey("Completed sets") as! [Bool]
	var currentSet = Int()
	
	var paused = true
	var correctAnswer = Int()
	var qNumber = Int()
	var questions: [Quiz] = [] // This value will be overwritten later

	override func viewDidLoad() {
		super.viewDidLoad()

		pauseMenu.hidden = true
		endOfQuestions.hidden = true
		statusLabel.alpha = 0.0

		if let bgMusic = MainViewController.bgMusic {
			
			let state = bgMusic.playing ? "Pause music" : "Play music"
			muteMusic.setTitle(state.localized, forState: .Normal)
		}

		endOfQuestions.text = "End of questions".localized
		goBack.setTitle("Go back".localized, forState: .Normal)
		mainMenu.setTitle("Main menu".localized, forState: .Normal)
		pauseButton.setTitle("Pause".localized, forState: .Normal)

		pickQuestion()
	}

	func pickQuestion() {

		if !questions.isEmpty {

			qNumber = Int(arc4random_uniform(UInt32(questions.count)))

			questionLabel.text = questions[qNumber].question
			correctAnswer = questions[qNumber].answer!

			for i in 0..<answersLabels.count {
				answersLabels[i].setTitle(questions[qNumber].answers[i], forState: .Normal)
			}

			questions.removeAtIndex(qNumber)
		}
		else {
			QuestionViewController.completedSets[currentSet] = true
			Settings.saveValue(QuestionViewController.completedSets, forKey: "Completed sets")
			
			endOfQuestions.hidden = false
			answersLabels.forEach { $0.enabled = false }
		}
	}

	func verifyAnswer(answer: Int) {

		stopPreviousSounds()

		statusLabel.alpha = 1.0

		if answer == correctAnswer {
			statusLabel.textColor = .greenColor()
			statusLabel.text = "Correct!".localized

			if let correctSound = MainViewController.correct {
				correctSound.play()
			}
		}
		else {
			statusLabel.textColor = .redColor()
			statusLabel.text = "Incorrect".localized

			if let incorrectSound = MainViewController.incorrect {
				incorrectSound.play()
			}
		}

		// Fade out animation for statusLabel
		UIView.animateWithDuration(1.5, animations: { self.statusLabel.alpha = 0.0 })

		pickQuestion()
	}

	func stopPreviousSounds() {

		if let incorrectSound = MainViewController.incorrect where incorrectSound.playing {
			incorrectSound.pause()
			incorrectSound.currentTime = 0
		}

		if let correctSound = MainViewController.correct where correctSound.playing {
			correctSound.pause()
			correctSound.currentTime = 0
		}
	}

	@IBAction func answer1Action(sender: UIButton) {
		verifyAnswer(0)
	}

	@IBAction func answer2Action(sender: UIButton) {
		verifyAnswer(1)
	}

	@IBAction func answer3Action(sender: UIButton) {
		verifyAnswer(2)
	}

	@IBAction func answer4Action(sender: UIButton) {
		verifyAnswer(3)
	}

	@IBAction func pauseMenu(sender: AnyObject) {
		
		let state = paused ? "Continue" : "Pause"
		pauseButton.setTitle(state.localized, forState: .Normal)

		answersLabels.forEach { if endOfQuestions.hidden { $0.enabled = $0.enabled ? false : true } }
		
		paused = paused ? false : true
		pauseMenu.hidden = pauseMenu.hidden ? false : true
	}

	@IBAction func muteMusicAction(sender: UIButton) {

		if let bgMusic = MainViewController.bgMusic {
			if bgMusic.playing {
				bgMusic.pause()
				muteMusic.setTitle("Play music".localized, forState: .Normal)
			}
			else {
				bgMusic.play()
				muteMusic.setTitle("Pause music".localized, forState: .Normal)
			}
		}

	}
}
