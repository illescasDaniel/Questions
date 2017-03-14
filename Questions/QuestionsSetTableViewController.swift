import UIKit

class QuestionsSetsViewController: UITableViewController {
	
	// MARK: Properties
	
	var cell: UITableViewCell?
	var currentQuiz = Int()
	var setCount = Int()
	let darkThemeEnabled = Settings.sharedInstance.darkThemeEnabled
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		switch currentQuiz {
			case 0: setCount = Quiz.technology.count
			case 1: setCount = Quiz.social.count
			case 2: setCount = Quiz.people.count
			default: return
		}
		
		tableView.backgroundColor = darkThemeEnabled ? .darkGray : .defaultBGcolor
		tableView.separatorColor = darkThemeEnabled ? .darkGray : .defaultSeparatorColor
	}
	
	// MARK: UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return setCount
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Questions sets".localized
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		cell = tableView.dequeueReusableCell(withIdentifier: "setCell")
		cell?.textLabel?.text = "Set \(indexPath.row)"
		
		fillCompletedSets()
		
		if Settings.sharedInstance.completedSets[currentQuiz]?[indexPath.row] ?? false {
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
		performSegue(withIdentifier: "selectQuestionSet", sender: indexPath.row)
	}
	
	// MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.textLabel?.textColor = darkThemeEnabled ? .lightGray : .gray
	}
	
	// MARK: UIStoryboardSegue Handling
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let set = sender as? Int , segue.identifier == "selectQuestionSet" {
			let controller = segue.destination as! QuestionViewController
			controller.currentQuiz = currentQuiz
			controller.currentSet = set
		}
	}
	
	@IBAction func unwindToQuestionSetSelector(_ segue: UIStoryboardSegue) {
		
		Audio.setVolumeLevel(to: Audio.bgMusicVolume)
		
		for i in 0..<setCount where (Settings.sharedInstance.completedSets[currentQuiz]?[i]) ?? false {
			tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
		}
	}
	
	// MARK: Convenience
	
	func fillCompletedSets() {
		let completedSetsCount = (Settings.sharedInstance.completedSets[currentQuiz]?.count) ?? 0
		
		if completedSetsCount < setCount {
			Settings.sharedInstance.completedSets[currentQuiz] = [Bool](repeating: false, count: setCount)
		}
	}
}
