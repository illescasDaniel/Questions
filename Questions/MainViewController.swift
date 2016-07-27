import AVFoundation
import UIKit

class MainViewController: UIViewController, UIAlertViewDelegate {
	
	// MARK: Properties
	
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var instructionsButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var mainMenuNavItem: UINavigationItem!
	
	static var bgMusic: AVAudioPlayer?
	static var correct: AVAudioPlayer?
	static var incorrect: AVAudioPlayer?
	static var settings = Settings()
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Add parallax effect to background image view
		addParallaxToView(view.subviews[0])
		
		// Load configuration file or create a new one
		if let mySettings = NSKeyedUnarchiver.unarchiveObjectWithFile(Settings.path) as? Settings {
			MainViewController.settings = mySettings
		}
		else {
			MainViewController.settings.save()
		}

		// Initialize sounds
		if let bgMusic = AVAudioPlayer(file: "bensound-funkyelement", type: "mp3") {
			MainViewController.bgMusic = bgMusic
		}

		if let correctSound = AVAudioPlayer(file: "correct", type: "mp3") {
			MainViewController.correct = correctSound
		}

		if let incorrectSound = AVAudioPlayer(file: "incorrect", type: "wav") {
			MainViewController.incorrect = incorrectSound
		}

		MainViewController.correct?.volume = 0.10
		MainViewController.incorrect?.volume = 0.33
		MainViewController.bgMusic?.volume = 0.06

		if MainViewController.settings.musicEnabled {
			MainViewController.bgMusic?.play()
		}
		
		MainViewController.bgMusic?.numberOfLoops = Int.max

		// Set button titles
		startButton.setTitle("START GAME".localized, forState: .Normal)
		instructionsButton.setTitle("INSTRUCTIONS".localized, forState: .Normal)
		settingsButton.setTitle("SETTINGS".localized, forState: .Normal)
		mainMenuNavItem.title = "Main menu".localized
	}

	// MARK: Alerts
	
	@IBAction func showInstructions() {
		let alertViewController = UIAlertController(title: "Instructions".localized,
													message: "INSTRUCTIONS_TEXT".localized,
													preferredStyle: .Alert)

		let okAction = UIAlertAction(title: "OK".localized, style: .Default) { (action) -> Void in }

		alertViewController.addAction(okAction)

		presentViewController(alertViewController, animated: true, completion: nil)
	}

	// MARK: UnwindSegue

	@IBAction func unwindToMainMenu(unwindSegue: UIStoryboardSegue) {

	}

	// MARK: Convenience

	func addParallaxToView(view: UIView) {
		let amount = 20

		let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
		horizontal.minimumRelativeValue = -amount
		horizontal.maximumRelativeValue = amount

		let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
		vertical.minimumRelativeValue = -amount
		vertical.maximumRelativeValue = amount

		let group = UIMotionEffectGroup()
		group.motionEffects = [horizontal, vertical]
		view.addMotionEffect(group)
	}
}
