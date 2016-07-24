import UIKit

class QuestionViewController: UIViewController {

	// MARK: Properties
	
	@IBOutlet weak var remainingQuestionsLabel: UILabel!
	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet var answersLabels: [UIButton]!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var endOfQuestions: UILabel!

	@IBOutlet weak var pauseButton: UIButton!
	@IBOutlet weak var pauseMenu: UIView!
	@IBOutlet weak var goBack: UIButton!
	@IBOutlet weak var muteMusic: UIButton!
	@IBOutlet weak var mainMenu: UIButton!

	static var completedSets = MainViewController.settings.completedSets
	var correctAnswer = Int()
	var currentSet = Int()
	var set: AnyObject = []
	var quiz = NSEnumerator()
	var paused = true

	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		set = (Quiz.set[currentSet] as! [AnyObject]).shuffle()

		if set.objectEnumerator() != nil {
			quiz = set.objectEnumerator()!
		}

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

	// MARK: IBActions
	
	@IBAction func answer1Action(sender: UIButton) { verifyAnswer(0) }
	@IBAction func answer2Action(sender: UIButton) { verifyAnswer(1) }
	@IBAction func answer3Action(sender: UIButton) { verifyAnswer(2) }
	@IBAction func answer4Action(sender: UIButton) { verifyAnswer(3) }

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
	
	// MARK: Convenience
	
	func pickQuestion() {
		
		if let quiz = quiz.nextObject() {
			
			correctAnswer = (quiz["answer"] as! Int)
			questionLabel.text = (quiz["question"] as! String).localized
			
			for i in 0..<answersLabels.count {
				answersLabels[i].setTitle((quiz["answers"] as! [String])[i].localized, forState: .Normal)
			}
			
			remainingQuestionsLabel.text = "\(set.indexOfObject(quiz) + 1)/\(set.count)"
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
}
