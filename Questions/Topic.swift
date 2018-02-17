import Foundation

// change from struct to class
class QuestionType: Codable, Equatable {
	
	static func ==(lhs: QuestionType, rhs: QuestionType) -> Bool {
		return lhs.question == rhs.question && lhs.answers == rhs.answers && lhs.correctAnswers == rhs.correctAnswers
	}
	
	init(question: String, answers: [String], correct: Set<UInt8>, singleCorrect: UInt8? = nil) {
		self.question = question
		self.answers = answers
		self.correctAnswers = correct
		self.correct = singleCorrect
	}
	
	let question: String
	let answers: [String]
	var correctAnswers: Set<UInt8>! = []
	let correct: UInt8?
}

struct Quiz: Codable, Equatable {
	
	let topic: [[QuestionType]]
	
	static func isValid(_ content: Quiz) -> Bool {
		
		guard !content.topic.isEmpty else { return false }
		
		for setOfQuestions in content.topic {
			
			// ~ Number of answers must be consistent in the same set of questions (otherwise don't make this restriction, you might need to make other changes too)
			let fullQuestionAnswersCount = setOfQuestions.first?.answers.count ?? 4
			
			for fullQuestion in setOfQuestions {
				
				if fullQuestion.correctAnswers == nil { fullQuestion.correctAnswers = [] }
				
				guard !fullQuestion.question.isEmpty,
					fullQuestion.answers.count == fullQuestionAnswersCount,
					Set(fullQuestion.answers).count == fullQuestionAnswersCount,
					fullQuestion.correctAnswers?.filter({ $0 >= fullQuestionAnswersCount }).count == 0,
					(fullQuestion.correctAnswers?.count ?? 0) < fullQuestionAnswersCount
					else { return false }
				
				if let singleCorrectAnswers = fullQuestion.correct {
					if singleCorrectAnswers >= fullQuestionAnswersCount {
						return false
					} else {
						fullQuestion.correctAnswers?.insert(singleCorrectAnswers)
					}
				}
				
				guard let correctAnswers = fullQuestion.correctAnswers, correctAnswers.count < fullQuestionAnswersCount, correctAnswers.count > 0 else { return false }
				
				var isAnswersLenghtCorrect = true
				fullQuestion.answers.forEach { answer in
					if answer.isEmpty { isAnswersLenghtCorrect = false }
				}
				
				guard isAnswersLenghtCorrect else { return false }
			}
		}
		
		guard content.topic.filter({ $0.filter({ $0.correctAnswers == nil || $0.correctAnswers.count == 0 }).count > 0 }).count == 0 else { return false }

		return true
	}
	
	static func ==(lhs: Quiz, rhs: Quiz) -> Bool {
		
		let flatLhs = lhs.topic.flatMap { return $0 }
		let flatRhs = rhs.topic.flatMap { return $0 }
		
		return flatLhs == flatRhs
	}
}

struct Topic: Equatable, Hashable {
	
	private(set) var name = String()
	private(set) var content = Quiz(topic: [[]])
	
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
			return nil
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
			return nil
		}
	}
	
	static func ==(lhs: Topic, rhs: Topic) -> Bool {
		return lhs.name == rhs.name || lhs.content == rhs.content
	}
	
	var hashValue: Int {
		return name.hashValue + (content.topic.count * (content.topic.first?.count ?? 1))
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
			for quiz in topic.content.topic.enumerated() {
				
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
