import UIKit

class TopicsViewController: UITableViewController {
	
	// MARK: View life cycle
	@IBOutlet weak var addBarButtonItem: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.title = "Topics".localized
		self.navigationItem.backBarButtonItem?.title = "Main Menu".localized
		
		/*self.editButtonItem.isEnabled = SetOfTopics.shared.isUsingUserSavedTopics
		self.navigationItem.rightBarButtonItem = self.editButtonItem
		self.editButtonItem.action = #selector(self.editModeAction)*/
		self.isEditing = false
		//self.tableView.allowsMultipleSelectionDuringEditing = true
		//self.clearsSelectionOnViewWillAppear = true
		
		addBarButtonItem.isEnabled = SetOfTopics.shared.isUsingUserSavedTopics
		
		NotificationCenter.default.addObserver(self, selector: #selector(loadCurrentTheme), name: .UIApplicationDidBecomeActive, object: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		self.loadCurrentTheme()
	}
	
	// MARK: Edit cell, delete
	
	@objc internal func editModeAction() {
		self.setEditing(!self.isEditing, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return SetOfTopics.shared.isUsingUserSavedTopics ? .delete : .none
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
		if editingStyle == .delete {
			
			let fileManager = FileManager.default
			
			if let cell = tableView.cellForRow(at: indexPath), let labelText = cell.textLabel?.text {
			
				let fileName =  "\(labelText).json"
				
				if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
					let fileURL = documentsDirectory.appendingPathComponent(fileName)
					if (try? fileManager.removeItem(at: fileURL)) != nil {
						SetOfTopics.shared.loadSavedTopics()
						tableView.deleteRows(at: [indexPath], with: .fade)
					}
				}
			}
		}
	}
	
	// MARK: UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		let count = SetOfTopics.shared.currentTopics.count

		if count > 0 {
			self.tableView?.backgroundView = nil
		}
		else if self.tableView?.backgroundView == nil {
			let emptyListText = "Empty, read questions from a QR code".localized
			let emptyTableLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
			emptyTableLabel.text = emptyListText.localized
			emptyTableLabel.font = .preferredFont(forTextStyle: .title3)
			emptyTableLabel.textColor = .themeStyle(dark: .warmYellow, light: .coolBlue)
			emptyTableLabel.textAlignment = .center
			emptyTableLabel.numberOfLines = 0
			
			UIView.animate(withDuration: 0.2, animations: {
				self.tableView?.backgroundView = emptyTableLabel
			})
			self.tableView?.separatorStyle = .none
		}
		
		return count
	}
	
	// MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "setCell")
		cell?.textLabel?.text = SetOfTopics.shared.currentTopics[indexPath.row].name.localized
		
		// Load theme
		cell?.textLabel?.font = .preferredFont(forTextStyle: .body)
		cell?.textLabel?.textColor = .themeStyle(dark: .white, light: .black)
		cell?.backgroundColor = .themeStyle(dark: .veryDarkGray, light: .white)
		cell?.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		
		return cell ?? UITableViewCell()
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// if is not editing... maybe will add the editing thing in the future
		performSegue(withIdentifier: "selectTopic", sender: indexPath.row)
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
	
	// MARK: - Actions
	
	@IBAction func addNewTopic(_ sender: UIBarButtonItem) {
		
		let newTopicAlert = UIAlertController(title: "New Topic".localized, message: "You can read a QR code to add a topic or download it using a URL which contains an appropiate formatted file.".localized, preferredStyle: .alert)
		
		newTopicAlert.addTextField { textField in
			textField.placeholder = "Topic Name".localized
			textField.keyboardType = .alphabet
			textField.autocapitalizationType = .sentences
			textField.autocorrectionType = .yes
			textField.keyboardAppearance = UserDefaultsManager.darkThemeSwitchIsOn ? .dark : .light
			textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 25))
		}
		
		newTopicAlert.addTextField { textField in
			textField.placeholder = "Topic URL or fomatted content".localized
			textField.keyboardType = .URL
			textField.keyboardAppearance = UserDefaultsManager.darkThemeSwitchIsOn ? .dark : .light
			textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 25))
		}
		
		newTopicAlert.addAction(title: "Help".localized, style: .default) { _ in
			if let url = URL(string: "https://github.com/illescasDaniel/Questions#topics-json-format") {
				
				if #available(iOS 10.0, *) {
					UIApplication.shared.open(url, options: [:])
				} else {
					UIApplication.shared.openURL(url)
				}
			}
		}
		
		newTopicAlert.addAction(title: "Add".localized, style: .default) { _ in
			
			if let topicName = newTopicAlert.textFields?.first?.text,
				let topicURLText = newTopicAlert.textFields?.last?.text, !topicURLText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				
				DispatchQueue.global().async {
					
					let quizContent: String
					if let topicURL = URL(string: topicURLText), let validTextFromURL = try? String(contentsOf: topicURL) {
						quizContent = validTextFromURL
					} else {
						quizContent = topicURLText
					}
					
					if let validQuiz = SetOfTopics.shared.quizFrom(content: quizContent) {
						SetOfTopics.shared.save(topic: TopicEntry(name: topicName, content: validQuiz))
						DispatchQueue.main.async {
							self.tableView.reloadData()
						}
					}
				}
			}
		}
		
		newTopicAlert.addAction(title: "Cancel", style: .cancel)
		
		self.present(newTopicAlert, animated: true)
	}
	
	// MARK: - UIStoryboardSegue Handling

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if let topicIndex = sender as? Int, segue.identifier == "selectTopic" {
			let controller = segue.destination as? QuizzesViewController
			controller?.currentTopicIndex = topicIndex
		}
	}
	
	// MARK: - Convenience
	
	@IBAction internal func loadCurrentTheme() {
		tableView.backgroundColor = .themeStyle(dark: .black, light: .groupTableViewBackground)
		tableView.separatorColor = .themeStyle(dark: .black, light: .defaultSeparatorColor)
		tableView.reloadData()
	}
}
