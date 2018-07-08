//
//  AddContentViewController.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 08/07/2018.
//

import UIKit

class CustomUITableViewCell: UITableViewCell {
	@IBInspectable
	override var imageView: UIImageView? { return self.viewWithTag(1) as? UIImageView }
	@IBInspectable
	override var textLabel: UILabel? { return self.viewWithTag(2) as? UILabel }
}

class PopoverTableViewController: UITableViewController {
	
	var parentVC: UITableViewController?
	
	override func viewDidLoad() {
		self.modalPresentationStyle = .popover
	}
	func presentOnParent(_ viewController: UIViewController) {
		self.dismiss(animated: true) {
			self.parentVC?.present(viewController, animated: true)
		}
	}
}

class AddContentTableVC: PopoverTableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.backgroundColor = .popoverVCBackground
		self.view.backgroundColor = .popoverVCBackground
		self.tableView.separatorColor = .clear
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case 0:
			self.addRemoteTopicOrContent()
		case 1:
			self.dismiss(animated: true)
			self.parentVC?.performSegue(withIdentifier: "createNewTopicSegue", sender: nil)
		case 2:
			self.dismiss(animated: true)
			self.parentVC?.performSegue(withIdentifier: "cameraViewSegue", sender: nil)
		default: break
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.textLabel?.textColor = .white
		cell.tintColor = .white
		cell.backgroundColor = .popoverVCBackground
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "addContentCell", for: indexPath) as? CustomUITableViewCell else { return UITableViewCell() }
		
		switch indexPath.row {
		case 0:
			cell.imageView?.image = #imageLiteral(resourceName: "addTopicRemote")
			cell.textLabel?.text = "Download remote topic".localized
			cell.textLabel?.adjustsFontSizeToFitWidth = true
		case 1:
			cell.imageView?.image = #imageLiteral(resourceName: "addTopicCreate")
			cell.textLabel?.text = "Create topic".localized
			cell.textLabel?.adjustsFontSizeToFitWidth = true
		case 2:
			cell.imageView?.image = #imageLiteral(resourceName: "addTopicCamera")
			cell.textLabel?.text = "Read from camera".localized
			cell.textLabel?.adjustsFontSizeToFitWidth = true
		default: break
		}
		
		let view = UIView()
		view.backgroundColor = .popoverVCBackgroundSelected
		cell.selectedBackgroundView = view
		
		return cell
	}
	
	// Convenience

	private func addRemoteTopicOrContent() {
		
		let titleText = "New Topic"
		let messageText = "You can download a topic using a URL which contains the formatted content or paste the content directly."
		
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
							self.parentVC?.tableView.reloadData()
							
						}
					}
				}
			}
		}
		
		newTopicAlert.addAction(title: "Cancel".localized, style: .cancel)
		
		self.presentOnParent(newTopicAlert)
	}
}
