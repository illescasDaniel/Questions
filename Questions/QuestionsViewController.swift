import UIKit

class QuestionsViewController: UIViewController {

	// MARK: Properties
	
	@IBOutlet weak var answerStub: RoundedButton!
	
	var answerButtons: [RoundedButton] = []
	
	@IBOutlet weak var pauseButton: UIButton!
	@IBOutlet weak var remainingQuestionsLabel: UILabel!
	@IBOutlet weak var quizTimerLabel: UILabel!
	
	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet weak var questionImageButton: UIButton!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	@IBOutlet weak var answersStackView: UIStackView!
	
	@IBOutlet weak var pauseView: UIView!
	@IBOutlet weak var goBack: UIButton!
	@IBOutlet weak var muteMusic: UIButton!
	@IBOutlet weak var mainMenu: UIButton!
	
	@IBOutlet weak var helpButton: UIButton!
	
	@IBOutlet weak var blurView: UIVisualEffectView!
	
	let oldScore = UserDefaultsManager.score
	var correctAnswer: Set<UInt8> = []
	var correctAnswers = Int()
	var incorrectAnswers = Int()
	var repeatTimes = UInt8()
	var currentTopicIndex = Int()
	var currentSetIndex = Int()
	var isSetFromJSON = false
	var set: [QuestionType] = []
	var quiz: EnumeratedIterator<IndexingIterator<Array<QuestionType>>>!
	var quizTime = TimeInterval()
	var previousQuizTime: TimeInterval = -1
	
	// MARK: View life cycle
	
	private func currentSet(option: Quiz.OptionsKey) -> String? {
		return SetOfTopics.shared.currentTopics[currentTopicIndex].quiz.customOptions[option]
	}

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		self.questionImageButton.setImage(nil, for: .normal)
		self.questionImageButton.imageView?.contentMode = .scaleAspectFill
		self.questionImageButton.imageView?.clipsToBounds = true
		self.questionImageButton.clipsToBounds = true
		self.questionImageButton.layer.cornerRadius = 10
		
		if !self.isSetFromJSON {
			self.setUpQuiz()
		} else {
			self.goBack.isHidden = true
			
			if let questionsInRandomOrderStr = SetOfTopics.shared.currentTopics[currentTopicIndex].quiz.customOptions[.questionsInRandomOrder],
				let questionsInRandomOrder = Bool(questionsInRandomOrderStr), questionsInRandomOrder {
			}
			
			if let questionsInRandomOrder = Bool(self.currentSet(option: .questionsInRandomOrder) ?? "true"), questionsInRandomOrder {
				self.set.shuffle()
			}
				
			self.quiz = set.enumerated().makeIterator()
		}
		
		DispatchQueue.global(qos: .userInitiated).async {
			self.preloadImages()
		}
		
		self.createAnswerButtons()
		
		let title = AudioSounds.bgMusic?.isPlaying == true ? "Pause music" : "Play music"
		self.muteMusic.setTitle(title.localized, for: .normal)
	
		self.goBack.setTitle("Questions menu".localized, for: .normal)
		self.mainMenu.setTitle("Main menu".localized, for: .normal)
		self.pauseButton.setTitle("Pause".localized, for: .normal)
		self.pauseView.isHidden = true
		self.blurView.isHidden = true
		
		// Theme settings
		self.loadCurrentTheme()
		
