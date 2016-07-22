import UIKit

class QuestionViewController: UIViewController {

	@IBOutlet var remainingQuestionsLabel: UILabel!
	@IBOutlet var questionLabel: UILabel!
	@IBOutlet var answersLabels: [UIButton]!
	@IBOutlet var statusLabel: UILabel!
	@IBOutlet var endOfQuestions: UILabel!

	@IBOutlet var pauseButton: UIButton!
	@IBOutlet var pauseMenu: UIView!
	@IBOutlet var goBack: UIButton!
	@IBOutlet var muteMusic: UIButton!
	@IBOutlet var mainMenu: UIButton!

	static var completedSets = MainViewController.settings.completedSets
	var correctAnswer = Int()
	var currentSet = Int()
	var set: AnyObject = []
	var quizIndex = 0
	var paused = true

	override func viewDidLoad() {
		super.viewDidLoad()
		
		set = (Quiz.set[currentSet] as! [AnyObject]).shuffle()

		pauseMenu.hidden = true
		endOfQuestions.hidden = true
		statusLabel.alpha = 0.0

		if let bgMusic = MainViewController.bgMusic {
			
			let title = bgMusic.playing ? "Pause music" : "Play music"
			muteMusic.setTitle(title.localized, forState: .Normal)
		}

		endOfQuestions.text = "End of questions".localized
		goBack.setTitle("Go back".localized, forState: .Normal)
		mainMenu.setTitle("Main menu".localized, forState: .Normal)
		pauseButton.setTitle("Pause".localized, forState: .Normal)

		pickQuestion()
	}

	func pickQuestion() {
		
		if quizIndex < set.count {
			
			correctAnswer = (set[quizIndex]["answer"] as! Int)
			questionLabel.text = (set[quizIndex]["question"] as! String).localized
			
			let answers = set[quizIndex]["answers"] as! [String]
			
			for i in 0..<answersLabels.count {
				answersLabels[i].setTitle(answers[i].localized, forState: .Normal)
			}
	
			remainingQuestionsLabel.text = "\(quizIndex + 1)/\(set.count)"
			quizIndex += 1
		}
		else {
			QuestionViewController.completedSets[currentSet] = true

			MainViewController.settings.completedSets = QuestionViewController.completedSets
			MainViewController.settings.save()

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
		UIView.animateWithDuration(1.5) { self.statusLabel.alpha = 0.0 }

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

		let title = paused ? "Continue" : "Pause"
		pauseButton.setTitle(title.localized, forState: .Normal)

		answersLabels.forEach {
			if endOfQuestions.hidden {
				$0.enabled = $0.enabled ? false : true
			}
		}

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
			
			MainViewController.settings.musicEnabled = !bgMusic.playing
			MainViewController.settings.save()
		}

	}
}
