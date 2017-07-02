import UIKit

class QuestionsViewController: UIViewController {

	// MARK: Properties
	
	@IBOutlet var answerButtons: [UIButton]!
	@IBOutlet weak var remainingQuestionsLabel: UILabel!
	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet weak var pauseButton: UIButton!
	@IBOutlet weak var pauseView: UIView!
	@IBOutlet weak var goBack: UIButton!
	@IBOutlet weak var muteMusic: UIButton!
	@IBOutlet weak var mainMenu: UIButton!
	@IBOutlet weak var helpButton: UIButton!
	@IBOutlet weak var blurView: UIVisualEffectView!
	
	let oldScore = Settings.sharedInstance.score
	let statusBarHeight = UIApplication.shared.statusBarFrame.height
	var blurViewPos = Int()
	var correctAnswer = UInt8()
	var correctAnswers = Int()
	var incorrectAnswers = Int()
	var repeatTimes = UInt8()
	var currentTopicIndex = Int()
	var currentSetIndex = Int()
	var isSetFromJSON = false
	var set: [QuestionType] = []
	var quiz: EnumeratedIterator<IndexingIterator<Array<QuestionType>>>!
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		if !isSetFromJSON {
			setUpQuiz()
		} else {
			set.shuffle()
			quiz = set.enumerated().makeIterator()
		}
		
		blurView.frame = UIScreen.main.bounds
		
		let title = Audio.bgMusic?.isPlaying == true ? "Pause music" : "Play music"
		muteMusic.setTitle(title.localized, for: .normal)
	
		goBack.setTitle("Go back".localized, for: .normal)
		mainMenu.setTitle("Main menu".localized, for: .normal)
		pauseButton.setTitle("Pause".localized, for: .normal)
		pauseView.alpha = 0.0
		blurView.alpha = 0.0
		
		// Theme settings
		loadCurrentTheme()
		setButtonsAndLabelsPosition()
		
		// Loads the theme if user uses a home quick action
		NotificationCenter.default.addObserver(self, selector: #selector(loadCurrentTheme), name: .UIApplicationDidBecomeActive, object: nil)
		
		if Settings.sharedInstance.score < 5 {
			helpButton.alpha = 0.4
		}
		
		addSwipeGestures()
		
		pickQuestion()
	}
	
	override func viewWillLayoutSubviews() {
		setButtonsAndLabelsPosition()
	}
	
	@available(iOS, deprecated: 9.0)
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: UIResponder

	// If user shake the device, an alert to repeat the quiz pop ups
	override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
		
		guard motion == .motionShake else { return }
		
		let currentQuestion = Int(String(remainingQuestionsLabel.text?.first ?? "0")) ?? 0
		