		// Loads the theme if user uses a home quick action
		NotificationCenter.default.addObserver(self, selector: #selector(self.loadCurrentTheme), name: .UIApplicationDidBecomeActive, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.userDidTakeScreenshot), name: .UIApplicationUserDidTakeScreenshot, object: nil)
		
		if UserDefaultsManager.score < 5 {
			self.helpButton.alpha = 0.4
		}
		
		self.addSwipeGestures()
		
		self.pickQuestion()
		self.updateTimer()
		
		if let helpButtonEnabled = Bool(self.currentSet(option: .helpButtonEnabled) ?? "true"), helpButtonEnabled && QuestionsAppOptions.isHelpEnabled {
			self.helpButton.isHidden = false
		} else {
			self.helpButton.isHidden = true
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.detectIfScreenIsCaptured()
	}
	
	private func updateTimer() {
		
		if let quizTimeString = SetOfTopics.shared.currentTopics[currentTopicIndex].quiz.customOptions[.timePerSetInSeconds],
			let quizTimeInterval = TimeInterval(quizTimeString), quizTimeInterval > 0 {
			
			self.quizTime = quizTimeInterval
			
			let timeMoreThan1Minute = self.quizTime > 60
			
			DispatchQueue.main.async {
				self.quizTimerLabel.isHidden = false
				self.quizTimerLabel.text = (timeMoreThan1Minute ? String(Int(self.quizTime.rounded(.down))) : String(format: "%.1f", self.quizTime)) + "s"
			}
			
			if #available(iOS 10.0, *) {
				
				Timer.scheduledTimer(withTimeInterval: timeMoreThan1Minute ? 1 : 0.1, repeats: true, block: { timer in
					
					guard self.previousQuizTime == -1 else { return }
					
					self.quizTime -= timeMoreThan1Minute ? 1 : 0.1
					
					if self.quizTime <= 0 {
						self.quizTime = 0
						DispatchQueue.main.async { self.quizTimerLabel.text = "0s" }
						self.presentedViewController?.dismiss(animated: true)
						self.endOfQuestionsAlert()
						timer.invalidate()
					}
					else {
						DispatchQueue.main.async {
							self.quizTimerLabel.text = (timeMoreThan1Minute ? String(Int(self.quizTime.rounded(.down))) : String(format: "%.1f", self.quizTime)) + "s"
						}
					}
				})
			}
		}
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		// Redraw the buttons to update the rounded corners when rotating the device
		self.answerButtons.forEach { $0.setNeedsDisplay() }
		self.pauseButton.setNeedsDisplay()
		self.pauseView.setNeedsDisplay()
		self.mainMenu.setNeedsDisplay()
		self.goBack.setNeedsDisplay()
		self.muteMusic.setNeedsDisplay()
	}
	
	// MARK: UIResponder

	// If user shake the device, an alert to repeat the quiz pop ups
	override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
		
		guard motion == .motionShake else { return }
		
		let currentQuestion = Int(String(remainingQuestionsLabel.text?.first ?? "0")) ?? 0
		
		FeedbackGenerator.impactOcurredWith(style: .medium)
		
		if self.repeatTimes < QuestionsAppOptions.maximumRepeatTriesPerQuiz && currentQuestion > 1 {
			
			let alertViewController = UIAlertController(title: "Repeat?".localized,
														message: "Do you want to start again?".localized,
														preferredStyle: .alert)
			
			alertViewController.addAction(title: "OK".localized, style: .default) { action in self.repeatActionDetailed() }
			alertViewController.addAction(title: "Cancel".localized, style: .cancel)
			
			present(alertViewController, animated: true)
		}
		else if self.repeatTimes >= QuestionsAppOptions.maximumRepeatTriesPerQuiz {
			showOKAlertWith(title: "Attention", message: "Maximum repeat tries per quiz reached")
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
			AudioSounds.bgMusic?.setVolumeLevel(to: AudioSounds.bgMusicVolume)
		}
		else if segue.identifier == "imageDetailsSegue", let imageDetailsVC = segue.destination as? ImageDetailsViewController {
			imageDetailsVC.modalPresentationStyle = .overCurrentContext
			imageDetailsVC.viewDidLoad()
			imageDetailsVC.imageView?.image = self.questionImageButton.imageView?.image
			imageDetailsVC.closeViewButton?.backgroundColor = .themeStyle(dark: .orange, light: .coolBlue)
			imageDetailsVC.preferredContentSize = imageDetailsVC.imageView?.sizeThatFits(self.view.frame.size) ?? imageDetailsVC.view.frame.size
		}
		
