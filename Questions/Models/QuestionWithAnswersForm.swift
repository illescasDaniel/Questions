//
//  QuestionWithAnswers.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 22/5/21.
//  Copyright © 2021 Daniel Illescas Romero. All rights reserved.
//

import Foundation

struct QuestionWithAnswersForm: Decodable {
	
	struct Answer: Decodable {
		let answer: String
		let isCorrect: Bool
	}
	
	let question: String
	let questionImage: String?
	let answers: [Answer]
}

typealias QuestionsWithAnswersIDs = [(questionID: String, questionImageID: String, answerIDs: [(answerValueID: String, isAnswerCorrectID: String)])]
