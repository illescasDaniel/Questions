import UIKit

class SettingsViewController: UITableViewController, UIAlertViewDelegate {

	// MARK: Properties

	@IBOutlet weak var settingsNavItem: UINavigationItem!
	@IBOutlet weak var bgMusicLabel: UILabel!
	@IBOutlet weak var bgMusicSwitch: UISwitch!
	@IBOutlet weak var parallaxEffectLabel: UILabel!
	@IBOutlet weak var parallaxEffectSwitch: UISwitch!
	@IBOutlet weak var resetGameLabel: UILabel!
	var options: [String] = []
	
	// MARK: View life cycle

	override func viewDidLoad() {
		super.viewDidLoad()
		
		settingsNavItem.title = "Settings".localized
		
		options = ["Background music".localized, "Parallax effect".localized, "Reset game".localized]

		bgMusicLabel.text = options[0]
		parallaxEffectLabel.text = options[1]
		resetGameLabel.text = options[2]
		
		// Value for the switch would be false if the music couldn't load
		bgMusicSwitch.setOn(MainViewController.bgMusic?.playing ?? false, animated: true)
		parallaxEffectSwitch.setOn(!MainViewController.backgroundView.motionEffects.isEmpty, animated: true)
	}

	// MARK: UITableViewDataSouce

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return options.count
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text == "Reset game".localized {
			resetGameAlert()
		}
	}

	// MARK: Alerts

	func resetGameAlert() {
		let alertViewController = UIAlertController(title: "",
		                                            message: "RESET_GAME_ADVICE".localized,
		                                            preferredStyle: .ActionSheet)

		let cancelAction = UIAlertAction(title: "NO".localized, style: .Cancel) { action in }
		let okAction = UIAlertAction(title: "Yes".localized, style: .Destructive) {
			action in

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

		let okAction = UIAlertAction(title: "OK".localized, style: .Default) { action in }

		alertViewController.addAction(okAction)

		presentViewController(alertViewController, animated: true, completion: nil)
	}

	// MARK: IBActions

	@IBAction func switchBGMusic() {

		if bgMusicSwitch.on {
			MainViewController.settings.musicEnabled = true
			MainViewController.bgMusic?.play()
		}
		else {
			MainViewController.settings.musicEnabled = false
			MainViewController.bgMusic?.pause()
		}

		MainViewController.settings.save()
	}

	@IBAction func switchParallaxEffect() {
		
		if parallaxEffectSwitch.on {
			MainViewController.addParallaxToView(MainViewController.backgroundView)
		}
		else {
			MainViewController.backgroundView.removeMotionEffect(MainViewController.motionEffects)
		}
	}
	// MARK: Convenience

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
