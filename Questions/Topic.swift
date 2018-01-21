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
	
	init(path: URL) {
		self.name = path.deletingPathExtension().lastPathComponent
		do {
			let data = try Data(contentsOf: path)
			content = try JSONDecoder().decode(Quiz.self, from: data)
		} catch {
			print("Error initializing quiz content")
		}
	}
}

struct SetOfTopics {
	
	static let shared = SetOfTopics()
	var topics: [Topic] = [] // Manually: [Topic(name: "Technology"), Topic(name: "Social"), Topic(name: "People")]
	
	// Automatically loads all .json files :)
	fileprivate init() {
		if let bundleURL = URL(string: Bundle.main.bundlePath),
			let contentOfBundlePath = (try? FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])) {
			for url in contentOfBundlePath where url.pathExtension == "json" {
				self.topics.append(Topic(path: url))
			}
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
