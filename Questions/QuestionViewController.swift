import UIKit

class QuestionViewController: UIViewController {

	// MARK: Properties
	
	@IBOutlet weak var remainingQuestionsLabel: UILabel!
	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet var answersLabels: [UIButton]!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var endOfQuestions: UILabel!

	@IBOutlet weak var pauseButton: UIButton!
	@IBOutlet weak var pauseView: UIView!
	@IBOutlet weak var goBack: UIButton!
	@IBOutlet weak var muteMusic: UIButton!
	@IBOutlet weak var mainMenu: UIButton!

	var correctAnswer = Int()
	var currentSet = Int()
	var set: AnyObject = []
	var quiz = NSEnumerator()
	var paused = true

	// MARK: View life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		set = (Quiz.set[currentSet] as! [AnyObject]).shuffle()
		quiz = set.objectEnumerator()
		
		pauseView.hidden = true
		endOfQuestions.hidden = true
		statusLabel.alpha = 0.0

		let title = MainViewController.bgMusic?.playing == true ? "Pause music" : "Play music"
		muteMusic.setTitle(title.localized, forState: .Normal)

		endOfQuestions.text = "End of questions".localized
		goBack.setTitle("Go back".localized, forState: .Normal)
		mainMenu.setTitle("Main menu".localized, forState: .Normal)
		pauseButton.setTitle("Pause".localized, forState: .Normal)

		pickQuestion()
	}

	// MARK: IBActions
	
	@IBAction func answer1Action() { verifyAnswer(0) }
	@IBAction func answer2Action() { verifyAnswer(1) }
	@IBAction func answer3Action() { verifyAnswer(2) }
	@IBAction func answer4Action() { verifyAnswer(3) }

	@IBAction func pauseMenu() {

		let title = paused ? "Continue" : "Pause"
		pauseButton.setTitle(title.localized, forState: .Normal)

		answersLabels.forEach {
			//if endOfQuestions.hidden { // This is not necessary anymore since the blurView blocks the buttons | Uncomment this if you remove the blurView
				$0.enabled = $0.enabled ? false : true
			//}
		}

		// BLUR BACKGROUND for pause menu
		if paused {
			let blurEffect = UIBlurEffect(style: .Light)
			let blurView = UIVisualEffectView(effect: blurEffect)
			blurView.frame = UIScreen.mainScreen().bounds
			
			view.insertSubview(blurView, atIndex: 8)
		}
		else {
			view.subviews[8].removeFromSuperview()
		}
		
		paused = paused ? false : true
		pauseView.hidden = paused
	}
	
	// Lock rotation if the pauseView is shown / Rotate screen if the pauseView is hidden
	override func shouldAutorotate() -> Bool {
		return pauseView.hidden
	}

	@IBAction func muteMusicAction() {
		
		if let bgMusic = MainViewController.bgMusic {
			
			if bgMusic.playing {
				bgMusic.pause()
				muteMusic.setTitle("Play music".localized, forState: .Normal)
			}
			else {
				bgMusic.play()
				muteMusic.setTitle("Pause music".localized, forState: .Normal)
			}
			
			Settings.sharedInstance.musicEnabled = bgMusic.playing
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
			
			Settings.sharedInstance.completedSets[currentSet] = true
			endOfQuestions.hidden = false
			answersLabels.forEach { $0.enabled = false }
		}
	}
	
	func verifyAnswer(answer: Int) {
		
		pausePreviousSounds()
		
		statusLabel.alpha = 1.0
		
		if answer == correctAnswer {
			statusLabel.textColor = .greenColor()
			statusLabel.text = "Correct!".localized
			MainViewController.correct?.play()
		}
		else {
			statusLabel.textColor = .redColor()
			statusLabel.text = "Incorrect".localized
			MainViewController.incorrect?.play()
		}
		
		if !Settings.sharedInstance.completedSets[currentSet] {
			(answer == correctAnswer) ? (Settings.sharedInstance.correctAnswers += 1) : (Settings.sharedInstance.incorrectAnswers += 1)
		}
		
		// Fade out animation for statusLabel
		UIView.animateWithDuration(1.5) { self.statusLabel.alpha = 0.0 }
		
		pickQuestion()
	}
	
	func pausePreviousSounds() {
		
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
