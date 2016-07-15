import AVFoundation
import UIKit

class MainViewController: UIViewController, UIAlertViewDelegate {
	
	static var bgMusic: AVAudioPlayer?

	static var language: String?
	
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var instructionsButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var mainMenuNavItem: UINavigationItem!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        if let bgMusic = AVAudioPlayer(file:"bensound-funkyelement", type:"mp3") {
			MainViewController.bgMusic = bgMusic
		}
		
		MainViewController.bgMusic?.volume = 0.06
		MainViewController.bgMusic?.play()
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
