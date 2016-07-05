import UIKit

class QuestionSet1VC: QuestionClass {

	@IBOutlet weak var questionLabel2: UILabel!
	@IBOutlet var answersLabels2: [UIButton]!
	@IBOutlet weak var endOfQuestions2: UILabel!
	@IBOutlet weak var statusLabel2: UILabel!

	override func viewDidLoad() {
		questions = getSet1()
		answersLabels = answersLabels2
		questionLabel = questionLabel2
		endOfQuestions = endOfQuestions2
		statusLabel = statusLabel2

		super.viewDidLoad()
	}

	@IBAction func answer1Action2(sender: UIButton) {
		super.answer1Action(answersLabels2[0])
	}
	@IBAction func answer2Action2(sender: UIButton) {
		super.answer2Action(answersLabels2[1])
	}
	@IBAction func answer3Action2(sender: UIButton) {
		super.answer3Action(answersLabels2[2])
	}
	@IBAction func answer4Action2(sender: UIButton) {
		super.answer4Action(answersLabels2[3])
	}
	
}
