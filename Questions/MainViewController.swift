import AVFoundation
import UIKit

class MainViewController: UIViewController {
	
	// MARK: Properties
	
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var instructionsButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var mainMenuNavItem: UINavigationItem!
	
	static var bgMusic: AVAudioPlayer?
	static var correct: AVAudioPlayer?
	static var incorrect: AVAudioPlayer?
	static var motionEffects: UIMotionEffectGroup?
	static var backgroundView: UIView?
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		MainViewController.backgroundView = view.subviews.first
		
		// Add parallax effect to background image view
		MainViewController.addParallax(toView: MainViewController.backgroundView)
		
		// Load configuration file (if it doesn't exist it creates a new one when the app goes to background)
		if let mySettings = NSKeyedUnarchiver.unarchiveObject(withFile: Settings.path) as? Settings {
			Settings.sharedInstance = mySettings
		}
		
		if Settings.sharedInstance.darkThemeEnabled {
			navigationController?.navigationBar.barStyle = .black
			navigationController?.navigationBar.tintColor = .orange
		}

		// Initialize sounds
		MainViewController.bgMusic = AVAudioPlayer(file: "bensound-funkyelement", type: "mp3")
		MainViewController.correct = AVAudioPlayer(file: "correct", type: "mp3")
		MainViewController.incorrect = AVAudioPlayer(file: "incorrect", type: "wav")

		MainViewController.correct?.volume = 0.10
		MainViewController.incorrect?.volume = 0.33
		MainViewController.bgMusic?.volume = 0.06

		if Settings.sharedInstance.musicEnabled {
			MainViewController.bgMusic?.play()
		}
		
		MainViewController.bgMusic?.numberOfLoops = Int.max

		// Set button titles
		startButton.setTitle("START GAME".localized, for: .normal)
		instructionsButton.setTitle("INSTRUCTIONS".localized, for: .normal)
		settingsButton.setTitle("SETTINGS".localized, for: .normal)
		mainMenuNavItem.title = "Main menu".localized
		
		// Set button position and size
		setButtonFrames()
		
		// If user rotates screen, the buttons position and sizes are recalculated
		NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.setButtonFrames),
		                                       name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
	}

	// MARK: Alerts
	
	@IBAction func showInstructions() {
		let alertViewController = UIAlertController(title: "Instructions".localized,
													message: "INSTRUCTIONS_TEXT".localized,
													preferredStyle: .alert)
		
		let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: nil)
		alertViewController.addAction(okAction)
		
		present(alertViewController, animated: true, completion: nil)
	}

	// MARK: UnwindSegue

	@IBAction func unwindToMainMenu(_ unwindSegue: UIStoryboardSegue) {	}

	// MARK: Convenience
	
	func setButtonFrames() {
		let buttonsWidth = UIScreen.main.bounds.maxX / 2.0
		var buttonsHeight = UIScreen.main.bounds.maxY * 0.08
		
		if let fontSize = instructionsButton.titleLabel?.font.pointSize {
			buttonsHeight = fontSize * 2.0
		}
		
		let spaceBetweenButtons = buttonsHeight * 1.6
		let xPosition = (UIScreen.main.bounds.maxX / 2.0) - (buttonsWidth / 2.0)
		let yPosition = UIScreen.main.bounds.maxY / 2.0
		
		instructionsButton.frame = CGRect(x: xPosition, y: yPosition, width: buttonsWidth, height: buttonsHeight)
		startButton.frame = CGRect(x: xPosition, y: yPosition - spaceBetweenButtons, width: buttonsWidth, height: buttonsHeight)
		settingsButton.frame = CGRect(x: xPosition, y: yPosition + spaceBetweenButtons, width: buttonsWidth, height: buttonsHeight)
	}

	static func addParallax(toView: UIView?) {
		
		let xAmount = 25
		let yAmount = 15
		
		let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
		horizontal.minimumRelativeValue = -xAmount
		horizontal.maximumRelativeValue = xAmount

		let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
		vertical.minimumRelativeValue = -yAmount
		vertical.maximumRelativeValue = yAmount

		MainViewController.motionEffects = UIMotionEffectGroup()
		MainViewController.motionEffects?.motionEffects = [horizontal, vertical]
		
		if let effects = MainViewController.motionEffects {
			toView?.addMotionEffect(effects)
		}
	}
}
