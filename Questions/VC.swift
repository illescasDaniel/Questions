import AVFoundation
import UIKit

class VC: UIViewController, UIAlertViewDelegate {
	
	var bgMusic: AVAudioPlayer?
	
	static var language: String?
	
	@IBOutlet weak var langButton: UIButton!
	@IBOutlet weak var soundButton: UIButton!
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var instructionsButton: UIButton!
	@IBOutlet weak var mainMenuNavItem: UINavigationItem!
	
	func setButtonsLanguage(lang: String) {
		
		langButton.setTitle("FLAG".localized(lang), forState: UIControlState.Normal)
		startButton.setImage(UIImage(named: "START_GAME".localized(lang)), forState: UIControlState.Normal)
		instructionsButton.setImage(UIImage(named: "INSTRUCTIONS".localized(lang)), forState: UIControlState.Normal)
		mainMenuNavItem.title = "MAIN_MENU".localized(lang)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set up the background music
		if let bgMusic = setupAudioPlayerWithFile("bensound-funkyelement", type:"mp3") {
			self.bgMusic = bgMusic
		}
		
		bgMusic?.volume = 0.06
		bgMusic?.play()
		
		// Set default language
		let lang = NSLocale.preferredLanguages()[0]
		let localLanguage = lang.substringToIndex(lang.startIndex.advancedBy(2))

		VC.language = localLanguage
		
		setButtonsLanguage(localLanguage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	@IBAction func showInstructions(sender: AnyObject) {
		let alertViewController = UIAlertController(title: "INSTRUCTIONS".localized(VC.language!),
		                                            message: "INSTRUCTIONS_TEXT".localized(VC.language!),
		                                            preferredStyle: .Alert)
		
		let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in }

		alertViewController.addAction(okAction)
		
		presentViewController(alertViewController, animated: true, completion: nil)
	}
	
	@IBAction func changeLangButton(sender: UIButton) {
		
		if VC.language == "es" {
			setButtonsLanguage("en")
			VC.language = "en"
		}
		else {
			setButtonsLanguage("es")
			VC.language = "es"
		}

	}
	
	@IBAction func soundButtonAction(sender: UIButton) {
		
		if bgMusic?.playing == true {
			bgMusic?.stop()
			soundButton.setTitle("🔇", forState: UIControlState.Normal)
		}
		else {
			bgMusic?.play()
			soundButton.setTitle("🔈", forState: UIControlState.Normal)
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
