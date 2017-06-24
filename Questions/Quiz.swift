import Foundation

struct QuestionType: Codable, Equatable {
	
	static func ==(lhs: QuestionType, rhs: QuestionType) -> Bool {
		return lhs.question == rhs.question && lhs.answers == rhs.answers && lhs.correct == rhs.correct
	}
	
	let question: String
	let answers: [String]
	let correct: UInt8
	
}

struct Question: Codable {
	let quiz: [[QuestionType]]
}

struct Quiz {
	
	private(set) var name = String()
	private(set) var content = Question(quiz: [[]])
	
	init(name: String) {
		
		self.name = name
		
		guard let path = Bundle.main.path(forResource: name, ofType: "json") else { print("Quiz incorrect path"); return }
		let url = URL(fileURLWithPath: path)
		
		do {
			let data = try Data(contentsOf: url)
			content = try JSONDecoder().decode(Question.self, from: data)
		} catch {
			print("Error initializing quiz content")
		}
	}

	static let quizzes = [Quiz(name: "Technology"), Quiz(name: "Social"), Quiz(name: "People")]
}
