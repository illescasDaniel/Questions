import AVFoundation
import UIKit

class MainViewController: UIViewController, UIAlertViewDelegate {

	static var bgMusic: AVAudioPlayer?
	static var correct: AVAudioPlayer?
	static var incorrect: AVAudioPlayer?

	static var settings: [String: AnyObject] = [:]
	
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var instructionsButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var mainMenuNavItem: UINavigationItem!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		if Settings.valueForKey("New game") == 1 {
			
			let emptyBoolArray = [Bool](count: Quiz.setsCount, repeatedValue: false)
			
			Settings.saveValue(emptyBoolArray, forKey: "Completed sets")
			Settings.saveValue(0, forKey: "New game")
		}

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

		if Settings.valueForKey("Music") == true {
			MainViewController.bgMusic?.play()
		}
		
		MainViewController.bgMusic?.numberOfLoops = Int.max

		startButton.setImage(UIImage(named: "Start game".localized), forState: UIControlState.Normal)
		instructionsButton.setImage(UIImage(named: "Instructions".localized), forState: UIControlState.Normal)
		settingsButton.setImage(UIImage(named: "Settings".localized), forState: UIControlState.Normal)
		mainMenuNavItem.title = "Main menu".localized
	}

	@IBAction func showInstructions(sender: AnyObject) {
		let alertViewController = UIAlertController(title: "Instructions".localized,
			message: "INSTRUCTIONS_TEXT".localized,
			preferredStyle: .Alert)

		let okAction = UIAlertAction(title: "OK".localized, style: .Default) { (action) -> Void in }

		alertViewController.addAction(okAction)

		presentViewController(alertViewController, animated: true, completion: nil)
	}

	@IBAction func unwindToMainMenu(unwindSegue: UIStoryboardSegue) {

	}

}
