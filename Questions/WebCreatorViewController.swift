//
//  WebCreatorViewController.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 20/05/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import UIKit

extension UIWebView {
	func getInputValueFrom(id: String) -> String? {
		return self.stringByEvaluatingJavaScript(from: "document.getElementById(\"\(id)\").value")
	}
	func isCheckboxChecked(id: String) -> Bool {
		return self.stringByEvaluatingJavaScript(from: "document.getElementById(\"\(id)\").checked") == "true"
	}
}

class WebCreatorViewController: UIViewController, UIWebViewDelegate {

	@IBOutlet weak var webView: UIWebView!
	
	var questionsCreatorWrapper: QuestionsCreatorWrapper?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.setupWebView()
		self.promptUserWithFormGenerator()
    }
	
	// MARK: - Web view Delegate

	func webViewDidFinishLoad(_ webView: UIWebView) {
		self.webView.stringByEvaluatingJavaScript(from: "document.documentElement.style.webkitUserSelect='none'")
		self.webView.stringByEvaluatingJavaScript(from: "document.documentElement.style.webkitTouchCallout='none'")
	}
	
	/// We'll retrieve the info from the form, validate it and promt the user what to do with it
	@IBAction func outputBarButtonAction(_ sender: UIBarButtonItem) {
		
		guard let questionsCreatorWrapper = self.questionsCreatorWrapper else { return }
		
		let name = self.webView.getInputValueFrom(id: "topic-name")
		let topicTime = self.webView.getInputValueFrom(id: "topic-time") ?? ""
		let timePerSetInSeconds = TimeInterval(topicTime)
		let questionsInRandomOrder = self.webView.isCheckboxChecked(id: "topic-random-order")
		let helpButtonEnabled = self.webView.isCheckboxChecked(id: "topic-help-button")
		let showCorrectIncorrectAnwer = self.webView.isCheckboxChecked(id: "topic-correct-answer")
		let multipleCorrectAnswersAsMandatory = self.webView.isCheckboxChecked(id: "topic-force-choose")
		
		let options = Quiz.Options(name: name, timePerSetInSeconds: timePerSetInSeconds, helpButtonEnabled: helpButtonEnabled, questionsInRandomOrder: questionsInRandomOrder, showCorrectIncorrectAnswer: showCorrectIncorrectAnwer, multipleCorrectAnswersAsMandatory: multipleCorrectAnswersAsMandatory)
		
		var sets: [[QuestionType]] = []
		
		for i in 1...questionsCreatorWrapper.numberOfSets {
			
			var questions: [QuestionType] = []
			
			for j in 1...questionsCreatorWrapper.questionsPerSet {
				
				guard let questionText = self.webView.getInputValueFrom(id: "question-text-\(i)-\(j)")?.trimmingCharacters(in: .whitespacesAndNewlines), !questionText.isEmpty else {
					let error = Quiz.ValidationError.emptyQuestion(set: Int(i), question: Int(j))
					self.invalidQuizAlert(title: error.localizedDescription, message: error.recoverySuggestion)
					return
				}
				
				let imageURL = self.webView.getInputValueFrom(id: "question-image-\(i)-\(j)")?.trimmingCharacters(in: .whitespacesAndNewlines)
				var answers: [String] = []
				var correct: Set<UInt8> = []
				
				for k in 1...questionsCreatorWrapper.answersPerQuestion {
					if let answerText = self.webView.getInputValueFrom(id: "answer-\(i)-\(j)-\(k)") {
						let trimmedAnswer = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
						if !trimmedAnswer.isEmpty {
							answers.append(trimmedAnswer)
						} else {
							let error = Quiz.ValidationError.emptyAnswer(set: Int(i), question: Int(j), answer: Int(k))
							self.invalidQuizAlert(title: error.localizedDescription, message: error.recoverySuggestion)
							return
						}
					}
					if self.webView.isCheckboxChecked(id: "answer-correct-\(i)-\(j)-\(k)") {
						correct.insert(k-1)
					}
				}
				guard !correct.isEmpty else {
					let error = Quiz.ValidationError.incorrectCorrectAnswersCount(set: Int(i), question: Int(j), count: 0)
					self.invalidQuizAlert(title: error.localizedDescription, message: error.recoverySuggestion)
					return
				}
				guard !answers.isEmpty, answers.count == Int(questionsCreatorWrapper.answersPerQuestion) else {
					let error = Quiz.ValidationError.incorrectAnswersCount(set: Int(i), question: Int(j))
					self.invalidQuizAlert(title: error.localizedDescription, message: error.recoverySuggestion)
					return
				}
				
				questions.append(QuestionType(question: questionText, answers: answers, correct: correct, imageURL: imageURL))
			}
			
			sets.append(questions)
		}
		
		let quiz = Quiz(options: options, sets: sets)
		
		switch quiz.validate() {
		case .none:
			if quiz.sets.count == Int(questionsCreatorWrapper.numberOfSets)
				&& (quiz.sets.first?.count ?? 0) == Int(questionsCreatorWrapper.questionsPerSet)
				&& (quiz.sets.first?.first?.answers.count ?? 0) == Int(questionsCreatorWrapper.answersPerQuestion) {
				self.topicActionAlert(quiz: quiz)
				return
			}
			
		case .some(let error):
			self.invalidQuizAlert(title: error.localizedDescription, message: error.recoverySuggestion)
		}
		
		self.invalidQuizAlert()
	}
	
	// MARK: - Convenience
	
	private func setupWebView() {
		self.webView.delegate = self
		self.webView.scrollView.showsHorizontalScrollIndicator = false
		self.webView.backgroundColor = .themeStyle(dark: .black, light: .white)
		self.view.backgroundColor = .themeStyle(dark: .black, light: .white)
	}
	
	private func promptUserWithFormGenerator() {
		let questionsCreatorSetupAlert = UIAlertController(title: "Create Topic".localized, message: nil, preferredStyle: .alert)
		
		questionsCreatorSetupAlert.addTextField { textField in
			textField.placeholder = "Number of sets".localized
			textField.keyboardType = .numberPad
			textField.keyboardAppearance = UserDefaultsManager.darkThemeSwitchIsOn ? .dark : .light
			textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 25))
		}
		questionsCreatorSetupAlert.addTextField { textField in
			textField.placeholder = "Questions per set".localized
			textField.keyboardType = .numberPad
			textField.keyboardAppearance = UserDefaultsManager.darkThemeSwitchIsOn ? .dark : .light
			textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 25))
		}
		questionsCreatorSetupAlert.addTextField { textField in
			textField.placeholder = "Answers per question".localized
			textField.keyboardType = .numberPad
			textField.keyboardAppearance = UserDefaultsManager.darkThemeSwitchIsOn ? .dark : .light
			textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 25))
		}
		questionsCreatorSetupAlert.addAction(title: "Cancel".localized, style: .cancel) { _ in
			self.navigationController?.popViewController(animated: true)
		}
		questionsCreatorSetupAlert.addAction(title: "Generate form".localized, style: .default) { action in
			
			if let textFields = questionsCreatorSetupAlert.textFields, textFields.count == 3, !textFields.contains(where: { !$0.hasText }),
				let numberOfSetsStr = textFields[0].text, let numberOfSets = UInt8(numberOfSetsStr),
				let questionsPerSetStr = textFields[1].text, let questionsPerSet = UInt8(questionsPerSetStr),
				let answersPerQuestionStr = textFields[2].text, let answersPerQuestion = UInt8(answersPerQuestionStr),
				numberOfSets > 0, questionsPerSet > 0, answersPerQuestion > 1 {
				
				self.questionsCreatorWrapper = QuestionsCreatorWrapper(numberOfSets: numberOfSets, questionsPerSet: questionsPerSet, answersPerQuestion: answersPerQuestion)
				self.webView.loadHTMLString(self.questionsCreatorWrapper?.web ?? "", baseURL: nil)
			}
			else {
				// TODO: tell somehow the user that the input values were incorrect
				self.navigationController?.popViewController(animated: true)
			}
		}
		self.present(questionsCreatorSetupAlert, animated: true)
	}
	
	private func topicActionAlert(quiz: Quiz) {
		
		let whatToDoAlertController = UIAlertController(title: "What to do with the topic".localized, message: nil, preferredStyle: .alert)
		whatToDoAlertController.addAction(title: "Wait! I'm not done".localized, style: .cancel)
		whatToDoAlertController.addAction(title: "Save".localized, style: .default) { _ in
			DispatchQueue.global().async {
				let savedCorrectly = SetOfTopics.shared.save(topic: TopicEntry(name: quiz.options?.name ?? "", content: quiz))
				let message = savedCorrectly ? "Saved" : "Error while saving"
				DispatchQueue.main.async {
					let alertVC = UIAlertController(title: message.localized, message: nil, preferredStyle: .alert)
					self.present(alertVC, animated: true) {
						DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(215)) {
							alertVC.dismiss(animated: true)
						}
					}
				}
			}
		}
		
		whatToDoAlertController.addAction(title: "Share".localized, style: .default) { _ in
			if let data = try? JSONEncoder().encode(quiz), let jsonQuiz = String(data: data, encoding: .utf8) {
				let size = min(self.view.bounds.width, self.view.bounds.height)
				if let outputQR = jsonQuiz.generateQRImageWith(size: (width: size, height: size)) {
					let activityVC = UIActivityViewController(activityItems: [outputQR, jsonQuiz], applicationActivities: nil)
					activityVC.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
					self.present(activityVC, animated: true)
				}
			}
		}
		self.present(whatToDoAlertController, animated: true)
	}
	
	private func invalidQuizAlert(title: String = "", message: String? = nil) {
		let alertVC = UIAlertController(title: title.isEmpty ? "Invalid topic".localized : title, message: message ?? nil, preferredStyle: .alert)
		alertVC.addAction(title: "OK", style: .default)
		self.present(alertVC, animated: true)
	}
}
