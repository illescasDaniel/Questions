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
	var set: [AnyObject] = []
	var quiz = NSEnumerator()
	var paused = true
	
	// MARK: View life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		set = (Quiz.set[currentSet] as! Array).shuffle()
		quiz = set.objectEnumerator()
		
		pauseView.isHidden = true
		endOfQuestions.isHidden = true
		statusLabel.alpha = 0.0

		let title = MainViewController.bgMusic?.isPlaying == true ? "Pause music" : "Play music"
		muteMusic.setTitle(title.localized, for: UIControlState())

		endOfQuestions.text = "End of questions".localized
		goBack.setTitle("Go back".localized, for: UIControlState())
		mainMenu.setTitle("Main menu".localized, for: UIControlState())
		pauseButton.setTitle("Pause".localized, for: UIControlState())

		pickQuestion()
	}

	// MARK: IBActions
	
	@IBAction func answer1Action() { verify(answer: 0) }
	@IBAction func answer2Action() { verify(answer: 1) }
	@IBAction func answer3Action() { verify(answer: 2) }
	@IBAction func answer4Action() { verify(answer: 3) }

	@IBAction func pauseMenu() {

		let title = paused ? "Continue" : "Pause"
		pauseButton.setTitle(title.localized, for: UIControlState())

		answersLabels.forEach {
			//if endOfQuestions.hidden { // This is not necessary anymore since the blurView blocks the buttons | Uncomment this if you remove the blurView
				$0.isEnabled = $0.isEnabled ? false : true
			//}
		}

		// BLUR BACKGROUND for pause menu
		if paused {
			let blurEffect = UIBlurEffect(style: .light)
			let blurView = UIVisualEffectView(effect: blurEffect)
			blurView.frame = UIScreen.main.bounds
			
			view.insertSubview(blurView, at: 8)
		}
		else {
			view.subviews[8].removeFromSuperview()
		}
		
		paused = paused ? false : true
		pauseView.isHidden = paused
	}
	
	// Lock rotation if the pauseView is shown / Rotate screen if the pauseView is hidden
	override var shouldAutorotate: Bool {
		return pauseView.isHidden
	}

	@IBAction func muteMusicAction() {
		
		if let bgMusic = MainViewController.bgMusic {
			
			if bgMusic.isPlaying {
				bgMusic.pause()
				muteMusic.setTitle("Play music".localized, for: UIControlState())
			}
			else {
				bgMusic.play()
				muteMusic.setTitle("Pause music".localized, for: UIControlState())
			}
			
			Settings.sharedInstance.musicEnabled = bgMusic.isPlaying
		}
	}
	
	// MARK: Convenience
	
	func pickQuestion() {
		
		if let quiz = quiz.nextObject() as? NSDictionary {
			
			correctAnswer = (quiz["answer"] as! Int)
			questionLabel.text = (quiz["question"] as! String).localized
			
			for i in 0..<answersLabels.count {
				answersLabels[i].setTitle((quiz["answers"] as! [String])[i].localized, for: UIControlState())
			}

			remainingQuestionsLabel.text =  "\((set as! Array).index(of: quiz)! + 1)/\(set.count)"
		}
		else {
			
			Settings.sharedInstance.completedSets[currentSet] = true
			endOfQuestions.isHidden = false
			answersLabels.forEach { $0.isEnabled = false }
		}
	}

	func verify(answer: Int) {
		
		pausePreviousSounds()
		
		statusLabel.alpha = 1.0
		
		if answer == correctAnswer {
			statusLabel.textColor = UIColor.green
			statusLabel.text = "Correct!".localized
			MainViewController.correct?.play()
		}
		else {
			statusLabel.textColor = UIColor.red
			statusLabel.text = "Incorrect".localized
			MainViewController.incorrect?.play()
		}
		
		if !Settings.sharedInstance.completedSets[currentSet] {
			(answer == correctAnswer) ? (Settings.sharedInstance.correctAnswers += 1) : (Settings.sharedInstance.incorrectAnswers += 1)
		}
		
		// Fade out animation for statusLabel
		UIView.animate(withDuration: 1.5) { self.statusLabel.alpha = 0.0 }
		
		pickQuestion()
	}
	
	func pausePreviousSounds() {
		
		if let incorrectSound = MainViewController.incorrect , incorrectSound.isPlaying {
			incorrectSound.pause()
			incorrectSound.currentTime = 0
		}
		
		if let correctSound = MainViewController.correct , correctSound.isPlaying {
			correctSound.pause()
			correctSound.currentTime = 0
		}
	}
}
