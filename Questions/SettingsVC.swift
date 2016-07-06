//
//  SettingsVC.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 06/07/16.
//  Copyright © 2016 Daniel Illescas Romero. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {

	@IBOutlet weak var settingsNavItem: UINavigationItem!
	@IBOutlet weak var bgMusicLabel: UILabel!
	@IBOutlet weak var bgMusicSwitch: UISwitch!
	@IBOutlet weak var languageLabel: UILabel!
	@IBOutlet weak var currentLanguageLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		settingsNavItem.title = "SETTINGS".localized(VC.language!)
		bgMusicLabel.text = "BG_MUSIC".localized(VC.language!)
		
		languageLabel.text = "LANGUAGE".localized(VC.language!)

		if VC.language! == "es" {
			currentLanguageLabel.text = "SPANISH".localized(VC.language!)
		}
		else {
			currentLanguageLabel.text = "ENGLISH".localized(VC.language!)
		}

		bgMusicSwitch.setOn(VC.bgMusic!.playing, animated: true)
	}

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}

	@IBAction func switchBGMusic(sender: UISwitch) {

		if bgMusicSwitch.on {
			VC.bgMusic?.play()
		}
		else {
			VC.bgMusic?.stop()
		}
	}

}
