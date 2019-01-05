import AVFoundation
import UIKit

class MainViewController: UIViewController {
	
	// MARK: Properties
	
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var communityButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
	
	@IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var backgroundImageView: UIImageView!
	
	static var parallaxEffect = UIMotionEffectGroup()
	static var backgroundView: UIView?

	@IBOutlet weak var mainMenuStack: UIStackView!
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
		NotificationCenter.default.addObserver(self, selector: #selector(loadTheme), name: UIApplication.didBecomeActiveNotification, object: nil)
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
		[self.startButton, self.communityButton, self.settingsButton].forEach { $0?.setNeedsDisplay() }
	}

	// MARK: UnwindSegue

	@IBAction func unwindToMainMenu(_ unwindSegue: UIStoryboardSegue) {
		AudioSounds.bgMusic?.setVolumeLevel(to: AudioSounds.defaultBGMusicLevel)
	}
	
	// MARK: Actions
	
	@IBAction func loadAppTopics(_ sender: UIButton) {
		SetOfTopics.shared.current = .app
	}

	@IBAction func loadCommunityTopics(_ sender: UIButton) {
		SetOfTopics.shared.current = .community
	}
	
	// MARK: Convenience
	
	private func initializeSounds() {
		if UserDefaultsManager.backgroundMusicSwitchIsOn {
			AudioSounds.bgMusic?.play()
		}
	}
	
	private func initializeLables() {
		self.startButton.setTitle(Localized.MainMenu_Entries_Topics, for: .normal)
		self.communityButton.setTitle(Localized.MainMenu_Entries_Community, for: .normal)
		self.settingsButton.setTitle(Localized.MainMenu_Entries_Settings, for: .normal)
	}
	
	@IBAction func loadTheme() {
		self.navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		self.navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		self.backgroundImageView.dontInvertColors()
		self.startButton.dontInvertColors()
		self.communityButton.dontInvertColors()
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
