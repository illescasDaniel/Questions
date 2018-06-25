import UIKit

class TopicsViewController: UITableViewController {
	
	// MARK: View life cycle
	@IBOutlet weak var addBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var refreshBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var composeBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var cameraBarButtonItem: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.title = SetOfTopics.shared.current == .community ? "Community".localized : "Topics".localized
		self.navigationItem.backBarButtonItem?.title = "Main menu".localized
		/*self.editButtonItem.isEnabled = SetOfTopics.shared.isUsingUserSavedTopics
		self.navigationItem.rightBarButtonItem = self.editButtonItem
		self.editButtonItem.action = #selector(self.editModeAction)*/
		self.isEditing = false
		//self.tableView.allowsMultipleSelectionDuringEditing = true
		//self.clearsSelectionOnViewWillAppear = true

		let allowedBarButtonItems: [UIBarButtonItem]?
		if SetOfTopics.shared.current != .community {
			allowedBarButtonItems = self.navigationItem.rightBarButtonItems?.filter { $0 != self.refreshBarButtonItem}
		} else {
			allowedBarButtonItems = [self.addBarButtonItem, self.refreshBarButtonItem]
		}
		self.navigationItem.setRightBarButtonItems(allowedBarButtonItems, animated: false)
		
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
		switch indexPath.section {
		case 0: return .none
		case 1: return .delete
		case 2: return .none
		default: return .none
		}
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
	
