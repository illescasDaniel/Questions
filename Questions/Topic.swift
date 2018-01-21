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
	
	static func isValid(_ content: Quiz) -> Bool {
		
		guard !content.quiz.isEmpty else { return false }
		
		for topic in content.quiz {
			for fullQuestion in topic {
				
				guard !fullQuestion.question.isEmpty, fullQuestion.answers.count == 4, fullQuestion.correct < 4, fullQuestion.correct >= 0 else { return false }
				
				var isAnswersLenghtCorrect = true
				fullQuestion.answers.forEach { answer in
					if answer.isEmpty { isAnswersLenghtCorrect = false }
				}
				
				guard isAnswersLenghtCorrect else { return false }
			}
		}

		return true
	}
}

struct Topic: Equatable, Hashable {
	
	private(set) var name = String()
	private(set) var content = Quiz(quiz: [[]])
	
	init?(name: String) {
		
		self.name = name
		
		guard let path = Bundle.main.path(forResource: name, ofType: "json") else { print("Quiz incorrect path"); return }
		let url = URL(fileURLWithPath: path)
		
		do {
			let data = try Data(contentsOf: url)
			let contentToValidate = try JSONDecoder().decode(Quiz.self, from: data)
			if Quiz.isValid(contentToValidate) {
				self.content = contentToValidate
			} else {
				return nil
			}
		} catch {
			print("Error initializing quiz content")
		}
	}
	
	init?(path: URL) {
		self.name = path.deletingPathExtension().lastPathComponent
		do {
			let data = try Data(contentsOf: path)

			let contentToValidate = try JSONDecoder().decode(Quiz.self, from: data)
			if Quiz.isValid(contentToValidate) {
				self.content = contentToValidate
			} else {
				return nil
			}
		} catch {
			print("Error initializing quiz content")
		}
	}
	
	// Could change in the future, but for now DataStore saves the state of Topics sets using a dictionary and they can't have the same name
	// Also two same names would confuse if two topics had the same name and maybe you can't even save two json files with the same name either
	static func ==(lhs: Topic, rhs: Topic) -> Bool {
		return lhs.name == rhs.name
	}
	
	var hashValue: Int {
		return name.hashValue
	}
}

struct SetOfTopics {
	
	static let shared = SetOfTopics()
	var topics: [Topic] = [] // Manually: [Topic(name: "Technology"), Topic(name: "Social"), Topic(name: "People")]
	
	// Automatically loads all .json files :)
	fileprivate init() {
		
		if let bundleURL = URL(string: Bundle.main.bundlePath),
			let contentOfBundlePath = (try? FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])) {
			
			var setOfTopics = Set<Topic>()
			
			for url in contentOfBundlePath where url.pathExtension == "json" {
				if let validTopic = Topic(path: url) {
					setOfTopics.insert(validTopic)
				}
			}
			self.topics = Array(setOfTopics)
		}
		self.loadSets()
	}
	
	func loadSets() {
		
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
