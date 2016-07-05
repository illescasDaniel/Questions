import UIKit
import Foundation
import AVFoundation

struct Question {
	var question: String
	var answers: [String] = []
	var answer: Int?
}

class QuestionClass: UIViewController {
	
	var correctSound: AVAudioPlayer?
	var incorrectSound: AVAudioPlayer?
	
	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet var answersLabels: [UIButton]!
	
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var endOfQuestions: UILabel!
	
	var correctAnswer = Int()
	var qNumber = Int()
	var questions: [Question] = [] // This value will be overwritten by the subclass in the viewDidLoad method
	
	func initialize(){
		statusLabel.alpha = 0.0
		endOfQuestions.alpha = 0.0
		
		pickQuestion()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initialize()
		
		endOfQuestions.text = "END_OF_QUESTIONS".localized(VC.language!)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func pickQuestion() {
		
		if !questions.isEmpty {
			
			qNumber = Int(arc4random_uniform(UInt32(questions.count)))
			
			questionLabel.text = questions[qNumber].question
			correctAnswer = questions[qNumber].answer!
			
			for i in 0..<answersLabels.count {
				answersLabels[i].setTitle(questions[qNumber].answers[i], forState: UIControlState.Normal)
			}
			
			questions.removeAtIndex(qNumber)
		}
		else {
			endOfQuestions.alpha = 1.0
		}
		
	}
	
	func verifyAnswer(answer: Int) {
		
		statusLabel.alpha = 1.0
		
		if answer == correctAnswer {
			statusLabel.textColor = UIColor.greenColor()
			statusLabel.text = "CORRECT_ANSWER".localized(VC.language!)
			
			// Play correct sound
			if let correctSound = setupAudioPlayerWithFile("correct", type:"mp3") {
				self.correctSound = correctSound
			}
			
			correctSound?.volume = 0.10
			correctSound?.play()
		}
		else {
			statusLabel.textColor = UIColor.redColor()
			statusLabel.text = "INCORRECT_ANSWER".localized(VC.language!)
			
			// Play incorrect sound
			if let incorrectSound = setupAudioPlayerWithFile("incorrect", type:"wav") {
				self.incorrectSound = incorrectSound
			}
			
			incorrectSound?.volume = 0.33
			incorrectSound?.play()
		}
		
		// Fade out animation for statusLabel
		UIView.animateWithDuration(1.5, animations: {self.statusLabel.alpha = 0.0})
		
		pickQuestion()
	}
	
	@IBAction func answer1Action(sender: UIButton) {
		verifyAnswer(0)
	}
	
	@IBAction func answer2Action(sender: UIButton) {
		verifyAnswer(1)
	}
	
	@IBAction func answer3Action(sender: UIButton) {
		verifyAnswer(2)
	}
	
	@IBAction func answer4Action(sender: UIButton) {
		verifyAnswer(3)
	}

}