	@objc private func reloadTopicIfCommunityTopicsLoaded(_ timer: Timer) {
		if CommunityTopics.shared != nil && CommunityTopics.areLoaded {
			DispatchQueue.main.async {
				(self.tableView?.backgroundView as? UIActivityIndicatorView)?.stopAnimating()
				self.tableView.reloadData()
			}
			timer.invalidate()
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if SetOfTopics.shared.current == .community {
			if self.tableView.backgroundView == nil {
				let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UserDefaultsManager.darkThemeSwitchIsOn ? .white : .gray)
				activityIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
				activityIndicatorView.startAnimating()
				
				self.tableView?.backgroundView = activityIndicatorView
				
				if CommunityTopics.shared == nil || !CommunityTopics.areLoaded {
					
					if #available(iOS 10.0, *) {
						Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
							if CommunityTopics.shared != nil && CommunityTopics.areLoaded {
								DispatchQueue.main.async {
									activityIndicatorView.stopAnimating()
									self.tableView.reloadData()
								}
								timer.invalidate()
							}
						}
					} else {
						Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.reloadTopicIfCommunityTopicsLoaded), userInfo: nil, repeats: true)
					}
				}
			}
			return SetOfTopics.shared.communityTopics.count
		}
		else {
			switch section {
			case 0: return SetOfTopics.shared.topics.count
			case 1: return SetOfTopics.shared.savedTopics.count
			default: return 0
			}
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if SetOfTopics.shared.current == .community {
			return 1
		} else {
			return SetOfTopics.shared.savedTopics.isEmpty ? 1 : 2
		}
	}
	
	// MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "setCell")
		
		if SetOfTopics.shared.current == .community {
			cell?.textLabel?.text = SetOfTopics.shared.communityTopics[indexPath.row].displayedName.localized
		}
		else {
			switch indexPath.section {
			case 0: cell?.textLabel?.text = SetOfTopics.shared.topics[indexPath.row].displayedName.localized
			case 1: cell?.textLabel?.text = SetOfTopics.shared.savedTopics[indexPath.row].displayedName.localized
			default: break
			}
		}
		
		// Load theme
		cell?.textLabel?.font = .preferredFont(forTextStyle: .body)
		cell?.textLabel?.textColor = .themeStyle(dark: .white, light: .black)
		cell?.backgroundColor = .themeStyle(dark: .veryDarkGray, light: .white)
		cell?.tintColor = .themeStyle(dark: .orange, light: .defaultTintColor)
		
		return cell ?? UITableViewCell()
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return nil
		case 1: return "User topics".localized
		default: return nil
		}
	}

	// TODO:  needs more testing
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		guard let currentCell = tableView.cellForRow(at: indexPath) else { return }
		let activityIndicator = UIActivityIndicatorView(frame: currentCell.bounds)
		activityIndicator.activityIndicatorViewStyle = (UserDefaultsManager.darkThemeSwitchIsOn ? .white : .gray)
		activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		DispatchQueue.global().async {
			
			if SetOfTopics.shared.current == .community,
				SetOfTopics.shared.communityTopics[indexPath.row].quiz.sets.flatMap({ $0 }).isEmpty,
				let communityTopics = CommunityTopics.shared {
				
				DispatchQueue.main.async {
					activityIndicator.startAnimating()
					currentCell.accessoryView = activityIndicator
				}
				
				let currentTopic = communityTopics.topics[indexPath.row]
				
				if let validTextFromURL = try? String(contentsOf: currentTopic.remoteContentURL), let quiz = SetOfTopics.shared.quizFrom(content: validTextFromURL) {
					SetOfTopics.shared.communityTopics[indexPath.row].quiz = quiz
				}
				DispatchQueue.main.async {
					activityIndicator.stopAnimating()
					currentCell.accessoryView = nil
				}
			}
			
			DispatchQueue.main.async {
				self.performSegue(withIdentifier: "selectTopic", sender: indexPath)
			}
		}
		// if is not editing... maybe will add the editing thing in the future
		//self.performSegue(withIdentifier: "selectTopic", sender: indexPath.row)
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
		
		let titleText = (SetOfTopics.shared.current == .community) ? "Topic submission" : "New Topic"
		let messageText = (SetOfTopics.shared.current != .community)
			? "You can read a QR code to add a topic or download it using a URL which contains an appropiate formatted file."
			: "You can specify a URL which contains an appropiate formatted file or the full topic content."
		
		let newTopicAlert = UIAlertController(title: titleText.localized, message: messageText.localized, preferredStyle: .alert)
		
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
		
		let okAction = (SetOfTopics.shared.current != .community) ? "Add" : "Submit"
		newTopicAlert.addAction(title: okAction.localized, style: .default) { _ in
			
			if let topicName = newTopicAlert.textFields?.first?.text,
				let topicURLText = newTopicAlert.textFields?.last?.text, !topicURLText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				
				self.okActionAddItem(topicName: topicName, topicURLText: topicURLText)
			}
		}
		
		newTopicAlert.addAction(title: "Cancel".localized, style: .cancel)
		
		self.present(newTopicAlert, animated: true)
	}
	
	@IBAction func refreshTopics(_ sender: UIBarButtonItem) {
		
		SetOfTopics.shared.communityTopics.removeAll(keepingCapacity: true)
		CommunityTopics.shared = nil
		self.tableView.reloadData()
		
		DispatchQueue.global().async {
			SetOfTopics.shared.loadCommunityTopics()
		}
	}
	
	@IBAction func createTopic(_ sender: UIBarButtonItem) {
		
	}
	
	@IBAction func readTopicFromCamera(_ sender: UIBarButtonItem) {
		
	}
	// MARK: - UIStoryboardSegue Handling

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let topicIndexPath = sender as? IndexPath, segue.identifier == "selectTopic" {
			let controller = segue.destination as? QuizzesViewController
			switch topicIndexPath.section {
			case 0: SetOfTopics.shared.current = .app
			case 1: SetOfTopics.shared.current = .saved
			case 2: SetOfTopics.shared.current = .community
			default: break
			}
			controller?.currentTopicIndex = topicIndexPath.row
		}
	}
	
	// MARK: - Convenience
	
	@IBAction internal func loadCurrentTheme() {
		tableView.backgroundColor = .themeStyle(dark: .black, light: .groupTableViewBackground)
		tableView.separatorColor = .themeStyle(dark: .black, light: .defaultSeparatorColor)
		tableView.reloadData()
	}
	
	private func okActionAddItem(topicName: String, topicURLText: String) {
		
		DispatchQueue.global().async {
			
			if SetOfTopics.shared.current == .community {
				
				let messageBody = """
					Topic name: \(topicName)
					Topic URL or content: \(topicURLText)
					""".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "error"
				
				let devEmail = "daniel.illescas@icloud.com"
				let subject = "Questions - Topic submission".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "Questions_Topic submission"
				let fullURL = "mailto:\(devEmail)?subject=\(subject)&body=\(messageBody)"
				
				if let validURL = URL(string: fullURL) {
					UIApplication.shared.openURL(validURL)
				}
			}
			else {
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
}
