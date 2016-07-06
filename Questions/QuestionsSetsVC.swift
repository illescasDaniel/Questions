import UIKit

class QuestionsSetsVC: UITableViewController {
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "QUESTIONS_SET".localized(VC.language!)
	}
}
