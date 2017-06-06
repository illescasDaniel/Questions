import UIKit

class QuizzesViewController: UITableViewController {
	
	// MARK: Properties
	
	var currentTopicIndex = Int()
	var setCount = Int()
	
	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = Quiz.quizzes[currentTopicIndex].name.localized
		setCount = Quiz.quizzes[currentTopicIndex].content.count
		
		NotificationCenter.default.addObserver(self, selector: #selector(loadCurrentTheme), name: .UIApplicationDidBecomeActive, object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		loadCurrentTheme()
	}
	
	@available(iOS, deprecated: 9.0)
	deinit {
		NotificationCenter.default.removeObserver(self)
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
		
		fillCompletedSets()
		
		if Settings.sharedInstance.completedSets[currentTopicIndex]?[indexPath.row] ?? false {
			cell?.accessoryType = .checkmark
		}

		// Load theme
		cell?.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
		cell?.textLabel?.textColor = .themeStyle(dark: .white, light: .black)
		cell?.backgroundColor = .themeStyle(dark: .gray, light: .white)
		cell?.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		
		return cell ?? UITableViewCell()
	}
	
	// MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let header = view as! UITableViewHeaderFooterView
		header.textLabel?.textColor = .themeStyle(dark: .lightGray, light: .gray)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		fillCompletedSets()
		performSegue(withIdentifier: "selectQuiz", sender: indexPath.row)
	}
	
	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		
		let cell = tableView.cellForRow(at: indexPath)
		
		let cellColor = UIColor.themeStyle(dark: .lightGray, light: .highlighedGray)
		cell?.backgroundColor = cellColor
		
		let view = UIView()
		view.backgroundColor = cellColor
		cell?.selectedBackgroundView = view
	}
	
	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)
		cell?.backgroundColor = .themeStyle(dark: .gray, light: .white)
	}
	
	// MARK: UIStoryboardSegue Handling
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let currentSetIndex = sender as? Int, segue.identifier == "selectQuiz" {
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
	
	@objc func loadCurrentTheme() {
		navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		navigationController?.navigationBar.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		tableView.backgroundColor = .themeStyle(dark: .darkGray, light: .groupTableViewBackground)
		tableView.separatorColor = .themeStyle(dark: .darkGray, light: .defaultSeparatorColor)
		tableView.reloadData()
	}
	
	private func fillCompletedSets() {
		let completedSetsCount = (Settings.sharedInstance.completedSets[currentTopicIndex]?.count) ?? 0
		
		if completedSetsCount < setCount {
			Settings.sharedInstance.completedSets[currentTopicIndex] = [Bool](repeating: false, count: setCount)
		}
	}
}
