import UIKit
import GameplayKit // .shuffled()

class QuestionViewController: UIViewController {

	// MARK: Properties
	
	@IBOutlet var answersButtons: [UIButton]!
	@IBOutlet weak var remainingQuestionsLabel: UILabel!
	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var endOfQuestions: UILabel!
	@IBOutlet weak var pauseButton: UIButton!
	@IBOutlet weak var pauseView: UIView!
	@IBOutlet weak var goBack: UIButton!
	@IBOutlet weak var muteMusic: UIButton!
	@IBOutlet weak var mainMenu: UIButton!

	let darkThemeEnabled = Settings.sharedInstance.darkThemeEnabled
	var blurViewPos = Int()
	var correctAnswers = Int32()
	var incorrectAnswers = Int32()
	var correctAnswer = Int()
	var currentSet = Int()
	var set: NSArray = []
	var quiz: NSEnumerator?
	var paused = true
	
	// MARK: View life cycle

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		// Answers buttons position
		var labelHeight: CGFloat = 40
		
		if let answerFont = answersButtons[0].titleLabel?.font {
			labelHeight = answerFont.pointSize * 3
		}
		
		let offset = labelHeight + 15
		let labelWidth: CGFloat = UIScreen.main.bounds.maxX / 1.125
		let xPosition = (UIScreen.main.bounds.maxX / 2.0) - (labelWidth / 2.0)
		let yPosition = (UIScreen.main.bounds.maxY / 4.0) - (labelHeight / 4.0) + offset
		let yPosition4 = (UIScreen.main.bounds.maxY * 0.75) - (labelHeight / 4.0) - offset
		let spaceBetweenAnswers: CGFloat = (((yPosition4 - yPosition)) - (3 * labelHeight)) / 3.0
		let fullLabelHeight = labelHeight + spaceBetweenAnswers
		
		answersButtons[0].frame = CGRect(x: xPosition, y: yPosition, width: labelWidth, height: labelHeight)
		answersButtons[1].frame = CGRect(x: xPosition, y: yPosition + fullLabelHeight, width: labelWidth, height: labelHeight)
		answersButtons[2].frame = CGRect(x: xPosition, y: yPosition4 - fullLabelHeight, width: labelWidth, height: labelHeight)
		answersButtons[3].frame = CGRect(x: xPosition, y: yPosition4, width: labelWidth, height: labelHeight)
		
		// Labels position
		
		let yPosition5 = (UIScreen.main.bounds.maxY - yPosition4) / 2.0
		let yPositionOfButtomLabel = UIScreen.main.bounds.maxY - yPosition5
		
		endOfQuestions.frame = CGRect(x: xPosition, y: yPositionOfButtomLabel, width: labelWidth, height: labelHeight)
		statusLabel.frame = CGRect(x: xPosition, y: yPositionOfButtomLabel, width: labelWidth, height: labelHeight)
		
		//let yPosition6 = yPosition / 2.0
		let statusBarHeight = UIApplication.shared.statusBarFrame.height
		let yPosition6 = ((yPosition / 2.0) - labelHeight) + statusBarHeight
		questionLabel.frame = CGRect(x: xPosition, y: yPosition6, width: labelWidth, height: labelHeight * 2)
		
