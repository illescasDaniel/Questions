import UIKit

class QuizzesViewController: UITableViewController {
	
	// MARK: Properties
	
	var cell: UITableViewCell?
	var currentTopicIndex = Int()
	var setCount = Int()
	let darkThemeEnabled = Settings.sharedInstance.darkThemeEnabled
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = Quiz.quizzes[currentTopicIndex].name.localized
		setCount = Quiz.quizzes[currentTopicIndex].contents.count
		
		tableView.backgroundColor = darkThemeEnabled ? .darkGray : .defaultBGcolor
		tableView.separatorColor = darkThemeEnabled ? .darkGray : .defaultSeparatorColor
	}
	
	// MARK: UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return setCount
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Quizzes".localized
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		cell = tableView.dequeueReusableCell(withIdentifier: "setCell")
		cell?.textLabel?.text = "Set \(indexPath.row)"
		
		fillCompletedSets()
		
		if Settings.sharedInstance.completedSets[currentTopicIndex]?[indexPath.row] ?? false {
			cell?.accessoryType = .checkmark
		}

		// Load theme
		cell?.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
		cell?.textLabel?.textColor = darkThemeEnabled ? .white : .black
		cell?.backgroundColor = darkThemeEnabled ? .gray : .white
		cell?.tintColor = darkThemeEnabled ? .orange : .defaultTintColor
		
		return cell ?? UITableViewCell()
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		fillCompletedSets()
		performSegue(withIdentifier: "selectQuiz", sender: indexPath.row)
	}
	
	// MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.textLabel?.textColor = darkThemeEnabled ? .lightGray : .gray
	}
	
	// MARK: UIStoryboardSegue Handling
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let currentSetIndex = sender as? Int , segue.identifier == "selectQuiz" {
			let controller = segue.destination as! QuestionsViewController
			controller.currentTopicIndex = currentTopicIndex
			controller.currentSetIndex = currentSetIndex
		}
	}
	
	@IBAction func unwindToQuizSelector(_ segue: UIStoryboardSegue) {
		
		Audio.setVolumeLevel(to: Audio.bgMusicVolume)
		
		for i in 0..<setCount where (Settings.sharedInstance.completedSets[currentTopicIndex]?[i]) ?? false {
			tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
		}
	}
	
	// MARK: Convenience
	
	func fillCompletedSets() {
		let completedSetsCount = (Settings.sharedInstance.completedSets[currentTopicIndex]?.count) ?? 0
		
		if completedSetsCount < setCount {
			Settings.sharedInstance.completedSets[currentTopicIndex] = [Bool](repeating: false, count: setCount)
		}
	}
}
