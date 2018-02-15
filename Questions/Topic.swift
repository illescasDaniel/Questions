import Foundation

struct QuestionType: Codable, Equatable {
	
	static func ==(lhs: QuestionType, rhs: QuestionType) -> Bool {
		return lhs.question == rhs.question && lhs.answers == rhs.answers && lhs.correct == rhs.correct
	}
	
	let question: String
	let answers: [String]
	let correct: UInt8
}

struct Quiz: Codable, Equatable {
	
	let quiz: [[QuestionType]]
	
	static func isValid(_ content: Quiz) -> Bool {
		
		guard !content.quiz.isEmpty else { return false }
		
		for topic in content.quiz {
			
			// ~ Number of answers must be consistent (otherwise don't make this restriction)
			let fullQuestionAnswersCount = topic.first?.answers.count ?? 4
			
			for fullQuestion in topic {
				
				guard !fullQuestion.question.isEmpty,
					fullQuestion.answers.count == fullQuestionAnswersCount,
					fullQuestion.correct < fullQuestionAnswersCount, fullQuestion.correct >= 0
				else { return false }
				
				var isAnswersLenghtCorrect = true
				fullQuestion.answers.forEach { answer in
					if answer.isEmpty { isAnswersLenghtCorrect = false }
				}
				
				guard isAnswersLenghtCorrect else { return false }
			}
		}

		return true
	}
	
	static func ==(lhs: Quiz, rhs: Quiz) -> Bool {
		
		let flatLhs = lhs.quiz.flatMap { return $0 }
		let flatRhs = rhs.quiz.flatMap { return $0 }
		
		return flatLhs == flatRhs
	}
}

struct Topic: Equatable, Hashable {
	
	private(set) var name = String()
	private(set) var content = Quiz(quiz: [[]])
	
	init(name: String, content: Quiz) {
		self.name = name
		self.content = content
	}
	
	init?(name: String) {
		
		self.name = name
		
		guard let path = Bundle.main.path(forResource: name, ofType: "json") else { print("Quiz incorrect path. Topic name: \(name)"); return }
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
			print("Error initializing quiz content. Quiz name: \(name)")
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
			print("Error initializing quiz content. Quiz path: \(path.lastPathComponent)")
		}
	}
	
	static func ==(lhs: Topic, rhs: Topic) -> Bool {
		return lhs.name == rhs.name || lhs.content == rhs.content
	}
	
	var hashValue: Int {
		return name.hashValue + (content.quiz.count * (content.quiz.first?.count ?? 1))
	}
}

struct SetOfTopics {
	
	static var shared = SetOfTopics()
	
	var topics: [Topic] = [] // Manually: [Topic(name: "Technology"), Topic(name: "Social"), Topic(name: "People")]
	var savedTopics: [Topic] = []
	
	var isUsingUserSavedTopics = false
	
	var currentTopics: [Topic] {
		return isUsingUserSavedTopics ? self.savedTopics : self.topics
	}

	// Automatically loads all .json files :)
	fileprivate init() {
		self.topics = Array(self.setOfTopicsFromJSONFilesOfDirectory(url: Bundle.main.bundleURL))
		self.loadSavedTopics()
		self.loadAllTopicsStates()
	}
	
	func loadAllTopicsStates() {
		self.loadSetState(for: self.topics)
		self.loadSetState(for: self.savedTopics)
	}
	
	func loadSetState(for topicSet: [Topic]) {
		
		for topic in topicSet {
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
	
	mutating func loadSavedTopics() {

		let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		self.savedTopics = Array(self.setOfTopicsFromJSONFilesOfDirectory(url: documentsURL))
		
		self.loadSetState(for: self.savedTopics)
	}
	
	private func setOfTopicsFromJSONFilesOfDirectory(url contentURL: URL?) -> Set<Topic> {
		
		let fileManager = FileManager.default
		
		if let validURL = contentURL, let contentOfFilesPath = (try? fileManager.contentsOfDirectory(at: validURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])) {
			
			var setOfSavedTopics = Set<Topic>()
			
			for url in contentOfFilesPath where url.pathExtension == "json" {
				if let validTopic = Topic(path: url) {
					setOfSavedTopics.insert(validTopic)
				}
			}
			return setOfSavedTopics
		}
		return Set<Topic>()
	}
}
