import UIKit

class QuestionsSetsViewController: UITableViewController {
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Question.nSets
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Questions set".localized
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier("selectQuestionSet", sender: indexPath.row + 1)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		if let set = sender as? Int where segue.identifier == "selectQuestionSet" {
			
			let controller = segue.destinationViewController as! QuestionViewController
			
			for i in 1...Question.nSets {
                if set == i {
                    controller.questions = Question.getSets(i)
                    break
                }
			}
			
		}
	}
    
    @IBAction func unwindToQuestionSetSelector(segue: UIStoryboardSegue) {
        
    }
}
