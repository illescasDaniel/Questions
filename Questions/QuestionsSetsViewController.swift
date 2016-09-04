import UIKit

class QuestionsSetsViewController: UITableViewController {

	// MARK: Properties
	
	var cell: UITableViewCell?
	var sets: [String] = []
	let darkThemeEnabled = Settings.sharedInstance.darkThemeEnabled

	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		sets = ["Social".localized, "Technology".localized, "People".localized]
		
		tableView.backgroundColor = darkThemeEnabled ? UIColor.darkGray : UIColor.defaultBGcolor
		tableView.separatorColor = darkThemeEnabled ? UIColor.darkGray : UIColor.defaultSeparatorColor
	}

	// MARK: UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sets.count
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Questions set".localized
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		cell = tableView.dequeueReusableCell(withIdentifier: "setCell")
		cell?.textLabel?.text = sets[indexPath.row]
		
		if Settings.sharedInstance.completedSets[indexPath.row] {
			cell?.accessoryType = .checkmark
		}
		
		// THEME 
		cell?.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
		cell?.textLabel?.textColor = darkThemeEnabled ? UIColor.white : UIColor.black
		cell?.backgroundColor = darkThemeEnabled ? UIColor.gray : UIColor.white
		cell?.tintColor = darkThemeEnabled ? UIColor.orange : UIColor.defaultTintColor
		
		return cell ?? UITableViewCell()
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "selectQuestionSet", sender: indexPath.row)
	}
	
	// MARK: UITableViewDelegate

	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		let footer = view as! UITableViewHeaderFooterView
		footer.textLabel?.textColor = darkThemeEnabled ? UIColor.lightGray : UIColor.gray
	}
	
	// MARK: UIStoryboardSegue Handling

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if let set = sender as? Int , segue.identifier == "selectQuestionSet" {
			let controller = segue.destination as! QuestionViewController
			controller.currentSet = set
		}
	}

	@IBAction func unwindToQuestionSetSelector(_ segue: UIStoryboardSegue) {

		for i in 0..<sets.count where Settings.sharedInstance.completedSets[i] {
			tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
		}
	}
}
