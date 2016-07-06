import AVFoundation
import UIKit

class VC: UIViewController, UIAlertViewDelegate {
	
	static var bgMusic: AVAudioPlayer?
	
	static var language: String?
	
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var instructionsButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var mainMenuNavItem: UINavigationItem!
	
	func setButtonsLanguage(lang: String) {
		
		startButton.setImage(UIImage(named: "START_GAME".localized(lang)), forState: UIControlState.Normal)
		instructionsButton.setImage(UIImage(named: "INSTRUCTIONS".localized(lang)), forState: UIControlState.Normal)
		settingsButton.setImage(UIImage(named: "SETTINGS".localized(lang)), forState: UIControlState.Normal)
		mainMenuNavItem.title = "MAIN_MENU".localized(lang)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set up the background music
		if let bgMusic = setupAudioPlayerWithFile("bensound-funkyelement", type:"mp3") {
			VC.bgMusic = bgMusic
		}
		
		VC.bgMusic?.volume = 0.06
		VC.bgMusic?.play()
		
		// Set default language
		let lang = NSLocale.preferredLanguages()[0]
		let localLanguage = lang.substringToIndex(lang.startIndex.advancedBy(2))

		VC.language = localLanguage
		
		setButtonsLanguage(localLanguage)
    }

	@IBAction func showInstructions(sender: AnyObject) {
		let alertViewController = UIAlertController(title: "INSTRUCTIONS".localized(VC.language!),
		                                            message: "INSTRUCTIONS_TEXT".localized(VC.language!),
		                                            preferredStyle: .Alert)
		
		let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in }

		alertViewController.addAction(okAction)
		
		presentViewController(alertViewController, animated: true, completion: nil)
	}
	
	@IBAction func unwindWithSelectedLanguage(segue: UIStoryboardSegue) {
		
		if let languagePickerViewController = segue.sourceViewController as? LanguageVC,
			selectedLanguage = languagePickerViewController.selectedLanguage {
			
			if selectedLanguage == "SPANISH".localized(VC.language!) {
				VC.language = "es"
			}
			else {
				VC.language = "en"
			}
			
			setButtonsLanguage(VC.language!)
		}
	}

}

func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer? {
	
	let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
	let url = NSURL.fileURLWithPath(path!)
	
	var audioPlayer:AVAudioPlayer?
	
	do {
		try audioPlayer = AVAudioPlayer(contentsOfURL: url)
	} catch {
		print("Player not available")
	}
	
	return audioPlayer
}
