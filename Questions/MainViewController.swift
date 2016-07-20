import AVFoundation
import UIKit

// FIXME: 'Unbalanced calls to begin/end appearance transitions' when going from the pause menu to the main menu

class MainViewController: UIViewController, UIAlertViewDelegate {

	static var bgMusic: AVAudioPlayer?
	static var correct: AVAudioPlayer?
	static var incorrect: AVAudioPlayer?
	
	@IBOutlet var startButton: UIButton!
	@IBOutlet var instructionsButton: UIButton!
	@IBOutlet var settingsButton: UIButton!
	@IBOutlet var mainMenuNavItem: UINavigationItem!
	
	static var settings = Settings()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// LOAD CONFIGURATION FILE or CREATE A NEW ONE
		if let mySettings1 = NSKeyedUnarchiver.unarchiveObjectWithFile(Settings.path) as? Settings {
			MainViewController.settings = mySettings1
		}
		else {
			MainViewController.settings.save()
		}

		// INITIALIZE SOUNDS
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

		if MainViewController.settings.music {
			MainViewController.bgMusic?.play()
		}
		
		MainViewController.bgMusic?.numberOfLoops = Int.max

		// SET BUTTON TITLES
		startButton.setTitle("START GAME".localized, forState: .Normal)
		instructionsButton.setTitle("INSTRUCTIONS".localized, forState: .Normal)
		settingsButton.setTitle("SETTINGS".localized, forState: .Normal)
		mainMenuNavItem.title = "Main menu".localized
	}

	@IBAction func showInstructions(sender: AnyObject) {
		let alertViewController = UIAlertController(title: "Instructions".localized,
													message: "INSTRUCTIONS_TEXT".localized,
													preferredStyle: .Alert)

		let okAction = UIAlertAction(title: "OK".l, style: .Default) { (action) -> Void in }

		alertViewController.addAction(okAction)

		presentViewController(alertViewController, animated: true, completion: nil)
	}

	@IBAction func unwindToMainMenu(unwindSegue: UIStoryboardSegue) {

	}

}
