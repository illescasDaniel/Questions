import UIKit

class LanguageVC: UITableViewController {

	var languages: [String] = ["ENGLISH".localized(VC.language!), "SPANISH".localized(VC.language!)]

	var noLanguageSelected = true

	static var selectedLanguageIndex: Int?

	var selectedLanguage: String? {
		didSet {
			if let language = selectedLanguage {
				LanguageVC.selectedLanguageIndex = languages.indexOf(language)!
			}
		}
	}

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return languages.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCellWithIdentifier("languageCell", forIndexPath: indexPath)
		cell.textLabel?.text = languages[indexPath.row]

		if indexPath.row == LanguageVC.selectedLanguageIndex {
			cell.accessoryType = .Checkmark
		} else {
			cell.accessoryType = .None
		}

		if noLanguageSelected {

			if (VC.language == "en" && indexPath == NSIndexPath(forRow: 0, inSection: 0)) ||
				(VC.language == "es" && indexPath == NSIndexPath(forRow: 1, inSection: 0)) {

				cell.accessoryType = .Checkmark
			}

			noLanguageSelected = false
		}

		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

		// Other row is selected - need to deselect it
		if let index = LanguageVC.selectedLanguageIndex {
			let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
			cell?.accessoryType = .None
		}

		selectedLanguage = languages[indexPath.row]

		// update the checkmark for the current row
		let cell = tableView.cellForRowAtIndexPath(indexPath)
		cell?.accessoryType = .Checkmark
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "SaveSelectedLanguage" {
			if let cell = sender as? UITableViewCell {
				let indexPath = tableView.indexPathForCell(cell)
				if let index = indexPath?.row {
					selectedLanguage = languages[index]
				}
			}
		}
	}

}
