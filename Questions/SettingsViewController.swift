import UIKit

class SettingsViewController: UITableViewController, UIAlertViewDelegate  {

	@IBOutlet var settingsNavItem: UINavigationItem!
	
	@IBOutlet var bgMusicLabel: UILabel!
	@IBOutlet var bgMusicSwitch: UISwitch!
	@IBOutlet var resetGameLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		settingsNavItem.title = "Settings".localized
		resetGameLabel.text = "Reset game".localized
		bgMusicLabel.text = "Background music".localized

		bgMusicSwitch.setOn(MainViewController.bgMusic!.playing, animated: true)
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		if tableView.cellForRowAtIndexPath(indexPath)!.textLabel!.text == "Reset game".localized {
			resetGameAlert()
		}
	}
	
	func resetGameAlert() {
		let alertViewController = UIAlertController(title: "",
		                                            message: "RESET_GAME_ADVICE".localized,
		                                            preferredStyle: .ActionSheet)
		
		let cancelAction = UIAlertAction(title: "Cancel".localized, style: .Cancel) { (action) -> Void in }
		let okAction = UIAlertAction(title: "OK".localized, style: .Destructive) {
			(action) -> Void in
			
			self.removeFile("Settings.archive", from: Settings.documentsDirectory())
			self.restartGameAlert()
		}
		
		alertViewController.addAction(cancelAction)
		alertViewController.addAction(okAction)

		presentViewController(alertViewController, animated: true, completion: nil)
	}

	func restartGameAlert() {
		let alertViewController = UIAlertController(title: "Restart the game".localized,
		                                            message: "RESTART_GAME_TEXT".localized,
		                                            preferredStyle: .Alert)
		
		let okAction = UIAlertAction(title: "OK".localized, style: .Default) { (action) -> Void in }
		
		alertViewController.addAction(okAction)
		
		presentViewController(alertViewController, animated: true, completion: nil)
	}
	
	@IBAction func switchBGMusic(sender: UISwitch) {

		if let bgMusic = MainViewController.bgMusic {

			if bgMusicSwitch.on {
				MainViewController.settings.musicEnabled = true
				bgMusic.play()
			}
			else {
				MainViewController.settings.musicEnabled = false
				bgMusic.pause()
			}
			
			MainViewController.settings.save()
		}

	}
	
	func removeFile(file: String, from: String) {
		
		let fileManager = NSFileManager.defaultManager()
		
		do {
			try fileManager.removeItemAtPath("\(from)/\(file)")
		}
		catch {
			print(error)
		}
	}

}
