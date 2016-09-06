import UIKit

class SettingsViewController: UITableViewController {

	// MARK: Properties

	@IBOutlet weak var bgMusicLabel: UILabel!
	@IBOutlet weak var parallaxEffectLabel: UILabel!
	@IBOutlet weak var darkThemeLabel: UILabel!
	@IBOutlet weak var resetGameLabel: UILabel!
	
	var optionsLabels: [UILabel]!
	@IBOutlet weak var settingsNavItem: UINavigationItem!
	@IBOutlet weak var bgMusicSwitch: UISwitch!
	@IBOutlet weak var parallaxEffectSwitch: UISwitch!
	@IBOutlet weak var darkThemeSwitch: UISwitch!
	
	// MARK: View life cycle

	override func viewDidLoad() {
		super.viewDidLoad()
	
		settingsNavItem.title = "Settings".localized
		
		bgMusicLabel.text = "Background music".localized
		parallaxEffectLabel.text = "Parallax effect".localized
		darkThemeLabel.text = "Dark theme".localized
		resetGameLabel.text = "Reset game".localized
		resetGameLabel.font = UIFont.preferredFont(forTextStyle: .body)
		
		optionsLabels = [bgMusicLabel, parallaxEffectLabel, darkThemeLabel, resetGameLabel]

		if let motionEffects = MainViewController.backgroundView?.motionEffects {
			parallaxEffectSwitch.setOn(!motionEffects.isEmpty, animated: true)
		}
		bgMusicSwitch.setOn(MainViewController.bgMusic?.isPlaying ?? false, animated: true)
		darkThemeSwitch.setOn(Settings.sharedInstance.darkThemeEnabled, animated: true)
		
		tableView.reloadData()
		
		loadTheme()
	}

	// MARK: UITableViewDataSouce

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return optionsLabels.count
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		if tableView.cellForRow(at: indexPath)?.textLabel?.text == "Reset game".localized {
			resetGameAlert()
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		
		var completedSets = UInt()
		Settings.sharedInstance.completedSets.forEach { if $0 { completedSets += 1 } }
		
		return "\n\("Statistics".localized): \n\n" +
			"\("Correct answers".localized): \(Settings.sharedInstance.correctAnswers)\n" +
			"\("Incorrect answers".localized): \(Settings.sharedInstance.incorrectAnswers)\n" +
			"\("Completed sets".localized): \(completedSets)"
	}
	
	// MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		
		let footer = view as! UITableViewHeaderFooterView
		footer.textLabel?.textColor = darkThemeSwitch.isOn ? UIColor.lightGray : UIColor.gray
		footer.backgroundView?.backgroundColor = darkThemeSwitch.isOn ? UIColor.darkGray : UIColor.defaultBGcolor
	}
	
	// MARK: Alerts

	func resetGameAlert() {
		
		let alertViewController = UIAlertController(title: "",
													message: "What do you want to reset?".localized,
													preferredStyle: .actionSheet)
		
		let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
		let everythingAction = UIAlertAction(title: "Everything".localized, style: .destructive) { action in self.resetGameOptions() }
		let statisticsAction = UIAlertAction(title: "Only statistics".localized, style: .default) {	action in self.resetGameStatistics() }
		
		alertViewController.addAction(cancelAction)
		alertViewController.addAction(everythingAction)
		alertViewController.addAction(statisticsAction)
		
		present(alertViewController, animated: true, completion: nil)
	}

	// MARK: IBActions

	@IBAction func switchBGMusic() {

		if bgMusicSwitch.isOn {
			Settings.sharedInstance.musicEnabled = true
			MainViewController.bgMusic?.play()
		}
		else {
			Settings.sharedInstance.musicEnabled = false
			MainViewController.bgMusic?.pause()
		}
	}

	@IBAction func switchParallaxEffect() {

		if parallaxEffectSwitch.isOn {
			MainViewController.addParallax(toView: MainViewController.backgroundView)
		}
		else if let effects = MainViewController.motionEffects {
			MainViewController.backgroundView?.removeMotionEffect(effects)
		}
	}

	@IBAction func switchTheme() {
		Settings.sharedInstance.darkThemeEnabled = darkThemeSwitch.isOn
		loadTheme()
		viewDidLoad()
	}
	
	// MARK: Convenience
	
	func loadTheme() {
		
		navigationController?.navigationBar.barStyle = darkThemeSwitch.isOn ? UIBarStyle.black : UIBarStyle.default
		navigationController?.navigationBar.tintColor = darkThemeSwitch.isOn ? UIColor.orange : UIColor.defaultTintColor
		
		tableView.backgroundColor = darkThemeSwitch.isOn ? UIColor.darkGray : UIColor.defaultBGcolor
		tableView.separatorColor = darkThemeSwitch.isOn ? UIColor.darkGray : UIColor.defaultSeparatorColor
		
		for i in 0..<optionsLabels.count {
			optionsLabels[i].textColor = darkThemeSwitch.isOn ? UIColor.white : UIColor.black
			tableView.visibleCells[i].backgroundColor = darkThemeSwitch.isOn ? UIColor.gray : UIColor.white
		}
	}
	
	func resetGameStatistics() {
		
		Settings.sharedInstance.completedSets = [Bool](repeating: false, count: Quiz.set.count)
		Settings.sharedInstance.correctAnswers = 0
		Settings.sharedInstance.incorrectAnswers = 0

		tableView.reloadData()
	}

	func resetGameOptions() {
		
		resetGameStatistics()
		Settings.sharedInstance.musicEnabled = true
		MainViewController.bgMusic?.play()
		bgMusicSwitch.setOn(true, animated: true)
		
		if !parallaxEffectSwitch.isOn {
			MainViewController.addParallax(toView: MainViewController.backgroundView)
		}
		
		parallaxEffectSwitch.setOn(true, animated: true)
		darkThemeSwitch.setOn(false, animated: true)
		Settings.sharedInstance.darkThemeEnabled = false
		
		viewDidLoad()
	}
}
