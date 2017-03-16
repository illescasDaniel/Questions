import UIKit

class SettingsViewController: UITableViewController {

	// MARK: Properties

	@IBOutlet weak var bgMusicLabel: UILabel!
	@IBOutlet weak var parallaxEffectLabel: UILabel!
	@IBOutlet weak var darkThemeLabel: UILabel!
	@IBOutlet weak var resetGameButton: UIButton!
	@IBOutlet weak var licensesButton: UIButton!
	var optionsLabels: [UILabel]!
	
	@IBOutlet weak var settingsNavItem: UINavigationItem!
	@IBOutlet weak var bgMusicSwitch: UISwitch!
	@IBOutlet weak var parallaxEffectSwitch: UISwitch!
	@IBOutlet weak var darkThemeSwitch: UISwitch!
	@IBOutlet weak var licensesCell: UITableViewCell!
	
	// MARK: View life cycle

	override func viewDidLoad() {
		super.viewDidLoad()
	
		settingsNavItem.title = "Settings".localized
		
		bgMusicLabel.text = "Background music".localized
		parallaxEffectLabel.text = "Parallax effect".localized
		darkThemeLabel.text = "Dark theme".localized
		resetGameButton.setTitle("Reset game".localized, for: .normal)
		licensesButton.setTitle("Licenses".localized, for: .normal)
		licensesCell.accessoryType = .disclosureIndicator
		
		optionsLabels = [bgMusicLabel, parallaxEffectLabel, darkThemeLabel, resetGameButton.titleLabel ?? UILabel(), licensesButton.titleLabel ?? UILabel()]

		parallaxEffectSwitch.setOn(Settings.sharedInstance.parallaxEnabled, animated: true)
		
		bgMusicSwitch.setOn(Audio.bgMusic?.isPlaying ?? false, animated: true)
		darkThemeSwitch.setOn(Settings.sharedInstance.darkThemeEnabled, animated: true)
		
		loadCurrentTheme(animated: false)
	}

	// MARK: UITableViewDataSouce

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return optionsLabels.count
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		
		var completedSets = UInt()
		
		for i in 0..<Quiz.quizzes.count {
			
			if let completedSet = Settings.sharedInstance.completedSets[i] {
				for j in 0..<completedSet.count {
					if completedSet[j] { completedSets += 1 }
				}
			}
		}
		
		return "\n\("Statistics".localized): \n\n" +
			"\("Completed sets".localized): \(completedSets)\n" +
			"\("Correct answers".localized): \(Settings.sharedInstance.correctAnswers)\n" +
			"\("Incorrect answers".localized): \(Settings.sharedInstance.incorrectAnswers)\n"
	}
	
	// MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		
		let footer = view as? UITableViewHeaderFooterView
		footer?.textLabel?.textColor = darkThemeSwitch.isOn ? .lightGray : .gray
		footer?.backgroundView?.backgroundColor = darkThemeSwitch.isOn ? .darkGray : .defaultBGcolor
	}
	
	// MARK: Alerts

	@IBAction func resetGameAlert() {
		
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

		if bgMusicSwitch.isOn { Audio.bgMusic?.play() }
		else { Audio.bgMusic?.pause() }
		
		Settings.sharedInstance.musicEnabled = bgMusicSwitch.isOn
	}

	@IBAction func switchParallaxEffect() {

		if parallaxEffectSwitch.isOn {
			MainViewController.addParallax(toView: MainViewController.backgroundView)
		}
		else {
			let effects = MainViewController.parallaxEffect
			MainViewController.backgroundView?.removeMotionEffect(effects)
		}
		
		Settings.sharedInstance.parallaxEnabled = parallaxEffectSwitch.isOn
	}

	@IBAction func switchTheme() {
		Settings.sharedInstance.darkThemeEnabled = darkThemeSwitch.isOn
		loadCurrentTheme(animated: true)
	}
	
	// MARK: Convenience
	
	func loadCurrentTheme(animated: Bool) {
		
		let duration: TimeInterval = animated ? 0.35 : 0
		UIView.animate(withDuration: duration) {
			
			self.navigationController?.navigationBar.barStyle = self.darkThemeSwitch.isOn ? .black : .default
			self.navigationController?.navigationBar.tintColor = self.darkThemeSwitch.isOn ? .orange : .defaultTintColor
			
			self.tableView.backgroundColor = self.darkThemeSwitch.isOn ? .darkGray : .defaultBGcolor
			self.tableView.separatorColor = self.darkThemeSwitch.isOn ? .darkGray : .defaultSeparatorColor
			
			self.resetGameButton.setTitleColor(self.darkThemeSwitch.isOn ? .white : .black, for: .normal)
			self.licensesButton.setTitleColor(self.darkThemeSwitch.isOn ? .white : .black, for: .normal)
			
			self.bgMusicSwitch.onTintColor = self.darkThemeSwitch.isOn ? .warmColor : .coolBlue
			self.parallaxEffectSwitch.onTintColor = self.darkThemeSwitch.isOn ? .warmColor : .coolBlue
			self.darkThemeSwitch.onTintColor = self.darkThemeSwitch.isOn ? .warmColor : .coolBlue
			
			self.tableView.reloadData()
			
			for i in 0..<self.optionsLabels.count {
				self.optionsLabels[i].textColor = self.darkThemeSwitch.isOn ? .white : .black
				self.tableView.visibleCells[i].backgroundColor = self.darkThemeSwitch.isOn ? .gray : .white
			}
		}
	}
	
	func resetGameStatistics() {
		
		for i in 0..<Quiz.quizzes.count {
			
			if let completedSet = Settings.sharedInstance.completedSets[i] {
				for j in 0..<completedSet.count {
					Settings.sharedInstance.completedSets[i]?[j] = false
				}
			}
		}
			
		Settings.sharedInstance.correctAnswers = 0
		Settings.sharedInstance.incorrectAnswers = 0
		Settings.sharedInstance.score = 0

		tableView.reloadData()
	}

	func resetGameOptions() {
		
		resetGameStatistics()
		
		if !Settings.sharedInstance.parallaxEnabled {
			MainViewController.addParallax(toView: MainViewController.backgroundView)
			Settings.sharedInstance.parallaxEnabled = true
		}
		
		Settings.sharedInstance.musicEnabled = true
		Settings.sharedInstance.darkThemeEnabled = false
		
		parallaxEffectSwitch.setOn(true, animated: true)
		darkThemeSwitch.setOn(false, animated: true)
		bgMusicSwitch.setOn(true, animated: true)
		
		Audio.bgMusic?.play()
		
		loadCurrentTheme(animated: true)
	}
}
