import UIKit

class TopicsViewController: UITableViewController {

	// MARK: Properties
	
	var darkThemeEnabled = Settings.sharedInstance.darkThemeEnabled

	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.title = "Topics".localized
		
		NotificationCenter.default.addObserver(self, selector: #selector(loadCurrentTheme),
		                                       name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		loadCurrentTheme()
	}
	
	deinit {		
		if #available(iOS 9.0, *) { }
		else {
			NotificationCenter.default.removeObserver(self)
		}
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
		cell?.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
		cell?.textLabel?.textColor = darkThemeEnabled ? .white : .black
		cell?.backgroundColor = darkThemeEnabled ? .gray : .white
		cell?.tintColor = darkThemeEnabled ? .orange : .defaultTintColor
		
		return cell ?? UITableViewCell()
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "selectTopic", sender: indexPath.row)
	}
	
	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		
		let cell = tableView.cellForRow(at: indexPath)
		
		let cellColor: UIColor = darkThemeEnabled ? .lightGray : .highlighedGray
		cell?.backgroundColor = cellColor
		
		let view = UIView()
		view.backgroundColor = cellColor
		cell?.selectedBackgroundView = view
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)
		cell?.backgroundColor = darkThemeEnabled ? .gray : .white
	}
	
	// MARK: UIStoryboardSegue Handling

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if let topicIndex = sender as? Int, segue.identifier == "selectTopic" {
			let controller = segue.destination as! QuizzesViewController
			controller.currentTopicIndex = topicIndex
		}
	}
	
	// MARK: Convenience
	
	func loadCurrentTheme() {
		darkThemeEnabled = Settings.sharedInstance.darkThemeEnabled
		tableView.backgroundColor = darkThemeEnabled ? .darkGray : .defaultBGcolor
		tableView.separatorColor = darkThemeEnabled ? .darkGray : .defaultSeparatorColor
		tableView.reloadData()
	}
}
