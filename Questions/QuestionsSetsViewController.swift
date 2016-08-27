import UIKit

class QuestionsSetsViewController: UITableViewController {

	// MARK: Properties
	
	@IBOutlet weak var table: UITableView!
	var cell: UITableViewCell?
	var sets: [String] = []

	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		sets = ["Social".localized, "Technology".localized, "People".localized]
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
		
		return cell ?? UITableViewCell()
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "selectQuestionSet", sender: indexPath.row)
	}
	
	// MARK: UIStoryboardSegue Handling

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if let set = sender as? Int , segue.identifier == "selectQuestionSet" {

			let controller = segue.destination as! QuestionViewController

			sets.forEach {
				if set == sets.index(of: $0) {
					controller.currentSet = set
				}
			}
		}
	}

	@IBAction func unwindToQuestionSetSelector(_ segue: UIStoryboardSegue) {

		for i in 0..<Quiz.set.count {
			if Settings.sharedInstance.completedSets[i] {
				table.reloadRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
			}
		}
	}

}
