import UIKit

class TopicsViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UISearchBarDelegate {
	
	// MARK: View life cycle
	@IBOutlet weak var addBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var refreshBarButtonItem: UIBarButtonItem!
	
	private let searchController = SearchTableViewController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.loadCommunityTopics()
		
		self.tableView.allowsMultipleSelectionDuringEditing = true
		self.clearsSelectionOnViewWillAppear = true
		self.isEditing = false
		
		self.setupNavigationItem()
	
		if UserDefaultsManager.darkThemeSwitchIsOn {
			self.loadCurrentTheme()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.updateEditButton()
		if !SetOfTopics.shared.savedTopics.isEmpty {
			self.tableView.reloadData()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.setEditing(false, animated: true)
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
	
	// MARK: UISearchBarDelegate
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		DispatchQueue.global(qos: .userInitiated).async {
			
			var items: [SetOfTopics.Mode: [TopicEntry]] = [:]
			
			if SetOfTopics.shared.current == .community {
				items[.community] = Array(SetOfTopics.shared.communityTopics.sorted { lhs, rhs in
					return lhs.displayedName.localized.similarityTo(string: searchText) > rhs.displayedName.localized.similarityTo(string: searchText)
					}.prefix(10))
			}
			else {
				items[.app] = Array(SetOfTopics.shared.topicsEntry.sorted { lhs, rhs in
						return lhs.displayedName.localized.similarityTo(string: searchText) > rhs.displayedName.localized.similarityTo(string: searchText)
					}.prefix(10))
				items[.saved] = Array(SetOfTopics.shared.savedTopics.sorted { lhs, rhs in
						return lhs.displayedName.localized.similarityTo(string: searchText) > rhs.displayedName.localized.similarityTo(string: searchText)
					}.prefix(10))
			}
			
			DispatchQueue.main.async {
				self.searchController.items = items
				self.searchController.tableView.reloadData()
			}
		}
	}
	
	// MARK: UIPopoverPresentationControllerDelegate
	
	func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
		return .none
	}
	
	// MARK: Edit cell, delete
	
