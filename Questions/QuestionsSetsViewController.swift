import UIKit

class QuestionsSetsViewController: UITableViewController {

	@IBOutlet var table: UITableView!
	var sets: [String] = []
	var cell = UITableViewCell()

	override func viewDidLoad() {
		super.viewDidLoad()

		sets = ["Social".localized, "Technology".localized, "People".localized]
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sets.count
	}

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Questions set".localized
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		cell = tableView.dequeueReusableCellWithIdentifier("setCell")!

		cell.textLabel!.text = sets[indexPath.row]

		if QuestionViewController.completedSets[indexPath.row] {
			cell.accessoryType = .Checkmark
		}

		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier("selectQuestionSet", sender: indexPath.row)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

		if let set = sender as? Int where segue.identifier == "selectQuestionSet" {

			let controller = segue.destinationViewController as! QuestionViewController

			sets.forEach {
				if set == sets.indexOf($0) {
					controller.currentSet = set
				}
			}

		}
	}

	@IBAction func unwindToQuestionSetSelector(segue: UIStoryboardSegue) {

		for i in 0..<sets.count {
			if QuestionViewController.completedSets[i] {
				table.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: 0)], withRowAnimation: .Automatic)
			}
		}
	}

}
