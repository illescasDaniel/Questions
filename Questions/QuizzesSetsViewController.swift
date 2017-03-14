import UIKit

class QuizzesSetsViewController: UITableViewController {

	// MARK: Properties
	
	var cell: UITableViewCell?
	let setNames = Quiz.setNames
	let darkThemeEnabled = Settings.sharedInstance.darkThemeEnabled

	// MARK: View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = "Quizzes sets".localized
		
		tableView.backgroundColor = darkThemeEnabled ? .darkGray : .defaultBGcolor
		tableView.separatorColor = darkThemeEnabled ? .darkGray : .defaultSeparatorColor
	}

	// MARK: UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return setNames.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		cell = tableView.dequeueReusableCell(withIdentifier: "setCell")
		cell?.textLabel?.text = setNames[indexPath.row].localized
		
		// Load theme 
		cell?.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
		cell?.textLabel?.textColor = darkThemeEnabled ? .white : .black
		cell?.backgroundColor = darkThemeEnabled ? .gray : .white
		cell?.tintColor = darkThemeEnabled ? .orange : .defaultTintColor
		
		return cell ?? UITableViewCell()
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "selectQuizSet", sender: indexPath.row)
	}
	
	// MARK: UIStoryboardSegue Handling

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if let set = sender as? Int , segue.identifier == "selectQuizSet" {
			let controller = segue.destination as! QuestionsSetsViewController
			controller.currentQuiz = set
		}
	}
}
