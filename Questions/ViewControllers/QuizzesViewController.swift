import UIKit

class QuizzesViewController: UITableViewController {
	
	// MARK: Properties
	
	var currentTopicIndex = Int()
	var setCount = Int()
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = SetOfTopics.shared.currentTopics[currentTopicIndex].displayedName.localized
		setCount =  SetOfTopics.shared.currentTopics[currentTopicIndex].topic.sets.count
		
		if UserDefaultsManager.darkThemeSwitchIsOn {
			self.loadCurrentTheme()
		}
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

	// MARK: UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return setCount
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return L10n.Topics_Quizzes_Title
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if #available(iOS 13.0, *) {
			cell.textLabel?.textColor = .label
			cell.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
			return
		}
		cell.textLabel?.textColor = .themeStyle(dark: .white, light: .black)
		
		cell.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		//cell.backgroundColor = .themeStyle(dark: .veryDarkGray, light: .white)
		if UserDefaultsManager.darkThemeSwitchIsOn { cell.backgroundColor = .veryDarkGray }
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "setCell", for: indexPath)
		cell.textLabel?.text = "Set \(indexPath.row)"
		
		let topicName = SetOfTopics.shared.currentTopics[currentTopicIndex].displayedName
		if DataStoreArchiver.shared.completedSets[topicName]?[indexPath.row] ?? false {
			cell.accessoryType = .checkmark
		}

		// Load theme
		cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
		
		if #available(iOS 13, *) {
			return cell
		}
		
		if UserDefaultsManager.darkThemeSwitchIsOn {
			let view = UIView()
			view.backgroundColor = UIColor.darkGray
			cell.selectedBackgroundView = view
		}
		
		return cell
	}
	
	// MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		guard UserDefaultsManager.darkThemeSwitchIsOn else { return } // NOTE: could change depending on your theme settings!
		let header = view as? UITableViewHeaderFooterView
		header?.textLabel?.textColor = .themeStyle(dark: .lightGray, light: .gray)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.performSegue(withIdentifier: "selectQuiz", sender: indexPath.row)
	}
	
	// MARK: UIStoryboardSegue Handling
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let currentSetIndex = sender as? Int, segue.identifier == "selectQuiz" {
			let controller = segue.destination as? QuestionsViewController
			controller?.currentTopicIndex = currentTopicIndex
			controller?.currentSetIndex = currentSetIndex
		}
	}
	
	@IBAction func unwindToQuizSelector(_ segue: UIStoryboardSegue) {
		
		AudioSounds.bgMusic?.setVolumeLevel(to: AudioSounds.defaultBGMusicLevel)
		
		let topicName = SetOfTopics.shared.currentTopics[currentTopicIndex].displayedName
		for i in 0..<setCount where ( DataStoreArchiver.shared.completedSets[topicName]?[i]) ?? false {
			tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
		}
	}
	
	// MARK: Convenience
	
	private func loadCurrentTheme() {
		guard #available(iOS 13, *) else {
			navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
			navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
			tableView.backgroundColor = .themeStyle(dark: .black, light: .groupTableViewBackground)
			tableView.separatorColor = .themeStyle(dark: .black, light: .defaultSeparatorColor)
			return
		}
	}
}
