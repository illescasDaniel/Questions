//
//  Quiz.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 24/05/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import Foundation

struct Quiz: Codable {
	let options: Options?
	let sets: [[QuestionType]]
}

extension Quiz {
	struct Options: Codable {
		let name: String?
		let timePerSetInSeconds: TimeInterval?
		let helpButtonEnabled: Bool?
		let questionsInRandomOrder: Bool?
		let showCorrectIncorrectAnswer: Bool?
		let multipleCorrectAnswersAsMandatory: Bool?
		// case displayFullResults // YET to implement
	}
}

extension Quiz: Equatable {
	static func ==(lhs: Quiz, rhs: Quiz) -> Bool {
		let flatLhs = lhs.sets.flatMap { return $0 }
		let flatRhs = rhs.sets.flatMap { return $0 }
		return flatLhs == flatRhs
	}
}

extension Quiz {
	
	enum ValidationError: Error {
		case emptySet(count: Int)
		case emptyQuestion(set: Int, question: Int)
		case emptyAnswer(set: Int, question: Int, answer: Int)
		case incorrectAnswersCount(set: Int, question: Int)
		case incorrectCorrectAnswersCount(set: Int, question: Int, count: Int?)
		case incorrectCorrectAnswerIndex(set: Int, question: Int, badIndex: Int, maximum: Int)
	}
	
	func validate() -> ValidationError? {
		
		guard !self.sets.contains(where: { $0.isEmpty }) else { return .emptySet(count: self.sets.count) }
		
		for (indexSet, setOfQuestions) in self.sets.enumerated() {
			
			// ~ Number of answers must be consistent in the same set of questions (otherwise don't make this restriction, you might need to make other changes too)
			let fullQuestionAnswersCount = setOfQuestions.first?.answers.count ?? 4
			
			for (indexQuestion, fullQuestion) in setOfQuestions.enumerated() {
				
				if fullQuestion.correctAnswers == nil { fullQuestion.correctAnswers = [] }
				
				guard !fullQuestion.question.isEmpty else { return .emptyQuestion(set: indexSet+1, question: indexQuestion+1) }
				
				guard fullQuestion.answers.count == fullQuestionAnswersCount, Set(fullQuestion.answers).count == fullQuestionAnswersCount else {
					return .incorrectAnswersCount(set: indexSet+1, question: indexQuestion+1)
				}
				
				guard !fullQuestion.correctAnswers.contains(where: { $0 >= fullQuestionAnswersCount }),
					(fullQuestion.correctAnswers?.count ?? 0) < fullQuestionAnswersCount else {
						return .incorrectCorrectAnswersCount(set: indexSet+1, question: indexQuestion+1, count: fullQuestion.correctAnswers?.count)
				}
				
				if let singleCorrectAnswer = fullQuestion.correct {
					if singleCorrectAnswer >= fullQuestionAnswersCount {
						return .incorrectCorrectAnswerIndex(set: indexSet+1, question: indexQuestion+1, badIndex: Int(singleCorrectAnswer)+1, maximum: fullQuestionAnswersCount)
					} else {
						fullQuestion.correctAnswers?.insert(singleCorrectAnswer)
					}
				}
				
				guard let correctAnswers = fullQuestion.correctAnswers, correctAnswers.count < fullQuestionAnswersCount, correctAnswers.count > 0 else {
					return .incorrectCorrectAnswersCount(set: indexSet+1, question: indexQuestion+1, count: fullQuestion.correctAnswers?.count)
				}
				
				for (indexAnswer, answer) in fullQuestion.answers.enumerated() {
					if answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
						return .emptyAnswer(set: indexSet+1, question: indexQuestion+1, answer: indexAnswer+1)
					}
				}
			}
		}
		
		return nil
	}
}

extension Quiz.ValidationError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .emptySet(_):
			return "At least one set is empty.".localized
		case .emptyQuestion(_):
			return "At least one question is empty.".localized
		case .emptyAnswer(_):
			return "At least one answer is empty.".localized
		case .incorrectAnswersCount(_):
			return "The number of valid answers is incorrect, repeated answers are not allowed.".localized
		case .incorrectCorrectAnswersCount(_):
			return "The number of correct answers is incorrect.".localized
		case .incorrectCorrectAnswerIndex(_):
			return "The 'correct answer' index is incorrect.".localized
		}
	}
	var recoverySuggestion: String? {
		switch self {
		case .emptySet(let count):
			return String(format: "Sets count: %d".localized, count)
		case .emptyQuestion(let set, let question):
			return String(format: "[Location] Set: %d, question: %d".localized, set, question)
		case .emptyAnswer(let set, let question, let answer):
			return String(format: "[Location] Set: %d, question: %d, answer: %d".localized, set, question, answer)
		case .incorrectAnswersCount(let set, let question):
			return String(format: "[Location] Set: %d, question: %d".localized, set, question)
		case .incorrectCorrectAnswersCount(let set, let question, let count):
			return String(format: "[Location] Set: %d, question: %d, correct answers: %d".localized, set, question, count ?? 0)
		case .incorrectCorrectAnswerIndex(let set, let question, let badIndex, let maximum):
			return String(format: "[Location] Set: %d, question: %d, bad: %d, maximum: %d".localized, set, question, badIndex, maximum)
		}
	}
}
