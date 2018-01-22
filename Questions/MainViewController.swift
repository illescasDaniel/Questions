import AVFoundation
import UIKit

class MainViewController: UIViewController {
	
	// MARK: Properties
	
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var savedTopicsButton: UIButton!
	@IBOutlet weak var readQRCodeButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var backgroundImageView: UIImageView!
	
	static var parallaxEffect = UIMotionEffectGroup()
	static var backgroundView: UIView?

	// MARK: View life cycle

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Add parallax effect to background image view
		MainViewController.backgroundView = backgroundImageView
		
		if UserDefaultsManager.parallaxEffectSwitchIsOn {
			MainViewController.addParallax(toView: MainViewController.backgroundView)
		}

		self.initializeSounds()
		self.initializeLables()
		
		// Load the theme if user uses a home quick action
		NotificationCenter.default.addObserver(self, selector: #selector(loadTheme), name: .UIApplicationDidBecomeActive, object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		// Load score
		let answersScore = UserDefaultsManager.score
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
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		// Redraw the buttons to update the rounded corners when rotating the device
		[self.startButton, self.readQRCodeButton, self.settingsButton].forEach { $0?.setNeedsDisplay() }
	}
	
	@available(iOS, deprecated: 9.0)
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: UnwindSegue

	@IBAction func unwindToMainMenu(_ unwindSegue: UIStoryboardSegue) {
		AudioSounds.bgMusic?.setVolumeLevel(to: AudioSounds.bgMusicVolume)
	}
	
	// MARK: Actions
	
	@IBAction func loadAppTopics(_ sender: UIButton) {
		SetOfTopics.shared.isUsingUserSavedTopics = false
	}
	
	@IBAction func loadSavedTopics(_ sender: UIButton) {
		SetOfTopics.shared.isUsingUserSavedTopics = true
	}

	// MARK: Convenience
	
	private func initializeSounds() {
		
		AudioSounds.bgMusic = AVAudioPlayer(file: "bensound-thelounge", type: .mp3, volume: AudioSounds.bgMusicVolume)
		AudioSounds.correct = AVAudioPlayer(file: "correct", type: .mp3, volume: 0.10)
		AudioSounds.incorrect = AVAudioPlayer(file: "incorrect", type: .wav, volume: 0.25)
		
		if UserDefaultsManager.backgroundMusicSwitchIsOn {
			AudioSounds.bgMusic?.play()
		}
		
		AudioSounds.bgMusic?.numberOfLoops = -1
	}
	
	private func initializeLables() {
		self.startButton.setTitle("START GAME".localized, for: .normal)
		self.savedTopicsButton.setTitle("SAVED TOPICS".localized, for: .normal)
		self.readQRCodeButton.setTitle("READ QR CODE".localized, for: .normal)
		self.settingsButton.setTitle("SETTINGS".localized, for: .normal)
	}
	
	@IBAction func loadTheme() {
		self.navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		self.navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		self.backgroundImageView.dontInvertColors()
		self.startButton.dontInvertColors()
		self.readQRCodeButton.dontInvertColors()
		self.settingsButton.dontInvertColors()
		self.scoreLabel.dontInvertColors()
	}
	
	static func addParallax(toView view: UIView?) {
		
		let xAmount = 25
		let yAmount = 25
		
		let horizontal = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x", type: .tiltAlongHorizontalAxis)
		horizontal.minimumRelativeValue = -xAmount
		horizontal.maximumRelativeValue = xAmount

		let vertical = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
		vertical.minimumRelativeValue = -yAmount
		vertical.maximumRelativeValue = yAmount
		
		MainViewController.parallaxEffect.motionEffects = [horizontal, vertical]
		view?.addMotionEffect(MainViewController.parallaxEffect)
	}
}
