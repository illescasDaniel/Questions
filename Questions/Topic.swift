import Foundation

struct QuestionType: Codable, Equatable {
	
	static func ==(lhs: QuestionType, rhs: QuestionType) -> Bool {
		return lhs.question == rhs.question && lhs.answers == rhs.answers && lhs.correct == rhs.correct
	}
	
	let question: String
	let answers: [String]
	let correct: UInt8
}

struct Quiz: Codable {
	let quiz: [[QuestionType]]
}

struct Topic {
	
	private(set) var name = String()
	private(set) var content = Quiz(quiz: [[]])
	
	init(name: String) {
		
		self.name = name
		
		guard let path = Bundle.main.path(forResource: name, ofType: "json") else { print("Quiz incorrect path"); return }
		let url = URL(fileURLWithPath: path)
		
		do {
			let data = try Data(contentsOf: url)
			content = try JSONDecoder().decode(Quiz.self, from: data)
		} catch {
			print("Error initializing quiz content")
		}
	}

	static let topics = [Topic(name: "Technology"), Topic(name: "Social"), Topic(name: "People")]
	
	static func loadSets() {
		
		for topic in topics {
			for quiz in topic.content.quiz.enumerated() {
				
				if DataStore.shared.completedSets[topic.name] == nil {
					DataStore.shared.completedSets[topic.name] = [:]
				}
				
				if DataStore.shared.completedSets[topic.name]?[quiz.offset] == nil {
					DataStore.shared.completedSets[topic.name]?[quiz.offset] = false
				}
			}
		}
	}
}
