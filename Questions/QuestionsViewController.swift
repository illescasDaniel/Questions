import UIKit

class QuestionsViewController: UIViewController {

	// MARK: Properties
	
	@IBOutlet var answersButtons: [UIButton]!
	@IBOutlet weak var remainingQuestionsLabel: UILabel!
	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet weak var pauseButton: UIButton!
	@IBOutlet weak var pauseView: UIView!
	@IBOutlet weak var goBack: UIButton!
	@IBOutlet weak var muteMusic: UIButton!
	@IBOutlet weak var mainMenu: UIButton!
	@IBOutlet weak var helpButton: UIButton!
	
	let darkThemeEnabled = Settings.sharedInstance.darkThemeEnabled
	var blurViewPos = Int()
	var correctAnswer = UInt8()
	var correctAnswers = Int()
	var incorrectAnswers = Int()
	var repeatTimes = UInt8()
	var currentTopicIndex = Int()
	var currentSetIndex = Int()
	var set: NSArray = []
	var quiz: NSEnumerator?
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		set = shuffledQuiz(Quiz.quizzes[currentTopicIndex].contents)
		quiz = set.objectEnumerator()
		
		// Saves the position where the blurView will be
		for i in 0..<view.subviews.count where (view.subviews[i] == pauseView) {
			blurViewPos = i - 1
		}

		let title = Audio.bgMusic?.isPlaying == true ? "Pause music" : "Play music"
		muteMusic.setTitle(title.localized, for: .normal)
	
		goBack.setTitle("Go back".localized, for: .normal)
		mainMenu.setTitle("Main menu".localized, for: .normal)
		pauseButton.setTitle("Pause".localized, for: .normal)
		
		// Theme settings
		loadCurrentTheme()
		setButtonsAndLabelsPosition()
		
		// If user minimize the app, the pause menu shows up
		NotificationCenter.default.addObserver(self, selector: #selector(self.showPauseMenu),
												name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

		
		// If user rotates screen, the buttons and labels position are recalculated, aswell as the bluerred background for the pause menu
		NotificationCenter.default.addObserver(self, selector: #selector(self.setButtonsAndLabelsPosition),
		                                       name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		pickQuestion()
		
		if Settings.sharedInstance.score < 5 {
			helpButton.alpha = 0.4
		}
	}
	
	// MARK: UIViewController
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return darkThemeEnabled ? .lightContent : .default
	}
	
	override var shouldAutorotate: Bool {
		
		if !pauseView.isHidden {
			view.subviews[blurViewPos].removeFromSuperview()
			
			let blurEffect = darkThemeEnabled ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
			let blurView = UIVisualEffectView(effect: blurEffect)
			blurView.frame = UIScreen.main.bounds
			view.insertSubview(blurView, at: blurViewPos)
		}
		return true
	}

	// MARK: IBActions
	
	@IBAction func answer1Action() { verify(answer: 0) }
	@IBAction func answer2Action() { verify(answer: 1) }
	@IBAction func answer3Action() { verify(answer: 2) }
	@IBAction func answer4Action() { verify(answer: 3) }

	@IBAction func pauseMenu() {
		
		let title = pauseView.isHidden ? "Continue" : "Pause"
		pauseButton.setTitle(title.localized, for: .normal)

		// BLURRED BACKGROUND for pause menu
		/* Note: if this you want to remove the view and block the buttons you have to change the property .isEnabled to false of each button */

		if pauseView.isHidden {
			let blurEffect = darkThemeEnabled ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
			let blurView = UIVisualEffectView(effect: blurEffect)
			blurView.frame = UIScreen.main.bounds
			view.insertSubview(blurView, at: blurViewPos)
		}
		else {
			view.subviews[blurViewPos].removeFromSuperview()
		}
		
		pauseView.isHidden = !pauseView.isHidden
		
		let newVolume = pauseView.isHidden ? Audio.bgMusicVolume : (Audio.bgMusicVolume / 5.0)
		Audio.setVolumeLevel(to: newVolume)
	}
	
	func showPauseMenu() {
		if (pauseView.isHidden) {
			pauseMenu()
		}
	}
	
