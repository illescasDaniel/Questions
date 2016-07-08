import UIKit

class QuestionsSetsVC: UITableViewController {
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QuestionClass.nSets
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "QUESTIONS_SET".localized(VC.language!)
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let set = String(indexPath.row + 1)
		
		switch indexPath.row {
		case 0:
			performSegueWithIdentifier("selectQuestionSet", sender: set)
			
		case 1:
			performSegueWithIdentifier("selectQuestionSet", sender: set)
		
		case 2:
			performSegueWithIdentifier("selectQuestionSet", sender: set)
			
		default:
			performSegueWithIdentifier("selectQuestionSet", sender: "1")
		}
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		if segue.identifier == "selectQuestionSet" {
			
			let controller = segue.destinationViewController as! QuestionClass
			
			for i in 1...QuestionClass.nSets {
				
				if let set = sender {
					if String(set) == String(i) {
						controller.questions = getSets(i)
						break
					}
				}
				
			}
			
		}
	}
	
}
