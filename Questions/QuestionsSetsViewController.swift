import UIKit

class QuestionsSetsViewController: UITableViewController {
	
	var sets: [String] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		sets = ["Social".localized,"Technology".localized,"People".localized]
    }

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("setCell")
		
		cell?.textLabel?.text = sets[indexPath.row]
		
		return cell!
	}

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets.count
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
			
			for i in 1...sets.count {
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
