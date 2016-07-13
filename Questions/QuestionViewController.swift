import UIKit
import Foundation
import AVFoundation
import CoreGraphics

class QuestionViewController : UIViewController {
	var correctSound: AVAudioPlayer?
	var incorrectSound: AVAudioPlayer?
	
	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet var answersLabels: [UIButton]!
	@IBOutlet var pauseButton: UIButton!
	
	@IBOutlet var pauseMenu: UIView!
	@IBOutlet var goBack: UIButton!
	@IBOutlet var muteMusic: UIButton!
	@IBOutlet var mainMenu: UIButton!
	
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var endOfQuestions: UILabel!
	
	var correctAnswer = Int()
	var qNumber = Int()
	var questions: [Question] = [] // This value will be overwritten later
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		pauseMenu.hidden = true
		
		statusLabel.alpha = 0.0
		
		endOfQuestions.hidden = true
		endOfQuestions.text = "End of questions".localized
		
		if ((MainViewController.bgMusic?.playing) != nil) {
			muteMusic.setTitle("Mute music".localized, forState: .Normal)
		}
		else {
			muteMusic.setTitle("Play music".localized, forState: .Normal)
		}
		
		goBack.setTitle("Go back".localized, forState: .Normal)
		mainMenu.setTitle("Main menu".localized, forState: .Normal)
		pauseButton.setTitle("Pause".localized, forState: .Normal)
		
		pickQuestion()
	}

	func pickQuestion() {
		
		if !questions.isEmpty {
			
			qNumber = Int(arc4random_uniform(UInt32(questions.count)))
			
			questionLabel.text = questions[qNumber].question
			correctAnswer = questions[qNumber].answer!
			
			for i in 0..<answersLabels.count {
				answersLabels[i].setTitle(questions[qNumber].answers[i], forState: .Normal)
			}
			
			questions.removeAtIndex(qNumber)
		}
		else {
			endOfQuestions.hidden = false
		}
		
	}
	
	func verifyAnswer(answer: Int) {
		
		statusLabel.alpha = 1.0
		
		if answer == correctAnswer {
			statusLabel.textColor = .greenColor()
			statusLabel.text = "Correct!".localized
			
			// Play correct sound
			if let correctSound = AVAudioPlayer(file:"correct", type:"mp3") {
				self.correctSound = correctSound
			}
			
			correctSound?.volume = 0.10
			correctSound?.play()
		}
		else {
			statusLabel.textColor = .redColor()
			statusLabel.text = "Incorrect".localized
			
			// Play incorrect sound
			if let incorrectSound = AVAudioPlayer(file:"incorrect", type:"wav") {
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

	@IBAction func pauseMenu(sender: AnyObject) {
		
		for i in 0..<answersLabels.count {
			answersLabels[i].enabled = answersLabels[i].enabled ? false : true
		}

		pauseMenu.hidden = pauseMenu.hidden ? false : true
	}
	
	@IBAction func muteMusicAction(sender: UIButton) {
		
		if let bgMusic = MainViewController.bgMusic {
			if bgMusic.playing {
				bgMusic.stop()
				muteMusic.setTitle("Play music".localized, forState: .Normal)
			}
			else {
				bgMusic.play()
				muteMusic.setTitle("Mute music".localized, forState: .Normal)
			}
		}
		
	}
}
