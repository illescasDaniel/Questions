import UIKit

class QuizzesViewController: UITableViewController {
	
	// MARK: Properties
	
	var currentTopicIndex = Int()
	var setCount = Int()
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = SetOfTopics.shared.currentTopics[currentTopicIndex].name.localized
		setCount =  SetOfTopics.shared.currentTopics[currentTopicIndex].quiz.sets.count
		
		NotificationCenter.default.addObserver(self, selector: #selector(loadCurrentTheme), name: .UIApplicationDidBecomeActive, object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		loadCurrentTheme()
	}
	
	// MARK: UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return setCount
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Quizzes".localized
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "setCell")
		cell?.textLabel?.text = "Set \(indexPath.row)"
		
		let topicName = SetOfTopics.shared.currentTopics[currentTopicIndex].name
		if DataStoreArchiver.shared.completedSets[topicName]?[indexPath.row] ?? false {
			cell?.accessoryType = .checkmark
		}

		// Load theme
		cell?.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
		cell?.textLabel?.textColor = .themeStyle(dark: .white, light: .black)
		cell?.backgroundColor = .themeStyle(dark: .veryDarkGray, light: .white)
		cell?.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		
		return cell ?? UITableViewCell()
	}
	
	// MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as? UITableViewHeaderFooterView
		header?.textLabel?.textColor = .themeStyle(dark: .lightGray, light: .gray)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "selectQuiz", sender: indexPath.row)
	}
	
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
	
	// MARK: UIStoryboardSegue Handling
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let currentSetIndex = sender as? Int, segue.identifier == "selectQuiz" {
			let controller = segue.destination as? QuestionsViewController
			controller?.currentTopicIndex = currentTopicIndex
			controller?.currentSetIndex = currentSetIndex
		}
	}
	
	@IBAction func unwindToQuizSelector(_ segue: UIStoryboardSegue) {
		
		AudioSounds.bgMusic?.setVolumeLevel(to: AudioSounds.bgMusicVolume)
		
		let topicName = SetOfTopics.shared.currentTopics[currentTopicIndex].name
		for i in 0..<setCount where ( DataStoreArchiver.shared.completedSets[topicName]?[i]) ?? false {
			tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
		}
	}
	
	// MARK: Convenience
	
	@IBAction internal func loadCurrentTheme() {
		navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		tableView.backgroundColor = .themeStyle(dark: .black, light: .groupTableViewBackground)
		tableView.separatorColor = .themeStyle(dark: .black, light: .defaultSeparatorColor)
		tableView.reloadData()
	}
}