		if #available(iOS 10.0, *), Settings.sharedInstance.hapticFeedbackEnabled {
			let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
			feedbackGenerator.impactOccurred()
		}
		
		if repeatTimes < 2 && currentQuestion > 1 {
			
			let alertViewController = UIAlertController(title: "Repeat?".localized,
														message: "Do you want to start again?".localized,
														preferredStyle: .alert)
			
			alertViewController.addAction(title: "OK".localized, style: .default) { action in self.repeatActionDetailed() }
			alertViewController.addAction(title: "Cancel".localized, style: .cancel)
			
			present(alertViewController, animated: true)
		}
		else if repeatTimes >= 2 {
			showOKAlertWith(title: "Attention", message: "Maximum help tries per question reached")
		}
	}
	
	// MARK: UIViewController
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .themeStyle(dark: .lightContent, light: .default)
	}

	// MARK: UIStoryboardSegue Handling
	
	@IBAction func unwindToQuestions(_ segue: UIStoryboardSegue) { }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "unwindToQRScanner" {
			Audio.setVolumeLevel(to: Audio.bgMusicVolume)
		}
	}
	
	// MARK: Actions
	
	@IBAction func answer1Action() { verify(answer: 0) }
	@IBAction func answer2Action() { verify(answer: 1) }
	@IBAction func answer3Action() { verify(answer: 2) }
	@IBAction func answer4Action() { verify(answer: 3) }

	@IBAction func pauseMenu() {
		pauseMenuAction()
	}
	
	@IBAction func goBackAction() {
		if !isSetFromJSON {
			performSegue(withIdentifier: "unwindToQuizSelector", sender: self)
		} else {
			performSegue(withIdentifier: "unwindToQRScanner", sender: self)
		}
	}
	
	@IBAction func helpAction() {
		
		// Use haptic feedback
		if #available(iOS 10.0, *), Settings.sharedInstance.hapticFeedbackEnabled {
			let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
			feedbackGenerator.impactOccurred()
		}
		
		if Settings.sharedInstance.score < 5 {
			showOKAlertWith(title: "Attention", message: "Not enough points (5 needed)")
		}
		else {
			
			var timesUsed: UInt8 = 0
			answerButtons.forEach { if $0.alpha != 1.0 { timesUsed += 1 } }
			
			if timesUsed < 2 {
				
				Settings.sharedInstance.score -= 5

				var randomQuestionIndex = UInt32()
				
				repeat {
					randomQuestionIndex = arc4random_uniform(4)
				} while((UInt8(randomQuestionIndex) == correctAnswer) || (answerButtons[Int(randomQuestionIndex)].alpha != 1.0))
				
				UIView.animate(withDuration: 0.4) {
					
					self.answerButtons[Int(randomQuestionIndex)].alpha = 0.4
					
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
	
	private func pauseMenuAction(animated: Bool = true) {
		
		let duration: TimeInterval = animated ? 0.2 : 0.0
		let title = (pauseView.alpha == 0.0) ? "Continue" : "Pause"
		pauseButton.setTitle(title.localized, for: .normal)
		
		UIView.animate(withDuration: duration) {
			self.pauseView.alpha = (self.pauseView.alpha == 0.0) ? 0.9 : 0.0
			self.blurView.alpha = (self.blurView.alpha == 0.0) ? 1.0 : 0.0
		}
		
		let newVolume = (pauseView.alpha == 0.0) ? Audio.bgMusicVolume : (Audio.bgMusicVolume / 5.0)
		Audio.setVolumeLevel(to: newVolume)
	}
	
	private func shuffledQuiz(_ name: Question) -> NSArray{
		if currentSetIndex < name.quiz.count {
			return name.quiz[currentSetIndex].shuffled() as NSArray
		}
		return NSArray()
	}
	
	private func addSwipeGestures() {
		
		let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
		swipeUp.direction = .up
		swipeUp.numberOfTouchesRequired = 2
		view.addGestureRecognizer(swipeUp)
		
		let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
		swipeDown.direction = .down
		swipeDown.numberOfTouchesRequired = 2
		view.addGestureRecognizer(swipeDown)
	}
	
	@objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
		
		if let swipeGesture = gesture as? UISwipeGestureRecognizer {
			
			let darkThemeEnabled = Settings.sharedInstance.darkThemeEnabled
			
			if !darkThemeEnabled && (swipeGesture.direction == .down) {
				Settings.sharedInstance.darkThemeEnabled = true
			}
			else if darkThemeEnabled && (swipeGesture.direction == .up) {
				Settings.sharedInstance.darkThemeEnabled = false
			}
			else { return }
			
			UIView.animate(withDuration: 0.3) {
				self.loadCurrentTheme()
				self.setNeedsStatusBarAppearanceUpdate()
			}
		}
	}
	
	@objc func loadCurrentTheme() {
		
		let currentThemeColor = UIColor.themeStyle(dark: .white, light: .black)
		
		helpButton.setTitleColor(dark: .orange, light: .defaultTintColor, for: .normal)
		remainingQuestionsLabel.textColor = currentThemeColor
		questionLabel.textColor = currentThemeColor
		view.backgroundColor = .themeStyle(dark: .darkGray, light: .white)
		pauseButton.backgroundColor = .themeStyle(dark: .lightGray, light: .veryLightGray)
		pauseButton.setTitleColor(dark: .white, light: .defaultTintColor, for: .normal)
		answerButtons.forEach { $0.backgroundColor = .themeStyle(dark: .orange, light: .defaultTintColor) }
		pauseView.backgroundColor = .themeStyle(dark: .lightGray, light: .veryVeryLightGray)
		pauseView.subviews.forEach { ($0 as? UIButton)?.setTitleColor(dark: .black, light: .darkGray, for: .normal)
									($0 as? UIButton)?.backgroundColor = .themeStyle(dark: .warmColor, light: .warmYellow) }
		
		setNeedsStatusBarAppearanceUpdate()
	}
	
	@objc func showPauseMenu() {
		if pauseView.alpha == 0.0 {
			pauseMenuAction(animated: false)
		}
	}
	
	@objc func setButtonsAndLabelsPosition() {
		
		// Answers buttons position
		
		let isPortrait = UIApplication.shared.statusBarOrientation.isPortrait
		
		let labelHeight: CGFloat = UIScreen.main.bounds.maxY * (isPortrait ? 0.0625 : 0.09)
		let labelWidth: CGFloat = UIScreen.main.bounds.maxX / 1.2
		
		let yOffset = isPortrait ? labelHeight : 0
		let yOffset4 = isPortrait ? labelHeight : (labelHeight * 1.3)
		
		let xPosition = (UIScreen.main.bounds.maxX / 2.0) - (labelWidth / 2.0)
		let yPosition = (UIScreen.main.bounds.maxY / 4.0) + labelHeight + yOffset
		let yPosition4 = (UIScreen.main.bounds.maxY * 0.75) - labelHeight + yOffset4
		let spaceBetweenAnswers: CGFloat = (((yPosition4 - yPosition)) - (3 * labelHeight)) / 3.0
		let fullLabelHeight = labelHeight + spaceBetweenAnswers
		
		answerButtons[0].frame = CGRect(x: xPosition, y: yPosition, width: labelWidth, height: labelHeight)
		answerButtons[1].frame = CGRect(x: xPosition, y: yPosition + fullLabelHeight, width: labelWidth, height: labelHeight)
		answerButtons[2].frame = CGRect(x: xPosition, y: yPosition4 - fullLabelHeight, width: labelWidth, height: labelHeight)
		answerButtons[3].frame = CGRect(x: xPosition, y: yPosition4, width: labelWidth, height: labelHeight)
		answerButtons.forEach { $0.titleLabel?.adjustsFontSizeToFitWidth = true }
		
		let currentStatusBarHeight = isPortrait ? statusBarHeight : 0.0
		let yPosition6 = ((yPosition / 2.0) - labelHeight) + currentStatusBarHeight + (pauseButton.bounds.height / 2.0)
		questionLabel.frame = CGRect(x: xPosition, y: yPosition6, width: labelWidth, height: labelHeight * 2)
		questionLabel.adjustsFontSizeToFitWidth = true
		
		blurView.frame = UIScreen.main.bounds
	}
	
	public func pickQuestion() {
		
		// Restore
		UIView.animate(withDuration: 0.75) {
			self.answerButtons.forEach { $0.alpha = 1 }
			
			if Settings.sharedInstance.score >= 5 {
				self.helpButton.alpha = 1.0
			}
		}
		
		if let quiz0 = quiz.next() {
			
			let fullQuestion = quiz0.element
			
			UIView.animate(withDuration: 0.1) {
				
				self.correctAnswer = fullQuestion.correct
				self.questionLabel.text = fullQuestion.question.localized
				
				let answers = fullQuestion.answers
				
				for i in 0..<self.answerButtons.count {
					self.answerButtons[i].setTitle(answers[i].localized, for: .normal)
				}
				
				if let index = self.set.index(of: fullQuestion) {
					self.remainingQuestionsLabel.text = "\(index + 1)/\(self.set.count)"
				}
			}
		}
		else {
			endOfQuestionsAlert()
		}
	}

	private func isSetCompleted() -> Bool {
		
		if let completedSets = Settings.sharedInstance.completedSets[currentTopicIndex] {
			return completedSets[currentSetIndex]
		}
		
		return false
	}
	
	private func okActionDetailed() {
		
		if !isSetCompleted() {
			Settings.sharedInstance.correctAnswers += correctAnswers
			Settings.sharedInstance.incorrectAnswers += incorrectAnswers
			Settings.sharedInstance.score += (correctAnswers * 20) - (incorrectAnswers * 10)
		}
		Settings.sharedInstance.completedSets[currentTopicIndex]?[currentSetIndex] = true

		if !isSetFromJSON {
			performSegue(withIdentifier: "unwindToQuizSelector", sender: self)
		} else {
			performSegue(withIdentifier: "unwindToMainMenu", sender: self)
		}
	}
	
	private func repeatActionDetailed() {
		repeatTimes += 1
		correctAnswers = 0
		incorrectAnswers = 0
		setUpQuiz()
		Settings.sharedInstance.score = oldScore
		pickQuestion()
	}
	
	private func verify(answer: UInt8) {
		
		pausePreviousSounds()
		
		if answer == correctAnswer {
			correctAnswers += 1
			Audio.correct?.play()
		}
		else {
			incorrectAnswers += 1
			Audio.incorrect?.play()
		}
		
		UIView.animate(withDuration: 0.75) {
			self.answerButtons[Int(answer)].backgroundColor = (answer == self.correctAnswer) ? .darkGreen : .alternativeRed
		}
		
		// Use haptic feedback
		if #available(iOS 10.0, *), Settings.sharedInstance.hapticFeedbackEnabled {
			let feedbackGenerator = UINotificationFeedbackGenerator()
			feedbackGenerator.notificationOccurred((answer == correctAnswer) ? .success : .error)
		}
		
		// Restore the answers buttons to their original color
		UIView.animate(withDuration: 0.75) {
			self.answerButtons[Int(answer)].backgroundColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		}
		
		pickQuestion()
	}
	
	private func pausePreviousSounds() {
		
		if let incorrectSound = Audio.incorrect, incorrectSound.isPlaying {
			incorrectSound.pause()
			incorrectSound.currentTime = 0
		}
		
		if let correctSound = Audio.correct, correctSound.isPlaying {
			correctSound.pause()
			correctSound.currentTime = 0
		}
	}
	
	// Alerts
	
	private func endOfQuestionsAlert() {
		
		let helpScore = oldScore - Settings.sharedInstance.score
		let score = (correctAnswers * 20) - (incorrectAnswers * 10) - helpScore
		
		let title = "Score: ".localized + "\(score) pts"
		let message = "Correct answers: ".localized + "\(correctAnswers)" + "/" + "\(set.count)"
		
		let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		alertViewController.addAction(title: "OK".localized, style: .default) { action in self.okActionDetailed() }
		
		if (correctAnswers < set.count) && (repeatTimes < 2) && !isSetCompleted() {
			
			let repeatText = "Repeat".localized + " (\(2 - self.repeatTimes))"
			alertViewController.addAction(title: repeatText, style: .cancel) { action in self.repeatActionDetailed() }
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(75)) {
			self.present(alertViewController, animated: true)
		}
	}
	
	private func showOKAlertWith(title: String, message: String) {
		let alertViewController = UIAlertController.OKAlert(title: title, message: message)
		present(alertViewController, animated: true)
	}
	
	private func setUpQuiz() {
		set = Quiz.quizzes[currentTopicIndex].content.quiz[currentSetIndex].shuffled()
		quiz = set.enumerated().makeIterator()
	}
}

