//
//  SettingsTableViewController.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 14/10/2017.
//  Copyright © 2017 Daniel Illescas Romero. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
	
	private class cellLabelsForSection0 {
		
		static let backgroundMusic = Localized.Settings_Options_Music
		static let hapticFeedback = Localized.Settings_Options_HapticFeedback
		static let parallaxEffect = Localized.Settings_Options_ParallaxEffect
		static let darkTheme = Localized.Settings_Options_DarkTheme
		static let licenses = Localized.Settings_Options_Licenses
		
		static let labels: [String] = [cellLabelsForSection0.backgroundMusic, cellLabelsForSection0.hapticFeedback, cellLabelsForSection0.parallaxEffect, cellLabelsForSection0.darkTheme, cellLabelsForSection0.licenses]
		static let count = labels.count
	}
	
	let backgroundMusicSwitch = UISwitch()
	let hapticFeedbackSwitch = UISwitch()
	let parallaxEffectSwitch = UISwitch()
	let darkThemeSwitch = UISwitch()
	
	var switches: [UISwitch] {
		return [backgroundMusicSwitch, hapticFeedbackSwitch, parallaxEffectSwitch, darkThemeSwitch]
	}
	
	private class cellLabelsForSection1 {
		
		static let resetProgress = Localized.Settings_Options_ResetProgress
		
		static let labels: [String] = [cellLabelsForSection1.resetProgress]
		static let count = labels.count
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.title = Localized.Settings_Title
		
		self.setUpSwitches()
		self.loadSwitchesStates()
		
		if UserDefaultsManager.darkThemeSwitchIsOn {
			self.loadCurrentTheme()
		}
		
		self.clearsSelectionOnViewWillAppear = true
    }
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		self.navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		if #available(iOS 11.0, *) {
			self.navigationController?.navigationBar.prefersLargeTitles = true
		}
		loadCurrentTheme()
		self.tableView.reloadData()
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
				self.resetProgressAlert(cellIndexpath: indexPath)
				if #available(iOS 10.0, *) {
					FeedbackGenerator.notificationOcurredOf(type: .warning)
				}
				self.viewWillAppear(false) // called so it clears the selection properly
			default: break
			}
		default: break
		}
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if #available(iOS 13, *) {
			return
		}
		switch indexPath.section {
		case 0: cell.textLabel?.textColor = .themeStyle(dark: .white, light: .black)
		case 1: cell.textLabel?.textColor = UIColor.themeStyle(dark: .lightRed, light: .alternativeRed)
		default: break
		}
		cell.backgroundColor = .themeStyle(dark: .veryDarkGray, light: .white)
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
		
		cell.textLabel?.font = .preferredFont(forTextStyle: .body)
		cell.accessoryView = nil

		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = cellLabelsForSection0.backgroundMusic
				cell.accessoryView = self.backgroundMusicSwitch
			case 1:
				cell.textLabel?.text = cellLabelsForSection0.hapticFeedback + "*"
				cell.accessoryView = self.hapticFeedbackSwitch
			case 2:
				cell.textLabel?.text = cellLabelsForSection0.darkTheme
				cell.accessoryView = self.darkThemeSwitch
				if #available(iOS 13, *) {
					self.darkThemeSwitch.isEnabled = false
				}
			case 3:
				cell.textLabel?.text = cellLabelsForSection0.parallaxEffect
				cell.accessoryView = self.parallaxEffectSwitch
			case 4:
				cell.textLabel?.text = cellLabelsForSection0.licenses
				cell.accessoryType = .disclosureIndicator
			default: break
			}
		case 1:
			switch indexPath.row {
			case 0: cell.textLabel?.text = cellLabelsForSection1.resetProgress
			default: break
			}
		default: break
		}
		
		if #available(iOS 13, *) {
			return cell
		}
		
		if UserDefaultsManager.darkThemeSwitchIsOn {
			let view = UIView()
			view.backgroundColor = .darkGray
			cell.selectedBackgroundView = view
		} else {
			cell.selectedBackgroundView = nil
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
		
		return """
		
		\(Localized.Settings_Statistics_Title):
		
		\(Localized.Settings_Statistics_CompletedSets): \(completedSets)
		\(Localized.Settings_Statistics_CorrectAnswers): \(correctAnswers)
		\(Localized.Settings_Statistics_IncorrectAnswers): \(incorrectAnswers)
		\(Localized.Settings_Statistics_Ratio): \(correctAnswersPercent)%
		
		\(Localized.Settings_Options_HapticFeedback_Info)
		"""
	}
	
	// UITableView delegate
	
	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		if #available(iOS 13, *) {
			return
		}
		let footer = view as? UITableViewHeaderFooterView
		footer?.textLabel?.textColor = .themeStyle(dark: .lightGray, light: .gray)
		if #available(iOS 13, *) {
			footer?.contentView.backgroundColor = .themeStyle(dark: .black, light: .systemGroupedBackground)
		} else {
			footer?.contentView.backgroundColor = .themeStyle(dark: .black, light: .groupTableViewBackground)
		}
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
		self.loadCurrentTheme()
	}

	// MARK: - Convenience

	private func setParallaxEffectSwitch() {
		let reduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
		let parallaxEffectEnabled = reduceMotionEnabled ? false : UserDefaultsManager.parallaxEffectSwitchIsOn
		parallaxEffectSwitch.setOn(parallaxEffectEnabled, animated: true)
		parallaxEffectSwitch.isEnabled = !reduceMotionEnabled
	}
	
	private func loadSwitchesStates() {
		self.setParallaxEffectSwitch()
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
	
		let switchTintColor = UIColor.themeStyle(dark: .warmColor, light: .coolBlue)
		self.switches.forEach { $0.onTintColor = switchTintColor; $0.dontInvertColors() }
	}
	
	private func resetProgressStatistics() {
		
		DataStoreArchiver.shared.completedSets.removeAll()
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
		
		
		let reduceMotion = UIAccessibility.isReduceMotionEnabled
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
		
		self.loadCurrentTheme()
	}
	
	private func loadCurrentTheme() {
		
		if #available(iOS 13, *) {
			let switchTintColor = UIColor.themeStyle(dark: .warmColor, light: .coolBlue)
			self.switches.forEach { $0.onTintColor = switchTintColor; $0.dontInvertColors() }
			return
		}
		
		self.navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		self.navigationController?.toolbar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		if #available(iOS 13, *) {
			self.navigationController?.toolbar.isTranslucent = true
		} else {
			self.navigationController?.toolbar.barStyle = UIBarStyle.themeStyle(dark: .blackTranslucent, light: .default)
		}
		
		self.navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		
		if #available(iOS 13.0, *) {
			self.tableView.backgroundColor = .themeStyle(dark: .black, light: .systemGroupedBackground)
		} else {
			self.tableView.backgroundColor = .themeStyle(dark: .black, light: .groupTableViewBackground)
		}
		self.tableView.separatorColor = .themeStyle(dark: .black, light: .defaultSeparatorColor)
		
		let switchTintColor = UIColor.themeStyle(dark: .warmColor, light: .coolBlue)
		self.switches.forEach { $0.onTintColor = switchTintColor; $0.dontInvertColors() }
		
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
		
		AppDelegate.windowReference?.dontInvertIfDarkModeIsEnabled()
	}
	
	private func resetProgressAlert(cellIndexpath: IndexPath) {
		
		let alertViewController = UIAlertController(title: Localized.Settings_Alerts_ResetProgress_Title, message: nil, preferredStyle: .actionSheet)
		
		alertViewController.addAction(title: Localized.Common_Cancel, style: .cancel)
		alertViewController.addAction(title: Localized.Settings_Alerts_ResetProgress_Everything, style: .destructive) { action in
			self.resetProgressOptions()
		}
		alertViewController.addAction(title: Localized.Settings_Alerts_ResetProgress_OnlyStatistics, style: .default) { action in
			self.resetProgressStatistics()
		}
		
		alertViewController.popoverPresentationController?.sourceView = self.tableView
		alertViewController.popoverPresentationController?.sourceRect = self.tableView.rectForRow(at: cellIndexpath)
		
		self.present(alertViewController, animated: true)
	}
}
