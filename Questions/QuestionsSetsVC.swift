import UIKit

class QuestionsSetsVC: UITableViewController {
	
	@IBOutlet weak var questionsSetsNavItem: UINavigationItem!
	@IBOutlet weak var specialSet: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		questionsSetsNavItem.title = "QUESTIONS_SET".localized(VC.language!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

}
