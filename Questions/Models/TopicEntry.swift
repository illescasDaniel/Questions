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
	var topic = Topic(options: nil, sets: [[]])
	
	init(name: String, content: Topic) {
		self.displayedName = name
		self.topic = content
	}
	
	init?(path: URL) {
		
		let data = try? Data(contentsOf: path)
		
		if let topicName = self.topic.options?.name, !topicName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			self.displayedName = topicName
		} else {
			self.displayedName = path.deletingPathExtension().lastPathComponent
		}
		
		if let topic = self.validatedQuiz(data: data, name: self.displayedName) {
			self.topic = topic
		} else {
			return nil
		}
	}
	
	private func validatedQuiz(data: Data?, name: String) -> Topic? {
		
		guard let data = data else { return nil }
		
		do {
			let contentToValidate = try JSONDecoder().decode(Topic.self, from: data)
			
			switch contentToValidate.validate() {
			case .none:
				return contentToValidate
			case .some(let error):
				print(#"Error loading "\#(name)" topic: \#(error.localizedDescription).\nDetails: \#(error.recoverySuggestion ?? "")"#)
				return nil
			}
		} catch {
			print("Error initializing quiz content. Quiz name: \(name)")
			return nil
		}
	}
}

extension TopicEntry: Equatable {
	static func ==(lhs: TopicEntry, rhs: TopicEntry) -> Bool {
		return lhs.displayedName == rhs.displayedName || lhs.topic == rhs.topic
	}
}

extension TopicEntry: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(displayedName.hashValue)
		hasher.combine(topic.sets.count * (topic.sets.first?.count ?? 1))
	}
}
