//
//  QuestionType.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 24/05/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import Foundation

class Question: Codable, CustomStringConvertible {
	
	let question: String
	let answers: [String]
	var correctAnswers: Set<UInt8>! = []
	let correct: UInt8?
	let imageURL: String?
	
	init(question: String, answers: [String], correct: Set<UInt8>, singleCorrect: UInt8? = nil, imageURL: String? = nil) {
		self.question = question.trimmingCharacters(in: .whitespacesAndNewlines)
		self.answers = answers.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
		self.correctAnswers = correct
		self.correct = singleCorrect
		self.imageURL = imageURL?.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}

extension Question: Equatable {
	static func ==(lhs: Question, rhs: Question) -> Bool {
		return lhs.question == rhs.question && lhs.answers == rhs.answers && lhs.correctAnswers == rhs.correctAnswers
	}
}

extension Question: Hashable {
	var hashValue: Int {
		return question.hash
	}
}
