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
		case parallaxEffect = "Parallax Effect"
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
		
		case resetGame = "Reset Game"
		
		static let labels: [cellLabelsForSection1] = [.resetGame]
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
				
				alertViewController.popoverPresentationController?.sourceRect = tableView.cellForRow(at: indexPath)!.frame
				alertViewController.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
				
				present(alertViewController, animated: true)
			default: break
			}
		default: break
		}
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
		
		cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)

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
			case 0: cell.textLabel?.text = cellLabelsForSection1.resetGame.rawValue.localized
			default: break
			}
		default: break
		}

        return cell
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

	// MARK: - Actions
	
	@IBAction func backgroundMusicSwitchAction(sender: UISwitch) {
		if sender.isOn { Audio.bgMusic?.play() }
		else { Audio.bgMusic?.pause() }
		
		Settings.shared.musicEnabled = sender.isOn
	}
	
	@IBAction func hapticFeedbackSwitchAction(sender: UISwitch) {
		if #available(iOS 10.0, *), traitCollection.forceTouchCapability == .available {
			Settings.shared.hapticFeedbackEnabled = sender.isOn
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
		
		Settings.shared.parallaxEnabled = sender.isOn
	}
	
	@IBAction func darkThemeSwitchAction(sender: UISwitch) {
		Settings.shared.darkThemeEnabled = sender.isOn
		self.loadCurrentTheme(animated: true)
		AppDelegate.updateVolumeBarTheme()
	}

	// MARK: - Convenience
	
	@IBAction internal func loadTheme() {
		darkThemeSwitch.setOn(Settings.shared.darkThemeEnabled, animated: false)
		loadCurrentTheme(animated: false)
	}
	
	@IBAction internal func setParallaxEffectSwitch() {
		let reduceMotionEnabled = UIAccessibilityIsReduceMotionEnabled()
		let parallaxEffectEnabled = reduceMotionEnabled ? false : Settings.shared.parallaxEnabled
		parallaxEffectSwitch.setOn(parallaxEffectEnabled, animated: true)
		parallaxEffectSwitch.isEnabled = !reduceMotionEnabled
	}
	
	private func loadSwitchesStates() {
		setParallaxEffectSwitch()
		backgroundMusicSwitch.setOn(Audio.bgMusic?.isPlaying ?? false, animated: true)
		darkThemeSwitch.setOn(Settings.shared.darkThemeEnabled, animated: true)
		
		if #available(iOS 10.0, *), traitCollection.forceTouchCapability == .available  {
			hapticFeedbackSwitch.setOn(Settings.shared.hapticFeedbackEnabled, animated: true)
		} else {
			hapticFeedbackSwitch.setOn(false, animated: false)
			hapticFeedbackSwitch.isEnabled = false
			Settings.shared.hapticFeedbackEnabled = false
		}
	}
	
	private func setUpSwitches() {
		self.backgroundMusicSwitch.addTarget(self, action: #selector(backgroundMusicSwitchAction(sender:)), for: .touchUpInside)
		self.hapticFeedbackSwitch.addTarget(self, action: #selector(hapticFeedbackSwitchAction(sender:)), for: .touchUpInside)
		self.parallaxEffectSwitch.addTarget(self, action: #selector(parallaxEffectSwitchAction(sender:)), for: .touchUpInside)
		self.darkThemeSwitch.addTarget(self, action: #selector(darkThemeSwitchAction(sender:)), for: .touchUpInside)
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
		
		self.tableView.reloadData()
	}
	
	private func resetGameOptions() {
		
		self.resetGameStatistics()
		
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
		backgroundMusicSwitch.setOn(true, animated: true)
		
		if #available(iOS 10.0, *) {
			hapticFeedbackSwitch.setOn(true, animated: true)
		} else {
			hapticFeedbackSwitch.setOn(false, animated: false)
			hapticFeedbackSwitch.isEnabled = false
			Settings.shared.hapticFeedbackEnabled = false
		}
		
		Audio.bgMusic?.play()
		
		self.loadCurrentTheme(animated: true)
	}
	
	private func loadCurrentTheme(animated: Bool) {
		
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
			
			self.tableView.backgroundColor = .themeStyle(dark: .veryVeryDarkGray, light: .groupTableViewBackground)
			self.tableView.separatorColor = .themeStyle(dark: .veryVeryDarkGray, light: .defaultSeparatorColor)
			
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
}
