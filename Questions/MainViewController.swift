import AVFoundation
import UIKit

class MainViewController: UIViewController {
	
	// MARK: Properties
	
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var readQRCodeButton: UIButton!
	@IBOutlet weak var scoreLabel: UILabel!
	
	static var parallaxEffect = UIMotionEffectGroup()
	static var backgroundView: UIView?

	// MARK: View life cycle

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Add parallax effect to background image view
		MainViewController.backgroundView = view.subviews.first
		
		if Settings.sharedInstance.parallaxEnabled {
			MainViewController.addParallax(toView: MainViewController.backgroundView)
		}

		initializeSounds()
		initializeLables()
		
		// Set buttons and label position and size
		setFramesAndPosition()
		
		// If user rotates screen, the buttons position and sizes are recalculated
		NotificationCenter.default.addObserver(self, selector: #selector(setFramesAndPosition),
		                                       name: Notification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
		
		// Loads the theme if user uses a home quick action
		NotificationCenter.default.addObserver(self, selector: #selector(loadTheme),
		                                       name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		// Load score
		let answersScore = Settings.sharedInstance.score
		scoreLabel.text = "🏆 \(answersScore)pts"
		
		if answersScore == 0 {
			scoreLabel.textColor = .darkGray
		} else if answersScore < 0 {
			scoreLabel.textColor = .darkRed
		} else {
			scoreLabel.textColor = .darkGreen
		}
		loadTheme()
	}
	
	deinit {
		if #available(iOS 9.0, *) { }
		else {
			NotificationCenter.default.removeObserver(self)
		}
	}

	// MARK: UnwindSegue

	@IBAction func unwindToMainMenu(_ unwindSegue: UIStoryboardSegue) {
		Audio.setVolumeLevel(to: Audio.bgMusicVolume)
	}

	// MARK: Convenience
	
	func initializeSounds() {
		
		Audio.bgMusic = AVAudioPlayer(file: "bensound-thelounge", type: "mp3")
		Audio.correct = AVAudioPlayer(file: "correct", type: "mp3")
		Audio.incorrect = AVAudioPlayer(file: "incorrect", type: "wav")
		
		Audio.bgMusic?.volume = Audio.bgMusicVolume
		Audio.correct?.volume = 0.10
		Audio.incorrect?.volume = 0.25
		
		if Settings.sharedInstance.musicEnabled {
			Audio.bgMusic?.play()
		}
		
		Audio.bgMusic?.numberOfLoops = -1
	}
	
	func initializeLables() {
		startButton.setTitle("START GAME".localized, for: .normal)
		readQRCodeButton.setTitle("READ QR CODE".localized, for: .normal)
		settingsButton.setTitle("SETTINGS".localized, for: .normal)
		self.navigationItem.title = "Main menu".localized
	}

	func setFramesAndPosition() {
		
		let isPortrait = UIApplication.shared.statusBarOrientation.isPortrait
		
		let buttonsWidth = UIScreen.main.bounds.maxX / (isPortrait ? 1.85 : 2.0)
		var buttonsHeight = UIScreen.main.bounds.maxY * 0.08
		
		if let fontSize = startButton.titleLabel?.font.pointSize {
			buttonsHeight = fontSize * 2.0
		}
		
		let spaceBetweenButtons = buttonsHeight * 1.4
		let xPosition = (UIScreen.main.bounds.maxX / 2.0) - (buttonsWidth / 2.0)
		let yPosition = UIScreen.main.bounds.maxY / 2.0
		
		startButton.frame = CGRect(x: xPosition, y: yPosition - spaceBetweenButtons, width: buttonsWidth, height: buttonsHeight)
		readQRCodeButton.frame = CGRect(x: xPosition, y: yPosition, width: buttonsWidth, height: buttonsHeight)
		settingsButton.frame = CGRect(x: xPosition, y: yPosition + spaceBetweenButtons, width: buttonsWidth, height: buttonsHeight)
		
		// ScoreLabel values
		let scoreLabelHeight = scoreLabel.frame.height
		let scoreLabelWidth = scoreLabel.frame.width
		let xPosition2 = (UIScreen.main.bounds.maxX / 2.0) - (scoreLabelWidth / 2.0)
		
		scoreLabel.frame = CGRect(x: xPosition2, y: yPosition + spaceBetweenButtons*2, width: scoreLabelWidth, height: scoreLabelHeight)
	}

	func loadTheme() {
		self.navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		self.navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
	}
	
	static func addParallax(toView view: UIView?) {
		
		let xAmount = 25
		let yAmount = 15
		
		let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
		horizontal.minimumRelativeValue = -xAmount
		horizontal.maximumRelativeValue = xAmount

		let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
		vertical.minimumRelativeValue = -yAmount
		vertical.maximumRelativeValue = yAmount
		
		MainViewController.parallaxEffect.motionEffects = [horizontal, vertical]
		view?.addMotionEffect(MainViewController.parallaxEffect)
	}
}