	@IBAction func helpAction() {
		
		if Settings.sharedInstance.score < 5 {
			showOKAlertWith(title: "Attention", message: "Not enough points (5 needed)")
		}
		else {
			
			var timesUsed: UInt8 = 0
			answersButtons.forEach { if $0.alpha != 1.0 { timesUsed += 1 } }
			
			if timesUsed < 2 {
				
				Settings.sharedInstance.score -= 5

				var randomQuestionIndex = UInt32()
				
				repeat {
					randomQuestionIndex = arc4random_uniform(4)
				} while((UInt8(randomQuestionIndex) == correctAnswer) || (answersButtons[Int(randomQuestionIndex)].alpha != 1.0))
				
				UIView.animate(withDuration: 0.4) {
					
					self.answersButtons[Int(randomQuestionIndex)].alpha = 0.4
					
					if (Settings.sharedInstance.score < 5) || (timesUsed == 1) {
						self.helpButton.alpha = 0.4
					}
				}
			}
			else {
				showOKAlertWith(title: "Attention", message: "Maximum help tries per question reached")
			}
		}
	}
	
	@IBAction func muteMusicAction() {
		
		if let bgMusic = Audio.bgMusic {
			
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
	
	func showOKAlertWith(title: String, message: String) {
		let alertViewController = UIAlertController(title: title.localized,
		                                            message: message.localized,
		                                            preferredStyle: .alert)
		
		alertViewController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
		present(alertViewController, animated: true, completion: nil)
	}
	
	func shuffledQuiz(_ name: [[[String: Any]]]) -> NSArray{
		if currentSetIndex < name.count {
			return name[currentSetIndex].shuffled() as NSArray
		}
		return NSArray()
	}
	
	func loadCurrentTheme() {
		
		let currentThemeColor: UIColor = darkThemeEnabled ? .white : .black
		
		helpButton.setTitleColor(darkThemeEnabled ? .orange : .defaultTintColor, for: .normal)
		remainingQuestionsLabel.textColor = currentThemeColor
		questionLabel.textColor = currentThemeColor
		view.backgroundColor = darkThemeEnabled ? .darkGray : .white
		pauseButton.backgroundColor = darkThemeEnabled ? .lightGray : .veryLightGrey
		pauseButton.setTitleColor(darkThemeEnabled ? .white : .defaultTintColor, for: .normal)
		answersButtons.forEach { $0.backgroundColor = darkThemeEnabled ? .orange : .defaultTintColor }
		pauseView.backgroundColor = darkThemeEnabled ? .lightGray : .veryVeryLightGrey
		pauseView.subviews.forEach { ($0 as! UIButton).setTitleColor(darkThemeEnabled ? .black : .darkGray, for: .normal)
									 ($0 as! UIButton).backgroundColor = darkThemeEnabled ? .warmColor : .warmYellow }
	}
	
	func setButtonsAndLabelsPosition() {
		
		// Answers buttons position
		
		let isPortrait = UIDevice.current.orientation.isPortrait
		
		let labelHeight: CGFloat = UIScreen.main.bounds.maxY * (isPortrait ? 0.0625 : 0.09)
		let labelWidth: CGFloat = UIScreen.main.bounds.maxX / (isPortrait ? 1.125 : 1.2)
		
		let yOffset = isPortrait ? labelHeight : 0
		let yOffset4 = isPortrait ? labelHeight : (labelHeight * 1.3)
		
		let xPosition = (UIScreen.main.bounds.maxX / 2.0) - (labelWidth / 2.0)
		let yPosition = (UIScreen.main.bounds.maxY / 4.0) + labelHeight + yOffset
		let yPosition4 = (UIScreen.main.bounds.maxY * 0.75) - labelHeight + yOffset4
		let spaceBetweenAnswers: CGFloat = (((yPosition4 - yPosition)) - (3 * labelHeight)) / 3.0
		let fullLabelHeight = labelHeight + spaceBetweenAnswers
		
		answersButtons[0].frame = CGRect(x: xPosition, y: yPosition, width: labelWidth, height: labelHeight)
		answersButtons[1].frame = CGRect(x: xPosition, y: yPosition + fullLabelHeight, width: labelWidth, height: labelHeight)
		answersButtons[2].frame = CGRect(x: xPosition, y: yPosition4 - fullLabelHeight, width: labelWidth, height: labelHeight)
		answersButtons[3].frame = CGRect(x: xPosition, y: yPosition4, width: labelWidth, height: labelHeight)
		
		let statusBarHeight = UIApplication.shared.statusBarFrame.height
		let yPosition6 = ((yPosition / 2.0) - labelHeight) + statusBarHeight + (pauseButton.bounds.height / 2.0)
		questionLabel.frame = CGRect(x: xPosition, y: yPosition6, width: labelWidth, height: labelHeight * 2)
	}
	
	func pickQuestion() {
		
		// Restore
		UIView.animate(withDuration: 0.6) {
			self.answersButtons.forEach { $0.alpha = 1 }
			
			if Settings.sharedInstance.score >= 5 {
				self.helpButton.alpha = 1.0
			}
		}
		
		if let quiz = quiz?.nextObject() as? NSDictionary {
			
			UIView.animate(withDuration: 0.1) {
				
				self.correctAnswer = (quiz["answer"] as! UInt8)
				self.questionLabel.text = (quiz["question"] as! String).localized
				
				let answers = quiz["answers"] as! [String]
				
				for i in 0..<self.answersButtons.count {
					self.answersButtons[i].setTitle(answers[i].localized, for: .normal)
				}
				self.remainingQuestionsLabel.text = "\(self.set.index(of: quiz) + 1)/\(self.set.count)"
			}
		}
		else {
			self.endOfQuestionsAlert()
		}
	}

	func isSetCompleted() -> Bool {
		
		if let completedSets = Settings.sharedInstance.completedSets[currentTopicIndex] {
			return completedSets[currentSetIndex]
		}
		
		return false
	}
	
	func okActionDetailed() {
		
		if !isSetCompleted() {
			Settings.sharedInstance.correctAnswers += correctAnswers
			Settings.sharedInstance.incorrectAnswers += incorrectAnswers
			Settings.sharedInstance.score += (correctAnswers * 20) - (incorrectAnswers * 10)
		}
		Settings.sharedInstance.completedSets[currentTopicIndex]?[currentSetIndex] = true

		performSegue(withIdentifier: "unwindToQuizSelector", sender: self)
	}
	
	func repeatActionDetailed() {
		repeatTimes += 1
		correctAnswers = 0
		incorrectAnswers = 0
		set = shuffledQuiz(Quiz.quizzes[currentTopicIndex].contents)
		quiz = set.objectEnumerator()
		pickQuestion()
	}
	
	func verify(answer: UInt8) {
		
		pausePreviousSounds()
		
		if answer == correctAnswer {
			correctAnswers += 1
			answersButtons[Int(answer)].backgroundColor = .darkGreen
			Audio.correct?.play()
		}
		else {
			incorrectAnswers += 1
			answersButtons[Int(answer)].backgroundColor = .alternativeRed
			Audio.incorrect?.play()
		}
		
		// Use haptic feedback
		if #available(iOS 10.0, *) {
			let feedbackGenerator = UINotificationFeedbackGenerator()
			feedbackGenerator.notificationOccurred((answer == correctAnswer) ? .success : .error)
		}
		
		// Restore the answers buttons to their original color
		UIView.animate(withDuration: 0.6) {
			self.answersButtons[Int(answer)].backgroundColor = self.darkThemeEnabled ? .orange : .defaultTintColor
		}
		
		self.pickQuestion()
	}
	
	func pausePreviousSounds() {
		
		if let incorrectSound = Audio.incorrect, incorrectSound.isPlaying {
			incorrectSound.pause()
			incorrectSound.currentTime = 0
		}
		
		if let correctSound = Audio.correct, correctSound.isPlaying {
			correctSound.pause()
			correctSound.currentTime = 0
		}
	}
	
	// MARK: Alerts
	
	func endOfQuestionsAlert() {
		
		let score = (correctAnswers * 20) - (incorrectAnswers * 10)
		
		let title = "Score: ".localized + "\(score) pts"
		let message = "Correct answers: ".localized + "\(correctAnswers)" + "/" + "\(set.count)"
		
		let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		let okAction = UIAlertAction(title: "OK".localized, style: .default) { action in self.okActionDetailed() }
		alertViewController.addAction(okAction)
		
		if (correctAnswers < set.count) && (repeatTimes < 2) && !isSetCompleted() {
			
			let repeatText = "Repeat".localized + " (\(2 - self.repeatTimes))"
			let repeatAction = UIAlertAction(title: repeatText, style: .cancel) { action in self.repeatActionDetailed() }
			
			alertViewController.addAction(repeatAction)
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(140)) {
			self.present(alertViewController, animated: true, completion: nil)
		}
	}
}
