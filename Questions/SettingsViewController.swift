import UIKit

class SettingsViewController: UITableViewController, UIAlertViewDelegate {

	// MARK: Properties

	@IBOutlet var optionsLabels: [UILabel]!
	@IBOutlet weak var settingsTableView: UITableView!
	@IBOutlet weak var settingsNavItem: UINavigationItem!
	@IBOutlet weak var bgMusicSwitch: UISwitch!
	@IBOutlet weak var parallaxEffectSwitch: UISwitch!

	// MARK: View life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		settingsNavItem.title = "Settings".localized

		let options = ["Background music".localized, "Parallax effect".localized, "Reset game".localized]

		for i in 0..<optionsLabels.count {
			optionsLabels[i].text = options[i]
		}

		// Value for the switch would be false if the music couldn't load
		bgMusicSwitch.setOn(MainViewController.bgMusic?.isPlaying ?? false, animated: true)
		parallaxEffectSwitch.setOn(!MainViewController.backgroundView.motionEffects.isEmpty, animated: true)
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

	// MARK: Alerts

	func resetGameAlert() {
		let alertViewController = UIAlertController(title: "",
													message: "What do you want to reset?".localized,
													preferredStyle: .actionSheet)

		let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { action in }
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
		else {
			MainViewController.backgroundView.removeMotionEffect(MainViewController.motionEffects)
		}
	}

	// MARK: Convenience

	func resetGameStatistics() {
		Settings.sharedInstance.completedSets = [Bool](repeating: false, count: Quiz.set.count)
		Settings.sharedInstance.correctAnswers = 0
		Settings.sharedInstance.incorrectAnswers = 0

		self.settingsTableView.reloadData()
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
	}
}
