import UIKit

class SettingsViewController: UITableViewController {

	@IBOutlet weak var settingsNavItem: UINavigationItem!
	@IBOutlet weak var bgMusicLabel: UILabel!
	@IBOutlet weak var bgMusicSwitch: UISwitch!

	override func viewDidLoad() {
		super.viewDidLoad()

		settingsNavItem.title = "Settings".localized
		bgMusicLabel.text = "Background music".localized

		bgMusicSwitch.setOn(MainViewController.bgMusic!.playing, animated: true)
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	@IBAction func switchBGMusic(sender: UISwitch) {
		
        if let bgMusic = MainViewController.bgMusic {
            
            if bgMusicSwitch.on {
                bgMusic.play()
            }
            else {
                bgMusic.stop()
            }

        }
	}

	@IBAction func unwindToSettingsMenu(unwindSegue: UIStoryboardSegue) {
		
	}
}
