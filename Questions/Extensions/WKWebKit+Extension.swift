//
//  WKWebKit+Extension.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 22/5/21.
//  Copyright © 2021 Daniel Illescas Romero. All rights reserved.
//

import WebKit

extension WKWebView {
	
	func inputValueFrom(id: String, completionHandler: @escaping (String?) -> Void) -> String? {
		self.evaluateJavaScript(#"document.getElementById("\#(id)").value"#) { value, error in
			completionHandler(value as? String)
		}
		return nil
	}
	
	func multipleInputValuesFrom(ids: [String], completionHandler: @escaping ([String?]) -> Void) {
		var getElementByIds: [String] = []
		for id in ids {
			getElementByIds.append(#"document.getElementById("\#(id)").value"#)
		}
		
		self.evaluateJavaScript("[\(getElementByIds.joined(separator: ", "))]") { jsValue, error in
			guard let values = jsValue as? Array<Any> else {
				completionHandler([])
				return
			}
			var stringValues: [String?] = []
			for value in values {
				stringValues.append(value as? String)
			}
			completionHandler(stringValues)
		}
	}
	
	func isCheckboxChecked(id: String, completionHandler: @escaping (Bool) -> Void) -> String? {
		self.evaluateJavaScript(#"document.getElementById("\#(id)").checked"#) { value, error in
			if let evaluatedOutput = value as? Bool, evaluatedOutput {
				completionHandler(true)
			} else {
				completionHandler(false)
			}
		}
		return nil
	}
	
	func checkedCheckboxes(ids: [String], completionHandler: @escaping ([Bool]) -> Void) {
		
		var getElementByIds: [String] = []
		for id in ids {
			getElementByIds.append(#"document.getElementById("\#(id)").checked"#)
		}
		
		self.evaluateJavaScript("[\(getElementByIds.joined(separator: ", "))]") { jsValue, error in
			guard let checkedCheckboxes = jsValue as? Array<Bool> else {
				completionHandler([])
				return
			}
			completionHandler(checkedCheckboxes)
		}
	}
	
	func questionAndAnswers(
		questionAndAnswersIDs: QuestionsWithAnswersIDs,
		completionHandler: @escaping ([QuestionWithAnswersForm]) -> Void
	) {
		
		var elementsByID: [String] = []
		for (questionID, questionImageID, answerIDs) in questionAndAnswersIDs {
			
			var answersByID: [String] = []
			
			for (answerID, isCorrectID) in answerIDs {
				answersByID.append(#"{ answer: document.getElementById("\#(answerID)").value, isCorrect: document.getElementById("\#(isCorrectID)").checked }"#)
			}
			let answers = "[\(answersByID.joined(separator: ", "))]"
			
			let questionImageByID = #"document.getElementById("\#(questionImageID)").value"#
			
			elementsByID.append(#"{ question: document.getElementById("\#(questionID)").value, questionImage: \#(questionImageByID), answers: \#(answers) }"#)
		}
		
		self.evaluateJavaScript("[\(elementsByID.joined(separator: ", "))]") { jsValue, error in
			guard let values = jsValue as? Array<Any> else {
				completionHandler([])
				return
			}
			
			let questionsWithAnswers = try? JSONDecoder().decode([QuestionWithAnswersForm].self, from: JSONSerialization.data(withJSONObject: values, options: .fragmentsAllowed))
		
			completionHandler(questionsWithAnswers ?? [])
		}
	}
}