		if #available(iOS 10.0, *) {
			set = (Quiz.set[currentSet] as! NSArray).shuffled() as NSArray
		}
		else {
			set = (Quiz.set[currentSet] as! [AnyObject]).shuffled() as NSArray
		}
		
		quiz = set.objectEnumerator()
		
		pauseView.isHidden = true
		endOfQuestions.isHidden = true
		statusLabel.alpha = 0.0
		
		// Saves the position where the blurView will be
		for i in 0..<view.subviews.count where (view.subviews[i] == pauseView) {
			blurViewPos = i - 1
		}

		let title = MainViewController.bgMusic?.isPlaying == true ? "Pause music" : "Play music"
		muteMusic.setTitle(title.localized, for: .normal)
		
		endOfQuestions.text = "End of questions".localized
		goBack.setTitle("Go back".localized, for: .normal)
		mainMenu.setTitle("Main menu".localized, for: .normal)
		pauseButton.setTitle("Pause".localized, for: .normal)
		
		// Theme settings

		let currentThemeColor: UIColor = darkThemeEnabled ? .white : .black

		remainingQuestionsLabel.textColor = currentThemeColor
		questionLabel.textColor = currentThemeColor
		endOfQuestions.textColor = currentThemeColor
		view.backgroundColor = darkThemeEnabled ? .darkGray : .white
		pauseButton.setTitleColor(darkThemeEnabled ? .orange : .defaultTintColor, for: .normal)
		answersButtons.forEach { $0.backgroundColor = darkThemeEnabled ? .orange : .defaultTintColor }
		pauseView.backgroundColor = darkThemeEnabled ? .darkYellow : .myYellow
		pauseView.subviews.forEach { ($0 as! UIButton).setTitleColor(darkThemeEnabled ? .darkGray : .black, for: .normal) }
		
		pickQuestion()
	}
	
	// MARK: UIViewController
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return darkThemeEnabled ? .lightContent : .default
	}

	// MARK: IBActions
	
	@IBAction func answer1Action() { verify(answer: 0) }
	@IBAction func answer2Action() { verify(answer: 1) }
	@IBAction func answer3Action() { verify(answer: 2) }
	@IBAction func answer4Action() { verify(answer: 3) }

	@IBAction func pauseMenu() {

		let title = paused ? "Continue" : "Pause"
		pauseButton.setTitle(title.localized, for: .normal)

		// BLUR BACKGROUND for pause menu
		/* Note: if this you want to remove the view and block the buttons you have to change the property .isEnabled to false of each button */

		if paused {
			let blurEffect = darkThemeEnabled ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
			let blurView = UIVisualEffectView(effect: blurEffect)
			blurView.frame = UIScreen.main.bounds
			view.insertSubview(blurView, at: blurViewPos)
		}
		else {
			view.subviews[blurViewPos].removeFromSuperview()
		}
		
		paused = paused ? false : true
		pauseView.isHidden = paused
	}
	
	@IBAction func muteMusicAction() {
		
		if let bgMusic = MainViewController.bgMusic {
			
			if bgMusic.isPlaying {
				bgMusic.pause()
				muteMusic.setTitle("Play music".localized, for: .normal)
			}
			else {
				bgMusic.play()
				muteMusic.setTitle("Pause music".localized, for: .normal)
			}
			
			Settings.sharedInstance.musicEnabled = bgMusic.isPlaying
		}
	}
	
	// MARK: Convenience

	func pickQuestion() {
		
		if let quiz = quiz?.nextObject() as? NSDictionary {
			
			correctAnswer = (quiz["answer"] as! Int)
			questionLabel.text = (quiz["question"] as! String).localized
			
			for i in 0..<answersButtons.count {
				answersButtons[i].setTitle((quiz["answers"] as! [String])[i].localized, for: .normal)
			}

			remainingQuestionsLabel.text = "\(set.index(of: quiz) + 1)/\(set.count)"
		}
		else {
			
			if !Settings.sharedInstance.completedSets[currentSet] {
				Settings.sharedInstance.correctAnswers += correctAnswers
				Settings.sharedInstance.incorrectAnswers += incorrectAnswers
			}
			Settings.sharedInstance.completedSets[currentSet] = true
			endOfQuestions.isHidden = false
			answersButtons.forEach { $0.isEnabled = false }
		}
	}

	func verify(answer: Int) {
		
		pausePreviousSounds()
		
		statusLabel.alpha = 1.0
		
		if answer == correctAnswer {
			statusLabel.textColor = darkThemeEnabled ? .lightGreen : .green
			statusLabel.text = "Correct!".localized
			MainViewController.correct?.play()
		}
		else {
			statusLabel.textColor = darkThemeEnabled ? .lightRed : .red
			statusLabel.text = "Incorrect".localized
			MainViewController.incorrect?.play()
		}
	
		if !Settings.sharedInstance.completedSets[currentSet] {
			(answer == correctAnswer) ? (correctAnswers += 1) : (incorrectAnswers += 1)
		}
		
		// Fade out animation for statusLabel
		UIView.animate(withDuration: 1) { self.statusLabel.alpha = 0.0 }
		
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