		if segue.identifier != "imageDetailsSegue" {
			self.saveScore()
		}
	}
	
	// MARK: Actions
	
	@IBAction func tapAnyWhereToClosePauseMenu(_ sender: UITapGestureRecognizer) {
		if !self.pauseView.isHidden {
			self.pauseMenuAction()
		}
	}
	
	@objc func verifyButton(_ sender: RoundedButton) {
		self.verify(answer: UInt8(sender.tag))
	}

	@IBAction func pauseMenu() {
		self.pauseMenuAction()
	}
	
	@IBAction func goBackAction() {
		if !self.isSetFromJSON {
			performSegue(withIdentifier: "unwindToQuizSelector", sender: self)
		} else {
			performSegue(withIdentifier: "unwindToQRScanner", sender: self)
		}
	}
	
	@IBAction func helpAction() {
		
		FeedbackGenerator.impactOcurredWith(style: .light)
		
		if UserDefaultsManager.score >= abs(QuestionsAppOptions.helpActionPoints) {
			
			var timesUsed: UInt8 = 0
			self.answerButtons.forEach { if $0.alpha != 1.0 { timesUsed += 1 } }
			
			var helpTries: UInt8 = 0
			if QuestionsAppOptions.maximumHelpTries == 0 || (QuestionsAppOptions.maximumHelpTries >= self.answerButtons.count && self.answerButtons.count > 1) {
				helpTries = UInt8(self.answerButtons.count) - 1
			} else  {
				helpTries = QuestionsAppOptions.maximumHelpTries
			}
			
			if timesUsed < helpTries {
				
				UserDefaultsManager.score += QuestionsAppOptions.helpActionPoints
				
				var randomQuestionIndex = UInt32()
				
				repeat {
					randomQuestionIndex = arc4random_uniform(UInt32(self.answerButtons.count))
				} while(self.correctAnswer.contains(UInt8(randomQuestionIndex)) || (answerButtons[Int(randomQuestionIndex)].alpha != 1.0))
				
				UIView.animate(withDuration: 0.4) {
					self.answerButtons[Int(randomQuestionIndex)].alpha = 0.4
				}
			}
			else {
				showOKAlertWith(title: "Attention", message: "Maximum help tries per question reached")
				self.helpButton.alpha = 0.4
			}
		}
		else {
			showOKAlertWith(title: "Attention", message: "Not enough points (5 needed).\nYou get points only get you complete a quiz.")
			self.helpButton.alpha = 0.4
		}
	}
	
	@IBAction func muteMusicAction() {
		
		if let bgMusic = AudioSounds.bgMusic {
			
			if bgMusic.isPlaying {
				bgMusic.pause()
				muteMusic.setTitle("Play music".localized, for: .normal)
			}
			else {
				bgMusic.play()
				muteMusic.setTitle("Pause music".localized, for: .normal)
			}
			UserDefaultsManager.backgroundMusicSwitchIsOn = bgMusic.isPlaying
		}
	}
	
	@IBAction func respondToSwipeGesture(gesture: UIGestureRecognizer) {
		
		if let swipeGesture = gesture as? UISwipeGestureRecognizer {
			
			let darkThemeEnabled = UserDefaultsManager.darkThemeSwitchIsOn
			
			if !darkThemeEnabled && (swipeGesture.direction == .down) {
				UserDefaultsManager.darkThemeSwitchIsOn = true
				AppDelegate.updateVolumeBarTheme()
			}
			else if darkThemeEnabled && (swipeGesture.direction == .up) {
				UserDefaultsManager.darkThemeSwitchIsOn = false
				AppDelegate.updateVolumeBarTheme()
			}
			else { return }
			
			UIView.transition(with: self.view, duration: 0.3, options: [.curveLinear], animations: {
				self.loadCurrentTheme()
				self.setNeedsStatusBarAppearanceUpdate()
			})
		}
	}
	
	// MARK: Convenience
	
	@objc private func appWillEnterForeground() {
		self.pauseMenuAction()
	}
	
	@objc private func userDidTakeScreenshot() {
		
		guard QuestionsAppOptions.privacyFeaturesEnabled else { return }
		
		if self.pauseView.isHidden {
			self.pauseMenuAction()
		}
		
		let contentIsProtectedAlert = UIAlertController(title: "This content is protected", message: "Please don't use the screen recorder or take screenshots", preferredStyle: .alert)
		contentIsProtectedAlert.addAction(title: "Exit quiz", style: .cancel) { _ in
			self.goBackAction()
		}
		contentIsProtectedAlert.addAction(title: "OK", style: .default)
		self.present(contentIsProtectedAlert, animated: true)
	}
	
	private func createAnswerButtons() {
		
		// Should fix this stuff in the storyboard...
		self.answerStub.isHidden = true
		
		let numberOfAnswers = set.first?.answers.count ?? 4
		
		for i in 0..<numberOfAnswers {
			
			let button = RoundedButton()
			button.cornerRadius = 15
			button.setup(shadows:
				ShadowEffect(
					shadowColor: .black,
					shadowOffset: CGSize(width: 0.5, height: 3.5),
					shadowOpacity: 0.15,
					shadowRadius: 4)
			)
			button.tag = i
			button.addTarget(self, action: #selector(self.verifyButton), for: .touchDown)
			button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
			
			self.answerButtons.append(button)
			self.answersStackView.addArrangedSubview(button)
		}
	}
	
	private func preloadImages() {
		for fullQuestion in self.set.dropFirst() { //.dropFirst() Drops the first because it will be cached by the 'pickQuestion()' function
			if let validImageURL = fullQuestion.imageURL, !validImageURL.isEmpty && !CachedImages.shared.exists(key: validImageURL.hash) {
				if let validImage = UIImage(contentsOf: URL(string: validImageURL)) {
					CachedImages.shared.save(image: validImage, withKey: validImageURL.hash)
				}
			}
		}
	}
	
	private func pauseMenuAction(animated: Bool = true) {
		
		if self.pauseView.isHidden {
			self.previousQuizTime = self.quizTime
		} else {
			self.quizTime = self.previousQuizTime
			self.previousQuizTime = -1
			self.detectIfScreenIsCaptured()
		}
		
		let duration: TimeInterval = 0.1
		let title = (pauseView.isHidden) ? "Continue" : "Pause"
		pauseButton.setTitle(title.localized, for: .normal)

		UIView.transition(with: self.view, duration: duration, options: [.transitionCrossDissolve], animations: {
			self.pauseView.isHidden = !self.pauseView.isHidden
			self.blurView.isHidden = !self.blurView.isHidden
		})
		
		let newVolume = (pauseView.isHidden) ? AudioSounds.bgMusicVolume : (AudioSounds.bgMusicVolume / 5.0)
		AudioSounds.bgMusic?.setVolumeLevel(to: newVolume)
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
	
	@objc func loadCurrentTheme() {
		
		let currentThemeColor = UIColor.themeStyle(dark: .white, light: .black)
		
		self.activityIndicatorView.activityIndicatorViewStyle = UserDefaultsManager.darkThemeSwitchIsOn ? .white : .gray
		self.helpButton.setTitleColor(dark: .orange, light: .defaultTintColor, for: .normal)
		self.remainingQuestionsLabel.textColor = currentThemeColor
		self.quizTimerLabel.textColor = currentThemeColor
		self.questionLabel.textColor = currentThemeColor
		self.view.backgroundColor = .themeStyle(dark: .black, light: .white)
		self.pauseButton.backgroundColor = .themeStyle(dark: .veryDarkGray, light: .veryLightGray)
		self.pauseButton.setTitleColor(dark: .white, light: .defaultTintColor, for: .normal)
		self.pauseView.backgroundColor = .themeStyle(dark: .lightGray, light: .veryVeryLightGray)

		self.pauseView.subviews.first?.subviews.forEach { ($0 as? UIButton)?.setTitleColor(dark: .black, light: .darkGray, for: .normal)
			($0 as? UIButton)?.backgroundColor = .themeStyle(dark: .warmColor, light: .warmYellow) }
		
		self.blurView.effect = UserDefaultsManager.darkThemeSwitchIsOn ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
		
		self.answerButtons.forEach { $0.backgroundColor = .themeStyle(dark: .orange, light: .defaultTintColor); $0.dontInvertColors() }
		
		self.setNeedsStatusBarAppearanceUpdate()
		
		self.detectIfScreenIsCaptured()
	}
	
	private func detectIfScreenIsCaptured() {
		if QuestionsAppOptions.privacyFeaturesEnabled, #available(iOS 11.0, *), UIScreen.main.isCaptured {
			
			if self.pauseView.isHidden {
				self.pauseMenuAction()
			}
			
			let contentIsProtectedAlert = UIAlertController(title: "This content is protected", message: "Please don't use the screen recorder or take screenshots", preferredStyle: .alert)
			
			contentIsProtectedAlert.addAction(title: "Exit quiz", style: .cancel) { _ in
				self.goBackAction()
			}
			
			contentIsProtectedAlert.addAction(title: "I've disabled it", style: .default) { _ in
				if UIScreen.main.isCaptured {
					self.present(contentIsProtectedAlert, animated: true)
				}
			}
			
			self.present(contentIsProtectedAlert, animated: true)
		}
	}
	
	private var currentURL: URL? = nil
	public func pickQuestion() {
		
		self.detectIfScreenIsCaptured()
		
		// Restore
		UIView.animate(withDuration: 0.75) {
			self.answerButtons.forEach { $0.alpha = 1 }
			
			if UserDefaultsManager.score >= 5 {
				self.helpButton.alpha = 1.0
			}
		}
		
		if let quiz0 = quiz.next() {
			
			let fullQuestion = quiz0.element
			
			self.correctAnswer = fullQuestion.correctAnswers
			self.questionLabel.text = fullQuestion.question.localized
			
			let answers = fullQuestion.answers
			
			for i in 0..<self.answerButtons.count {
				self.answerButtons[i].setTitle(answers[i].localized, for: .normal)
			}
			
			self.remainingQuestionsLabel.text = "\(quiz0.offset + 1)/\(self.set.count)"
			
			self.activityIndicatorView.stopAnimating()
			
			if let imageString = fullQuestion.imageURL, !imageString.isEmpty {
				
				if CachedImages.shared.exists(key: imageString.hash) {
					CachedImages.shared.asyncManageImage(withKey: imageString.hash) { cachedImage in
						self.questionImageButton.setImage(cachedImage, for: .normal)
						self.questionImageButton.isHidden = false
					}
				}
				else {
					
					self.questionImageButton.isHidden = true
					
					self.activityIndicatorView.startAnimating()
					
					self.currentURL = URL(string: imageString)
					
					UIImage.manageContentsOf(self.currentURL, completionHandler: { (image, url) in
						if url == self.currentURL {
							self.activityIndicatorView.stopAnimating()
							self.questionImageButton.setImage(image, for: .normal)
							self.questionImageButton.isHidden = false
						}
						CachedImages.shared.save(image: image, withKey: imageString.hash)
					}, errorHandler: {
						self.activityIndicatorView.stopAnimating()
					})
				}
			}
			else {
				self.questionImageButton.isHidden = true
			}
		}
		else {
			self.endOfQuestionsAlert()
		}
	}

	private func isSetCompleted() -> Bool {
		let topicName = SetOfTopics.shared.currentTopics[currentTopicIndex].name
		if let topicQuiz = DataStoreArchiver.shared.completedSets[topicName] {
			return topicQuiz[currentSetIndex] ?? false
		}
		return false
	}
	
	private func saveScore() {
		
		if !self.isSetCompleted() {
			UserDefaultsManager.correctAnswers += correctAnswers
			UserDefaultsManager.incorrectAnswers += incorrectAnswers
			UserDefaultsManager.score += (self.correctAnswers * QuestionsAppOptions.correctAnswerPoints) + (self.incorrectAnswers * QuestionsAppOptions.incorrectAnswerPoints)
		}
		
		let topicName = SetOfTopics.shared.currentTopics[self.currentTopicIndex].name
		DataStoreArchiver.shared.completedSets[topicName]?[self.currentSetIndex] = true
		guard DataStoreArchiver.shared.save() else { print("Error saving settings"); return }
	}
	
	private func okActionDetailed() {
		if !self.isSetFromJSON {
			self.performSegue(withIdentifier: "unwindToQuizSelector", sender: self)
		} else {
			self.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
		}
	}
	
	private func repeatActionDetailed() {
		self.repeatTimes += 1
		self.correctAnswers = 0
		self.incorrectAnswers = 0
		self.setUpQuiz()
		UserDefaultsManager.score = oldScore
		self.pickQuestion()
	}
	
	@objc private func verify(answer: UInt8) {
		
		pausePreviousSounds()
		
		let isCorrectAnswer = correctAnswer.contains(answer)
		let willNoticeIfAnswerIsCorrectOrIncorrect = Bool(self.currentSet(option: .showCorrectIncorrectAnswer) ?? "true") ?? true
		
		if isCorrectAnswer {
			correctAnswers += 1
			if willNoticeIfAnswerIsCorrectOrIncorrect { AudioSounds.correct?.play() }
		}
		else {
			incorrectAnswers += 1
			if willNoticeIfAnswerIsCorrectOrIncorrect { AudioSounds.incorrect?.play() }
		}
		
		UIView.transition(with: self.answerButtons[Int(answer)], duration: 0.25, options: [.transitionCrossDissolve], animations: {
			
			if willNoticeIfAnswerIsCorrectOrIncorrect {
				self.answerButtons[Int(answer)].backgroundColor = isCorrectAnswer ? .darkGreen : .alternativeRed
			} else {
				self.answerButtons[Int(answer)].backgroundColor = .coolBlue
			}
			
		}) { completed in
			if completed {
				self.pickQuestion()
				UIView.transition(with: self.answerButtons[Int(answer)], duration: 0.2, options: [.transitionCrossDissolve], animations: {
					self.answerButtons[Int(answer)].backgroundColor = .themeStyle(dark: .orange, light: .defaultTintColor)
				})
			}
		}
		
		if willNoticeIfAnswerIsCorrectOrIncorrect {
			FeedbackGenerator.notificationOcurredOf(type: isCorrectAnswer ? .success : .error)
		} else {
			FeedbackGenerator.impactOcurredWith(style: .light)
		}
	}
	
	private func pausePreviousSounds() {
		
		if let incorrectSound = AudioSounds.incorrect, incorrectSound.isPlaying {
			incorrectSound.pause()
			incorrectSound.currentTime = 0
		}
		
		if let correctSound = AudioSounds.correct, correctSound.isPlaying {
			correctSound.pause()
			correctSound.currentTime = 0
		}
	}
	
	private func setUpQuiz() {
		
		self.set = SetOfTopics.shared.currentTopics[currentTopicIndex].quiz.sets[currentSetIndex]
		
		if let questionsInRandomOrder = Bool(self.currentSet(option: .questionsInRandomOrder) ?? "true"), questionsInRandomOrder {
			self.set.shuffle()
		}
		self.quiz = set.enumerated().makeIterator()
	}
	
	// Alerts
	
	private func endOfQuestionsAlert() {
		
		let helpScore = self.oldScore - UserDefaultsManager.score
		let score = (self.correctAnswers * QuestionsAppOptions.correctAnswerPoints) + (self.incorrectAnswers * QuestionsAppOptions.incorrectAnswerPoints) - helpScore
					//(correctAnswers * 20) - (incorrectAnswers * 10) - helpScore
		
		let extraTitle = (self.quizTimerLabel.text == "0s" || self.quizTimerLabel.text == "0.0s") ? "(Time ran out)\n" : ""
		
		let title = extraTitle.localized + "Score: ".localized + "\(score) pts"
		let message = "Correct answers: ".localized + "\(correctAnswers)" + "/" + "\(set.count)"
		
		let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		alertViewController.addAction(title: "OK".localized, style: .default) { action in self.okActionDetailed() }
		
		if (self.correctAnswers < set.count) && (self.repeatTimes < 2) && !isSetCompleted() {
			let repeatText = "Repeat".localized + " (\(2 - self.repeatTimes))"
			alertViewController.addAction(title: repeatText, style: .cancel) { action in
				self.repeatActionDetailed()
				self.blurView.isHidden = true
			}
		}
		
		if QuestionsAppOptions.privacyFeaturesEnabled {
			UIView.transition(with: self.view, duration: 0.2, options: [.transitionCrossDissolve], animations: {
				self.blurView.isHidden = false
			})
		}
		
		self.present(alertViewController, animated: true)
	}
	
	private func showOKAlertWith(title: String, message: String) {
		let alertViewController = UIAlertController.OKAlert(title: title, message: message)
		present(alertViewController, animated: true)
	}
}
