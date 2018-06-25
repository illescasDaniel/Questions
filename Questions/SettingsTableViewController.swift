//
//  SettingsTableViewController.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 14/10/2017.
//  Copyright © 2017 Daniel Illescas Romero. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
	
	private enum cellLabelsForSection0: String {
		
		case backgroundMusic = "Background Music"
		case hapticFeedback = "Haptic Feedback"
		case parallaxEffect = "Parallax effect"
		case darkTheme = "Dark Theme"
		case licenses = "Licenses"
		
		static let labels: [cellLabelsForSection0] = [.backgroundMusic, .hapticFeedback, .parallaxEffect, .darkTheme, .licenses]
		static let count = labels.count
	}
	
	let backgroundMusicSwitch = UISwitch()
	let hapticFeedbackSwitch = UISwitch()
	let parallaxEffectSwitch = UISwitch()
	let darkThemeSwitch = UISwitch()
	
	var switches: [UISwitch] {
		return [backgroundMusicSwitch, hapticFeedbackSwitch, parallaxEffectSwitch, darkThemeSwitch]
	}
	
	private enum cellLabelsForSection1: String {
		
		case resetProgress = "Reset progress"
		case resetCachedImages = "Clear cached images"
		
		static let labels: [cellLabelsForSection1] = [.resetProgress, .resetCachedImages]
		static let count = labels.count
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.setUpSwitches()
		self.loadSwitchesStates()
		self.loadCurrentTheme(animated: false)

		// If user enables Reduce Motion setting, the parallax effect switch updates its value
		NotificationCenter.default.addObserver(self, selector: #selector(self.setParallaxEffectSwitch), name: .UIAccessibilityReduceMotionStatusDidChange, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.loadTheme), name: .UIApplicationDidBecomeActive, object: nil)
    }
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? cellLabelsForSection0.count : cellLabelsForSection1.count
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 4:
				DispatchQueue.main.async {
					self.performSegue(withIdentifier: "segueToLicenses", sender: nil)
				}
			default: break
			}
		case 1:
			switch indexPath.row {
			case 0:
				self.resetProgressAlert()
				FeedbackGenerator.notificationOcurredOf(type: .warning)
			case 1:
				self.resetCachedImages()
				FeedbackGenerator.notificationOcurredOf(type: .warning)
			default: break
			}
		default: break
		}
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
		
		cell.textLabel?.font = .preferredFont(forTextStyle: .body)
		cell.accessoryView = nil

		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = cellLabelsForSection0.backgroundMusic.rawValue.localized
				cell.accessoryView = backgroundMusicSwitch
			case 1:
				cell.textLabel?.text = cellLabelsForSection0.hapticFeedback.rawValue.localized
				cell.accessoryView = hapticFeedbackSwitch
			case 2:
				cell.textLabel?.text = cellLabelsForSection0.darkTheme.rawValue.localized
				cell.accessoryView = darkThemeSwitch
			case 3:
				cell.textLabel?.text = cellLabelsForSection0.parallaxEffect.rawValue.localized
				cell.accessoryView = parallaxEffectSwitch
			case 4:
				cell.textLabel?.text = cellLabelsForSection0.licenses.rawValue.localized
				cell.accessoryType = .disclosureIndicator
			default: break
			}
		case 1:
			switch indexPath.row {
			case 0: cell.textLabel?.text = cellLabelsForSection1.resetProgress.rawValue.localized
			case 1: cell.textLabel?.text = cellLabelsForSection1.resetCachedImages.rawValue.localized
			default: break
			}
		default: break
		}

        return cell
    }
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		
		guard section == 0 else { return nil }
		
		var completedSets = UInt()

		for topicQuiz in DataStoreArchiver.shared.completedSets {
			for setQuiz in topicQuiz.value where setQuiz.value == true {
				completedSets += 1
			}
		}
		
		let correctAnswers = UserDefaultsManager.correctAnswers
		let incorrectAnswers = UserDefaultsManager.incorrectAnswers
		let numberOfAnswers = Float(incorrectAnswers + correctAnswers)
		let correctAnswersPercent = (numberOfAnswers > 0) ? Int(round((Float(correctAnswers) / numberOfAnswers) * 100.0)) : 0
		
		return "\n\("Statistics".localized): \n\n" +
			"\("Completed sets".localized): \(completedSets)\n" +
			"\("Correct answers".localized): \(correctAnswers)\n" +
			"\("Incorrect answers".localized): \(incorrectAnswers)\n" +
			"\("Ratio".localized): \(correctAnswersPercent)%\n\n" +
			"*Only available on certain devices.".localized + "\n"
	}
	
	// UITableView delegate
	
	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		
		let cellColor: UIColor = .themeStyle(dark: .darkGray, light: .highlighedGray)
		let cell = tableView.cellForRow(at: indexPath)
		let view = UIView()
		
		UIView.animate(withDuration: 0.15) {
			cell?.backgroundColor = cellColor
			view.backgroundColor = cellColor
			cell?.selectedBackgroundView = view
		}
	}
	
	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)
		UIView.animate(withDuration: 0.15) {
			cell?.backgroundColor = .themeStyle(dark: .veryDarkGray, light: .white)
		}
	}
	
	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		let footer = view as? UITableViewHeaderFooterView
		footer?.textLabel?.textColor = .themeStyle(dark: .lightGray, light: .gray)
		footer?.contentView.backgroundColor = .themeStyle(dark: .black, light: .groupTableViewBackground)
	}
	
	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return tableView.cellForRow(at: indexPath)?.accessoryView == nil
	}

	// MARK: - Actions
	
	@IBAction func backgroundMusicSwitchAction(sender: UISwitch) {
		if sender.isOn { AudioSounds.bgMusic?.play() }
		else { AudioSounds.bgMusic?.pause() }
		
		UserDefaultsManager.backgroundMusicSwitchIsOn = sender.isOn
	}
	
	@IBAction func hapticFeedbackSwitchAction(sender: UISwitch) {
		if #available(iOS 10.0, *), traitCollection.forceTouchCapability == .available {
			UserDefaultsManager.hapticFeedbackSwitchIsOn = sender.isOn
		}
	}
	
	@IBAction func parallaxEffectSwitchAction(sender: UISwitch) {
		if sender.isOn {
			MainViewController.addParallax(toView: MainViewController.backgroundView)
		}
		else {
			let effects = MainViewController.parallaxEffect
			MainViewController.backgroundView?.removeMotionEffect(effects)
		}
		
		UserDefaultsManager.parallaxEffectSwitchIsOn = sender.isOn
	}
	
	@IBAction func darkThemeSwitchAction(sender: UISwitch) {
		UserDefaultsManager.darkThemeSwitchIsOn = sender.isOn
		self.loadCurrentTheme(animated: true)
		AppDelegate.updateVolumeBarTheme()
	}

	// MARK: - Convenience
	
	@objc internal func loadTheme() {
		darkThemeSwitch.setOn(UserDefaultsManager.darkThemeSwitchIsOn, animated: false)
		loadCurrentTheme(animated: false)
	}
	
	@objc internal func setParallaxEffectSwitch() {
		let reduceMotionEnabled = UIAccessibilityIsReduceMotionEnabled()
		let parallaxEffectEnabled = reduceMotionEnabled ? false : UserDefaultsManager.parallaxEffectSwitchIsOn
		parallaxEffectSwitch.setOn(parallaxEffectEnabled, animated: true)
		parallaxEffectSwitch.isEnabled = !reduceMotionEnabled
	}
	
	private func loadSwitchesStates() {
		setParallaxEffectSwitch()
		backgroundMusicSwitch.setOn(AudioSounds.bgMusic?.isPlaying ?? false, animated: true)
		darkThemeSwitch.setOn(UserDefaultsManager.darkThemeSwitchIsOn, animated: true)
		
		if #available(iOS 10.0, *), traitCollection.forceTouchCapability == .available  {
			hapticFeedbackSwitch.setOn(UserDefaultsManager.hapticFeedbackSwitchIsOn, animated: true)
		} else {
			hapticFeedbackSwitch.setOn(false, animated: false)
			hapticFeedbackSwitch.isEnabled = false
			UserDefaultsManager.hapticFeedbackSwitchIsOn = false
		}
	}
	
	private func setUpSwitches() {
		self.backgroundMusicSwitch.addTarget(self, action: #selector(backgroundMusicSwitchAction(sender:)), for: .touchUpInside)
		self.hapticFeedbackSwitch.addTarget(self, action: #selector(hapticFeedbackSwitchAction(sender:)), for: .touchUpInside)
		self.parallaxEffectSwitch.addTarget(self, action: #selector(parallaxEffectSwitchAction(sender:)), for: .touchUpInside)
		self.darkThemeSwitch.addTarget(self, action: #selector(darkThemeSwitchAction(sender:)), for: .touchUpInside)
	}
	
	private func resetProgressStatistics() {
		
		DataStoreArchiver.shared.completedSets.removeAll()
		CachedImages.shared.clear()
		SetOfTopics.shared.loadAllTopicsStates()
		guard DataStoreArchiver.shared.save() else { print("Error saving settings"); return }
		
		UserDefaultsManager.correctAnswers = 0
		UserDefaultsManager.incorrectAnswers = 0
		UserDefaultsManager.score = 0
		
		self.tableView.reloadData()
	}
	
	private func resetProgressOptions() {
		
		self.resetProgressStatistics()
		
		if !UserDefaultsManager.parallaxEffectSwitchIsOn {
			MainViewController.addParallax(toView: MainViewController.backgroundView)
			UserDefaultsManager.parallaxEffectSwitchIsOn = true
		}
		
		UserDefaultsManager.backgroundMusicSwitchIsOn = true
		UserDefaultsManager.darkThemeSwitchIsOn = false
		UserDefaultsManager.hapticFeedbackSwitchIsOn = true
		
		
		let reduceMotion = UIAccessibilityIsReduceMotionEnabled()
		self.parallaxEffectSwitch.setOn(!reduceMotion, animated: true)
		self.parallaxEffectSwitch.isEnabled = !reduceMotion
		
		self.darkThemeSwitch.setOn(false, animated: true)
		self.backgroundMusicSwitch.setOn(true, animated: true)
		
		if #available(iOS 10.0, *) {
			self.hapticFeedbackSwitch.setOn(true, animated: true)
		} else {
			self.hapticFeedbackSwitch.setOn(false, animated: false)
			self.hapticFeedbackSwitch.isEnabled = false
			UserDefaultsManager.hapticFeedbackSwitchIsOn = false
		}
		
		AudioSounds.bgMusic?.play()
		
		self.loadCurrentTheme(animated: true)
	}
	
	private func loadCurrentTheme(animated: Bool) {
		
		self.navigationItem.title = "Settings".localized
		
		let duration: TimeInterval = animated ? 0.2 : 0
		
		if #available(iOS 10.0, *) {
			UIView.animate(withDuration: duration) {
				self.navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
			}
		}
		else { // On iOS 9, the barStyle animation is not very nice...
			navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		}
		
		UIView.transition(with: self.view, duration: duration, options: [.transitionCrossDissolve], animations: {
			self.navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
			
			self.tableView.backgroundColor = .themeStyle(dark: .black, light: .groupTableViewBackground)
			self.tableView.separatorColor = .themeStyle(dark: .black, light: .defaultSeparatorColor)
			
			let textLabelColor = UIColor.themeStyle(dark: .white, light: .black)
			let switchTintColor = UIColor.themeStyle(dark: .warmColor, light: .coolBlue)
			
			self.switches.forEach { $0.onTintColor = switchTintColor; $0.dontInvertColors() }
			
			self.tableView.reloadData()
			
			for i in 0..<cellLabelsForSection0.count {
				let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0))
				cell?.textLabel?.textColor = textLabelColor
				cell?.backgroundColor = .themeStyle(dark: .veryDarkGray, light: .white)
			}
			
			for i in 0..<cellLabelsForSection1.count {
				let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 1))
				cell?.textLabel?.textColor = textLabelColor
				cell?.backgroundColor = .themeStyle(dark: .veryDarkGray, light: .white)
			}
		})
	}
	
	private func resetProgressAlert() {
		
		let alertViewController = UIAlertController(title: "Reset progress".localized, message: nil, preferredStyle: .alert)
		
		alertViewController.addAction(title: "Cancel".localized, style: .cancel)
		alertViewController.addAction(title: "Everything".localized, style: .destructive) { action in
			self.resetProgressOptions()
		}
		alertViewController.addAction(title: "Only Statistics".localized, style: .default) { action in
			self.resetProgressStatistics()
		}

		self.present(alertViewController, animated: true)
	}
	
	private func resetCachedImages() {
		
		let alertViewController = UIAlertController(title: "Clear cached images".localized, message: nil, preferredStyle: .alert)
		alertViewController.addAction(title: "Cancel".localized, style: .cancel)
		alertViewController.addAction(title: "Reset".localized, style: .destructive) { action in
			CachedImages.shared.clear()
		}
		self.present(alertViewController, animated: true)
	}
}
