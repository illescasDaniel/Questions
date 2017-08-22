import UIKit

class TopicsViewController: UITableViewController {

	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Topics".localized
		
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
		return Quiz.quizzes.count
	}
	
	// MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "setCell")
		cell?.textLabel?.text = Quiz.quizzes[indexPath.row].name.localized
		
		// Load theme
		cell?.textLabel?.font = .preferredFont(forTextStyle: .body)
		cell?.textLabel?.textColor = .themeStyle(dark: .white, light: .black)
		cell?.backgroundColor = .themeStyle(dark: .gray, light: .white)
		cell?.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		
		return cell ?? UITableViewCell()
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "selectTopic", sender: indexPath.row)
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

		if let topicIndex = sender as? Int, segue.identifier == "selectTopic" {
			let controller = segue.destination as? QuizzesViewController
			controller?.currentTopicIndex = topicIndex
		}
	}
	
	// MARK: Convenience
	
	@objc func loadCurrentTheme() {
		tableView.backgroundColor = .themeStyle(dark: .darkGray, light: .groupTableViewBackground)
		tableView.separatorColor = .themeStyle(dark: .darkGray, light: .defaultSeparatorColor)
		tableView.reloadData()
		tableView.dontInvertIfDarkModeIsEnabled()
	}
}