	@objc internal func editModeAction() {
		self.setEditing(!self.isEditing, animated: true)
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		self.navigationController?.setToolbarHidden(!editing, animated: true)
		if editing { self.toolbarItems?.forEach { $0.isEnabled = false }}
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		switch indexPath.section {
		case SetOfTopics.Mode.app.rawValue: return false
		case SetOfTopics.Mode.saved.rawValue: return true
		default: return false
		}
	}
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		switch indexPath.section {
		case SetOfTopics.Mode.app.rawValue: return .none
		case SetOfTopics.Mode.saved.rawValue: return .delete
		default: return .none
		}
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }
		self.removeSavedTopics(withIndexPaths: [indexPath])
	}
	
	// MARK: UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if SetOfTopics.shared.current == .community {
			if self.tableView.backgroundView == nil && SetOfTopics.shared.communityTopics.isEmpty {
				let activityIndicatorStyle: UIActivityIndicatorView.Style
				if #available(iOS 13, *) {
					activityIndicatorStyle = .medium
				} else {
					activityIndicatorStyle = UserDefaultsManager.darkThemeSwitchIsOn ? .white : .gray
				}
				let activityIndicatorView = UIActivityIndicatorView(style: activityIndicatorStyle)
				activityIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
				activityIndicatorView.startAnimating()
				self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
				self.tableView?.backgroundView = activityIndicatorView
			} else {
				self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
				self.tableView?.backgroundView = nil
			}
			return SetOfTopics.shared.communityTopics.count
		}
		else {
			switch section {
			case SetOfTopics.Mode.app.rawValue: return SetOfTopics.shared.topicsEntry.count
			case SetOfTopics.Mode.saved.rawValue: return SetOfTopics.shared.savedTopics.count
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
		
		if SetOfTopics.shared.current == .community {
			cell.textLabel?.text = SetOfTopics.shared.communityTopics[indexPath.row].displayedName.localized
		}
		else {
			switch indexPath.section {
			case SetOfTopics.Mode.app.rawValue:
				cell.textLabel?.text = SetOfTopics.shared.topicsEntry[indexPath.row].displayedName.localized
			case SetOfTopics.Mode.saved.rawValue:
				cell.textLabel?.text = SetOfTopics.shared.savedTopics[indexPath.row].displayedName.localized
			default: break
			}
		}
		
		// Load theme
		cell.textLabel?.font = .preferredFont(forTextStyle: .body)
		
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
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case SetOfTopics.Mode.app.rawValue: return nil
		case SetOfTopics.Mode.saved.rawValue: return Localized.Topics_AllTopics_Type_Saved
		default: return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		guard UserDefaultsManager.darkThemeSwitchIsOn else { return } // NOTE: could change depending on your theme settings!
		let header = view as? UITableViewHeaderFooterView
		header?.textLabel?.textColor = .themeStyle(dark: .lightGray, light: .gray)
	}

	// TODO: refactor
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if self.isEditing { self.toolbarItems?.forEach { $0.isEnabled = true } }
		
		guard !self.isEditing, let currentCell = tableView.cellForRow(at: indexPath) else { return }
	
		if SetOfTopics.shared.current == .community {
			
			let activityIndicatorStyle: UIActivityIndicatorView.Style
			if #available(iOS 13, *) {
				activityIndicatorStyle = .medium
			} else {
				activityIndicatorStyle = UserDefaultsManager.darkThemeSwitchIsOn ? .white : .gray
			}
			let activityIndicator = UIActivityIndicatorView(frame: currentCell.bounds)
			activityIndicator.style = activityIndicatorStyle
			activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			
			if !CommunityTopics.shared.topics.isEmpty, SetOfTopics.shared.communityTopics[indexPath.row].topic.sets.flatMap({ $0 }).isEmpty {
				
				activityIndicator.startAnimating()
				self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
				currentCell.accessoryView = activityIndicator
				
				let currentTopic = CommunityTopics.shared.topics[indexPath.row]
				DownloadManager.shared.manageData(from: currentTopic.remoteContentURL, onSuccess: { data in
					guard let topic = SetOfTopics.shared.quizFrom(content: data) else { return }
					SetOfTopics.shared.communityTopics[indexPath.row].topic = topic
					DispatchQueue.main.async {
						activityIndicator.stopAnimating()
						self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
						currentCell.accessoryView = nil
						self.performSegue(withIdentifier: "selectTopic", sender: indexPath)
					}
				})
				return
			}
		}
		self.performSegue(withIdentifier: "selectTopic", sender: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		let selectedRows = tableView.indexPathsForSelectedRows
		if self.isEditing && (selectedRows == nil || selectedRows?.isEmpty == true) {
			self.toolbarItems?.forEach { $0.isEnabled = false }
		}
	}
	
	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return (self.isEditing && indexPath.section == SetOfTopics.Mode.saved.rawValue) || !self.isEditing
	}
	
	// MARK: - Actions
	
	@IBAction func addTopicAction(_ sender: UIBarButtonItem) {
		
		guard SetOfTopics.shared.current == .community else {
			self.performSegue(withIdentifier: "addContentTableVC", sender: nil)
			return
		}
		
		let titleText = Localized.Topics_Community_Submission_Title
		let messageText = Localized.Topics_Community_Submission_Info
		
		let newTopicAlert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
		
		newTopicAlert.addTextField { textField in
			textField.placeholder = Localized.Topics_Community_Submission_TopicName
			textField.keyboardType = .alphabet
			textField.autocapitalizationType = .sentences
			textField.autocorrectionType = .yes
			textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 25))
			guard #available(iOS 13, *) else {
				textField.keyboardAppearance = UserDefaultsManager.darkThemeSwitchIsOn ? .dark : .light
				return
			}
		}
		
		newTopicAlert.addTextField { textField in
			textField.placeholder = Localized.Topics_Community_Submission_TopicContent
			textField.keyboardType = .URL
			textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 25))
			guard #available(iOS 13, *) else {
				textField.keyboardAppearance = UserDefaultsManager.darkThemeSwitchIsOn ? .dark : .light
				return
			}
		}
		
		newTopicAlert.addAction(title: Localized.Topics_Community_Submission_Help, style: .default) { _ in
			if let url = URL(string: QuestionsAppOptions.questionJSONFormatURL) {
				if #available(iOS 10.0, *) {
					UIApplication.shared.open(url, options: [:])
				} else {
					UIApplication.shared.openURL(url)
				}
			}
		}
		
		newTopicAlert.addAction(title: Localized.Topics_Community_Submission_Action, style: .default) { _ in
			
			if let topicName = newTopicAlert.textFields?.first?.text,
				let topicURLText = newTopicAlert.textFields?.last?.text, !topicURLText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				
				// TODO: translate
				let messageBody = """
					Topic name: \(topicName)
					Topic URL or content: \(topicURLText)
					""".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "error"
				
				let devEmail = "daniel.illescas@icloud.com"
				let subject = "Questions - Topic submission".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "Questions_Topic submission"
				let fullURL = "mailto:\(devEmail)?subject=\(subject)&body=\(messageBody)"
				
				if let validURL = URL(string: fullURL) {
					if #available(iOS 10.0, *) {
						UIApplication.shared.open(validURL, options: [:])
					} else {
						UIApplication.shared.openURL(validURL)
					}
				}
			}
		}
		
		newTopicAlert.addAction(title: Localized.Common_Cancel, style: .cancel)
		self.present(newTopicAlert, animated: true)
	}
	
	@objc
	private func deleteItems() {
		
		guard let selectedItemsIndexPaths = self.tableView.indexPathsForSelectedRows, !selectedItemsIndexPaths.isEmpty else { return }
		
		if #available(iOS 10.0, *) { FeedbackGenerator.notificationOcurredOf(type: .warning) }
		
		let title = String.localizedStringWithFormat(Localized.Topics_Saved_DeleteAll, selectedItemsIndexPaths.count, selectedItemsIndexPaths.count > 1 ? "s" : "")
		let deleteItemsAlert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
		deleteItemsAlert.popoverPresentationController?.barButtonItem = self.toolbarItems?.last
		
		deleteItemsAlert.addAction(title: Localized.Topics_Saved_Delete, style: .destructive) { _ in
			self.removeSavedTopics(withIndexPaths: selectedItemsIndexPaths)
		}
		deleteItemsAlert.addAction(title: Localized.Common_Cancel, style: .cancel)
		
		self.present(deleteItemsAlert, animated: true)
	}
	
	// Assuming all indexPaths are fromthe same section
	private func removeSavedTopics(withIndexPaths indexPaths: [IndexPath]) {
		SetOfTopics.shared.removeSavedTopics(withIndexPaths: indexPaths, reloadAfterDeleting: true)
		let section = indexPaths[0].section
		if self.tableView.numberOfRows(inSection: section) == indexPaths.count {
			self.tableView.deleteSections([section], with: .fade)
			self.updateEditButton()
		} else {
			self.tableView.deleteRows(at: indexPaths, with: .fade)
		}
		self.setEditing(false, animated: true)
	}
	
	@objc
	private func shareItems() {
		
		guard let selectedItemsIndexPaths = self.tableView.indexPathsForSelectedRows, !selectedItemsIndexPaths.isEmpty else { return }
		
		var items: [Any] = []
		
		for index in selectedItemsIndexPaths.lazy.map ({ $0.row }) {
			let quizInJSON = SetOfTopics.shared.savedTopics[index].topic.inJSON
			items.append(quizInJSON)
			let size = min(self.view.bounds.width, self.view.bounds.height)
			if let outputQR = quizInJSON.generateQRImageWith(size: (width: size, height: size)) { items.append(outputQR) }
		}
		
		let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
		activityVC.completionWithItemsHandler = { _, completed, _, _ in
			if completed { self.setEditing(false, animated: true) }
		}
		
		activityVC.popoverPresentationController?.barButtonItem = self.toolbarItems?.first
		self.present(activityVC, animated: true)
	}
	
	@IBAction func refreshTopics(_ sender: UIBarButtonItem) {
		
		SetOfTopics.shared.communityTopics.removeAll(keepingCapacity: true)
		self.tableView.backgroundView = nil
		self.tableView.reloadData()
		
		SetOfTopics.shared.loadCommunityTopics {
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	// MARK: - UIStoryboardSegue Handling

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "selectTopic", let topicIndexPath = sender as? IndexPath {
			
			let controller = segue.destination as? QuizzesViewController
			
			if SetOfTopics.shared.current != .community {
				switch topicIndexPath.section {
				case SetOfTopics.Mode.app.rawValue: SetOfTopics.shared.current = .app
				case SetOfTopics.Mode.saved.rawValue: SetOfTopics.shared.current = .saved
				default: break
				}
			}
			controller?.currentTopicIndex = topicIndexPath.row
		}
		
		if segue.identifier == "addContentTableVC", let addContentTableVC = segue.destination as? AddContentTableVC, SetOfTopics.shared.current != .community {
			if #available(iOS 10.0, *) { FeedbackGenerator.impactOcurredWith(style: .light) }
			addContentTableVC.popoverPresentationController?.delegate = self
			addContentTableVC.parentVC = self
			self.setEditing(false, animated: true)
		}
	}
	
	// MARK: - Convenience
	
	private func loadCommunityTopics() {
		guard SetOfTopics.shared.communityTopics.isEmpty else { return }
		SetOfTopics.shared.loadCommunityTopics {
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	private func updateEditButton() {
		self.editButtonItem.isEnabled = !SetOfTopics.shared.savedTopics.isEmpty
	}
	
	private func loadCurrentTheme() {
		if #available(iOS 13, *) {
			self.tableView.backgroundColor = .themeStyle(dark: .black, light: .systemGroupedBackground)
		} else {
			self.tableView.backgroundColor = .themeStyle(dark: .black, light: .groupTableViewBackground)
		}
		self.tableView.separatorColor = .themeStyle(dark: .black, light: .defaultSeparatorColor)
	}
	
	private func setupNavigationItem() {
		
		self.navigationItem.title = SetOfTopics.shared.current == .community
			? Localized.Topics_Community_Title
			: Localized.Topics_AllTopics_Title
		
		self.editButtonItem.isEnabled = SetOfTopics.shared.current != .community
		
		if let rightBarButtonItems = self.navigationItem.rightBarButtonItems {
			self.navigationItem.rightBarButtonItems = [self.editButtonItem] + rightBarButtonItems
		}
		
		let allowedBarButtonItems: [UIBarButtonItem]? =
			SetOfTopics.shared.current == .community
				? [self.addBarButtonItem, self.refreshBarButtonItem]
				: self.navigationItem.rightBarButtonItems?.filter { $0 != self.refreshBarButtonItem}
		self.navigationItem.setRightBarButtonItems(allowedBarButtonItems, animated: false)
		
		let shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareItems))
		let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
		let trashItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteItems))
		self.toolbarItems = [shareItem, flexibleSpaceItem, trashItem]
		
		self.setupSearchController()
	}
	
	private func setupSearchController() {
		guard #available(iOS 11.0, *) else { return }
		self.navigationItem.searchController = UISearchController(searchResultsController: self.searchController)
		self.searchController.parentVC = self
		self.navigationItem.searchController?.searchBar.delegate = self
		self.navigationItem.searchController?.delegate = self.searchController
		self.definesPresentationContext = true
		self.navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
		self.navigationItem.hidesSearchBarWhenScrolling = true
		self.navigationItem.searchController?.searchBar.placeholder = Localized.Topics_AllTopics_SearchBar_PlaceholderText
	}
}
