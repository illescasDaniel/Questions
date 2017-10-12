import UIKit

class SettingsViewController: UITableViewController {

	// MARK: Properties

	@IBOutlet weak var bgMusicLabel: UILabel!
	@IBOutlet weak var hapticFeedbackLabel: UILabel!
	@IBOutlet weak var parallaxEffectLabel: UILabel!
	@IBOutlet weak var licensesLabel: UILabel!
	@IBOutlet weak var darkThemeLabel: UILabel!
	@IBOutlet weak var resetGameButton: UIButton!
	var optionLabels: [UILabel]!

	var optionSwitches: [UISwitch]!
	@IBOutlet weak var settingsNavItem: UINavigationItem!
	@IBOutlet weak var bgMusicSwitch: UISwitch!
	@IBOutlet weak var hapticFeedbackSwitch: UISwitch!
	@IBOutlet weak var parallaxEffectSwitch: UISwitch!
	@IBOutlet weak var darkThemeSwitch: UISwitch!
	@IBOutlet weak var licensesCell: UITableViewCell!
	
	// MARK: View life cycle

	override func viewDidLoad() {
		super.viewDidLoad()
	
		self.initializeLabelNames()
		self.licensesCell.accessoryType = .disclosureIndicator
		
		self.optionLabels = [self.bgMusicLabel, self.hapticFeedbackLabel, self.parallaxEffectLabel, self.darkThemeLabel, self.licensesLabel,
						self.resetGameButton.titleLabel ?? UILabel()]
		
		self.optionSwitches = [self.bgMusicSwitch, self.hapticFeedbackSwitch, self.parallaxEffectSwitch, self.darkThemeSwitch]
		
		// If user enables Reduce Motion setting, the parallax effect switch updates its value
		NotificationCenter.default.addObserver(self, selector: #selector(self.setParallaxEffectSwitch), name: .UIAccessibilityReduceMotionStatusDidChange, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.loadTheme), name: .UIApplicationDidBecomeActive, object: nil)
		
		self.setSwitchesToDefaultValue()
		self.loadCurrentTheme(animated: false)
	}

	@available(iOS, deprecated: 9.0)
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: UITableViewDataSouce

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return optionLabels.count
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		
		var completedSets = UInt()
		
		for i in 0..<Quiz.quizzes.count {
			if let completedSet = Settings.shared.completedSets[i] {
				completedSet.forEach { if $0 { completedSets += 1 } }
			}
		}
		
		let correctAnswers = Settings.shared.correctAnswers
		let incorrectAnswers = Settings.shared.incorrectAnswers
		let numberOfAnswers = Float(incorrectAnswers + correctAnswers)
		let ratio = round(100 * Float(correctAnswers) / ((numberOfAnswers > 0) ? numberOfAnswers : 1.0)) / 100
		
		return "\n\("Statistics".localized): \n\n" +
			"\("Completed sets".localized): \(completedSets)\n" +
			"\("Correct answers".localized): \(correctAnswers)\n" +
			"\("Incorrect answers".localized): \(incorrectAnswers)\n" +
			"\("Ratio".localized): \(ratio)\n\n" +
			"*Only available on certain devices.".localized + "\n"
	}
	
	// MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if optionLabels[indexPath.row].text == "Licenses".localized {
			performSegue(withIdentifier: "unwindToLicenses", sender: self)
		}
	}
	
	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		let footer = view as? UITableViewHeaderFooterView
		footer?.textLabel?.textColor = .themeStyle(dark: .lightGray, light: .gray)
		footer?.contentView.backgroundColor = .themeStyle(dark: .darkGray, light: .groupTableViewBackground)
	}
	
	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		
		let cell = tableView.cellForRow(at: indexPath)
			
		let cellColor: UIColor = .themeStyle(dark: .lightGray, light: .highlighedGray)
		cell?.backgroundColor = cellColor
		
		let view = UIView()
		view.backgroundColor = cellColor
		cell?.selectedBackgroundView = view
	}
	
	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)
		cell?.backgroundColor = .themeStyle(dark: .gray, light: .white)
	}
	
	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return indexPath.row >= optionSwitches.count
	}
	
	// MARK: Alerts

	@IBAction func resetGameAlert(_ sender: UIButton) {
		let alertViewController = UIAlertController(title: "", message: "What do you want to reset?".localized,
		                                            preferredStyle: .actionSheet)
		
		alertViewController.modalPresentationStyle = .popover
		
		alertViewController.addAction(title: "Cancel".localized, style: .cancel)
		alertViewController.addAction(title: "Everything".localized, style: .destructive) { action in
			self.resetGameOptions()
		}
		alertViewController.addAction(title: "Only Statistics", style: .default) { action in
			self.resetGameStatistics()
		}
		
		alertViewController.popoverPresentationController?.sourceRect = sender.frame
		alertViewController.popoverPresentationController?.sourceView = sender
		
		present(alertViewController, animated: true)
	}

	// MARK: IBActions

	@IBAction func switchBGMusic() {

		if bgMusicSwitch.isOn { Audio.bgMusic?.play() }
		else { Audio.bgMusic?.pause() }
		
		Settings.shared.musicEnabled = bgMusicSwitch.isOn
	}
	
	@IBAction func switchHapticFeedback() {
		if #available(iOS 10.0, *), traitCollection.forceTouchCapability == .available {
			Settings.shared.hapticFeedbackEnabled = hapticFeedbackSwitch.isOn
		}
	}

	@IBAction func switchParallaxEffect() {

		if parallaxEffectSwitch.isOn {
			MainViewController.addParallax(toView: MainViewController.backgroundView)
		}
		else {
			let effects = MainViewController.parallaxEffect
			MainViewController.backgroundView?.removeMotionEffect(effects)
		}
		
		Settings.shared.parallaxEnabled = parallaxEffectSwitch.isOn
	}

	@IBAction func switchTheme() {
		Settings.shared.darkThemeEnabled = darkThemeSwitch.isOn
		loadCurrentTheme(animated: true)
		AppDelegate.updateVolumeBarTheme()
		AppDelegate.windowReference?.dontInvertIfDarkModeIsEnabled()
	}
	
	// MARK: Convenience
	
	@objc func setParallaxEffectSwitch() {
		let reduceMotionEnabled = UIAccessibilityIsReduceMotionEnabled()
		let parallaxEffectEnabled = reduceMotionEnabled ? false : Settings.shared.parallaxEnabled
		parallaxEffectSwitch.setOn(parallaxEffectEnabled, animated: true)
		parallaxEffectSwitch.isEnabled = !reduceMotionEnabled
	}
	
	private func setSwitchesToDefaultValue() {
		
		setParallaxEffectSwitch()
		bgMusicSwitch.setOn(Audio.bgMusic?.isPlaying ?? false, animated: true)
		darkThemeSwitch.setOn(Settings.shared.darkThemeEnabled, animated: true)
		
		if #available(iOS 10.0, *), traitCollection.forceTouchCapability == .available  {
			hapticFeedbackSwitch.setOn(Settings.shared.hapticFeedbackEnabled, animated: true)
		} else {
			hapticFeedbackSwitch.setOn(false, animated: false)
			hapticFeedbackSwitch.isEnabled = false
			Settings.shared.hapticFeedbackEnabled = false
		}
	}
	
	private func initializeLabelNames() {
		settingsNavItem.title = "Settings".localized
		bgMusicLabel.text = "Background music".localized
		hapticFeedbackLabel.text = "Haptic Feedback".localized + "*"
		parallaxEffectLabel.text = "Parallax effect".localized
		darkThemeLabel.text = "Dark theme".localized
		resetGameButton.setTitle("Reset game".localized, for: .normal)
		licensesLabel.text = "Licenses".localized
	}
	
	@objc func loadTheme() {
		darkThemeSwitch.setOn(Settings.shared.darkThemeEnabled, animated: false)
		loadCurrentTheme(animated: false)
	}
	
	private func loadCurrentTheme(animated: Bool) {
		
		let duration: TimeInterval = animated ? 0.3 : 0
		
		if #available(iOS 10.0, *) {
			UIView.animate(withDuration: duration) {
				self.navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
			}
		}
		else { // On iOS 9, the barStyle animation is not very nice...
			navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		}
		
		UIView.animate(withDuration: duration) {
			
			self.navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
			
			self.tableView.backgroundColor = .themeStyle(dark: .darkGray, light: .groupTableViewBackground)
			self.tableView.separatorColor = .themeStyle(dark: .darkGray, light: .defaultSeparatorColor)
			
			let textLabelColor = UIColor.themeStyle(dark: .white, light: .black)
			self.resetGameButton.setTitleColor(textLabelColor, for: .normal)
			
			let switchTintColor = UIColor.themeStyle(dark: .warmColor, light: .coolBlue)
			self.optionSwitches.forEach { $0.onTintColor = switchTintColor; $0.dontInvertColors() }
			
			self.tableView.reloadData()
			
			for i in 0..<self.optionLabels.count {
				self.optionLabels[i].textColor = textLabelColor
				self.tableView.visibleCells[i].backgroundColor = .themeStyle(dark: .gray, light: .white)
			}
		}	
	}
	
	private func resetGameStatistics() {
		
		for i in 0..<Quiz.quizzes.count {
			
			if let completedSet = Settings.shared.completedSets[i] {
				for j in 0..<completedSet.count {
					Settings.shared.completedSets[i]?[j] = false
				}
			}
		}
			
		Settings.shared.correctAnswers = 0
		Settings.shared.incorrectAnswers = 0
		Settings.shared.score = 0

		tableView.reloadData()
	}

	private func resetGameOptions() {
		
		resetGameStatistics()
		
		if !Settings.shared.parallaxEnabled {
			MainViewController.addParallax(toView: MainViewController.backgroundView)
			Settings.shared.parallaxEnabled = true
		}
		
		Settings.shared.musicEnabled = true
		Settings.shared.darkThemeEnabled = false
		Settings.shared.hapticFeedbackEnabled = true
		
		
		let reduceMotion = UIAccessibilityIsReduceMotionEnabled()
		parallaxEffectSwitch.setOn(!reduceMotion, animated: true)
		parallaxEffectSwitch.isEnabled = !reduceMotion
		
		darkThemeSwitch.setOn(false, animated: true)
		bgMusicSwitch.setOn(true, animated: true)
		
		if #available(iOS 10.0, *) {
			hapticFeedbackSwitch.setOn(true, animated: true)
		} else {
			hapticFeedbackSwitch.setOn(false, animated: false)
			hapticFeedbackSwitch.isEnabled = false
			Settings.shared.hapticFeedbackEnabled = false
		}
		
		Audio.bgMusic?.play()
		
		loadCurrentTheme(animated: true)
	}
}

