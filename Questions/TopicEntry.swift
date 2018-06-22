//
//  TopicEntry.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 24/05/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import Foundation

struct TopicEntry {
	
	private(set) var displayedName = String()
	var quiz = Quiz(options: nil, sets: [[]])
	
	init(name: String, content: Quiz) {
		self.displayedName = name
		self.quiz = content
	}
	
	init?(name: String) {
		
		self.displayedName = name
		
		guard let path = Bundle.main.path(forResource: name, ofType: "json") else { print("Quiz incorrect path. Topic name: \(name)"); return }
		let url = URL(fileURLWithPath: path)
		
		do {
			let data = try Data(contentsOf: url)
			let contentToValidate = try JSONDecoder().decode(Quiz.self, from: data)
			
			switch contentToValidate.validate() {
			case .none:
				self.quiz = contentToValidate
			case .some(let error):
				print("Error loading \"\(name)\" topic: \(error.localizedDescription).\nDetails: \(error.recoverySuggestion ?? "")")
				return nil
			}
			
		} catch {
			print("Error initializing quiz content. Quiz name: \(name)")
			return nil
		}
	}
	
	init?(path: URL) {
		do {
			let data = try Data(contentsOf: path)
			let contentToValidate = try JSONDecoder().decode(Quiz.self, from: data)
			
			if let topicName = self.quiz.options?.name, !topicName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				self.displayedName = topicName
			} else {
				self.displayedName = path.deletingPathExtension().lastPathComponent
			}
			
			switch contentToValidate.validate() {
			case .none:
				self.quiz = contentToValidate
			case .some(let error):
				print("Error loading \"\(self.displayedName)\" topic: \(error.localizedDescription)\nDetails: \(error.recoverySuggestion ?? "")")
				return nil
			}
		} catch {
			print(error)
			print("Error initializing quiz content. Quiz path: \(path.lastPathComponent)")
			return nil
		}
	}
}

extension TopicEntry: Equatable {
	static func ==(lhs: TopicEntry, rhs: TopicEntry) -> Bool {
		return lhs.displayedName == rhs.displayedName || lhs.quiz == rhs.quiz
	}
}

extension TopicEntry: Hashable {
	var hashValue: Int {
		return displayedName.hashValue + (quiz.sets.count * (quiz.sets.first?.count ?? 1))
	}
}
