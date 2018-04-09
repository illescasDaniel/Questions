import Foundation

// change from struct to class
class QuestionType: Codable, Equatable {
	
	static func ==(lhs: QuestionType, rhs: QuestionType) -> Bool {
		return lhs.question == rhs.question && lhs.answers == rhs.answers && lhs.correctAnswers == rhs.correctAnswers
	}
	
	init(question: String, answers: [String], correct: Set<UInt8>, singleCorrect: UInt8? = nil, imageURL: String? = nil) {
		self.question = question.trimmingCharacters(in: .whitespacesAndNewlines)
		self.answers = answers.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
		self.correctAnswers = correct
		self.correct = singleCorrect
		self.imageURL = imageURL?.trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
	let question: String
	let answers: [String]
	var correctAnswers: Set<UInt8>! = []
	let correct: UInt8?
	let imageURL: String?
}

struct QuizOptions: Codable {
	let name: String?
	let timePerSetInSeconds: TimeInterval?
	let helpButtonEnabled: Bool?
	let questionsInRandomOrder: Bool?
	let showCorrectIncorrectAnswer: Bool?
	// case displayFullResults // YET to implement
}

struct Quiz: Codable, Equatable {
	
	let options: QuizOptions?
	let sets: [[QuestionType]]

	static func isValid(_ content: Quiz) -> Bool {

		guard !content.sets.isEmpty else { return false }
		
		for setOfQuestions in content.sets {
			
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
		
		guard content.sets.filter({ $0.filter({ $0.correctAnswers == nil || $0.correctAnswers.count == 0 }).count > 0 }).count == 0 else { return false }

		return true
	}
	
	static func ==(lhs: Quiz, rhs: Quiz) -> Bool {
		
		let flatLhs = lhs.sets.flatMap { return $0 }
		let flatRhs = rhs.sets.flatMap { return $0 }
		
		return flatLhs == flatRhs
	}
}

struct TopicEntry: Equatable, Hashable {
	
	private(set) var name = String()
	private(set) var quiz = Quiz(options: nil, sets: [[]])
	
	init(name: String, content: Quiz) {
		self.name = name
		self.quiz = content
	}
	
	init?(name: String) {
		
		self.name = name
		
		guard let path = Bundle.main.path(forResource: name, ofType: "json") else { print("Quiz incorrect path. Topic name: \(name)"); return }
		let url = URL(fileURLWithPath: path)
		
		do {
			let data = try Data(contentsOf: url)
			let contentToValidate = try JSONDecoder().decode(Quiz.self, from: data)
			
			if Quiz.isValid(contentToValidate) {
				self.quiz = contentToValidate
			} else {
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
			
			if Quiz.isValid(contentToValidate) {
				
				self.quiz = contentToValidate
				
				if let topicName = self.quiz.options?.name, !topicName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
					self.name = topicName
				} else {
					self.name = path.deletingPathExtension().lastPathComponent
				}
				
			} else {
				return nil
			}
		} catch {
			print("Error initializing quiz content. Quiz path: \(path.lastPathComponent)")
			return nil
		}
	}
	
	static func ==(lhs: TopicEntry, rhs: TopicEntry) -> Bool {
		return lhs.name == rhs.name || lhs.quiz == rhs.quiz
	}
	
	var hashValue: Int {
		return name.hashValue + (quiz.sets.count * (quiz.sets.first?.count ?? 1))
	}
}

struct SetOfTopics {
	
	static var shared = SetOfTopics()
	
	var topics: [TopicEntry] = [] // Manually: [TopicEntry(name: "Technology"), TopicEntry(name: "Social"), TopicEntry(name: "People")]
	var savedTopics: [TopicEntry] = []
	
	var isUsingUserSavedTopics = false
	
	var currentTopics: [TopicEntry] {
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
	
	func loadSetState(for topicSet: [TopicEntry]) {
		
		for topic in topicSet {
			for quiz in topic.quiz.sets.enumerated() {
				
				if DataStoreArchiver.shared.completedSets[topic.name] == nil {
					DataStoreArchiver.shared.completedSets[topic.name] = [:]
				}
				
				if DataStoreArchiver.shared.completedSets[topic.name]?[quiz.offset] == nil {
					DataStoreArchiver.shared.completedSets[topic.name]?[quiz.offset] = false
				}
			}
		}
	}
	
	mutating func loadSavedTopics() {

		let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		self.savedTopics = Array(self.setOfTopicsFromJSONFilesOfDirectory(url: documentsURL))
		
		self.loadSetState(for: self.savedTopics)
	}
	
	func save(topic: TopicEntry) {
		// Won't save topics/set of questions with the same content
		guard !SetOfTopics.shared.savedTopics.contains(topic) else { return }
		
		let fileName: String
		let topicName = topic.name
		if topicName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			if let topicNameFromJSON = topic.quiz.options?.name, !topicNameFromJSON.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				fileName = topicNameFromJSON.trimmingCharacters(in: .whitespacesAndNewlines) + ".json"
			} else {
				fileName = "User Topic - \(UserDefaultsManager.savedQuestionsCounter).json" // Could be translated...
			}
		}
		else if !topicName.hasSuffix(".json") {
			fileName = topicName + ".json"
		} else {
			fileName = topicName
		}
		
		if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) {
			if let data = try? JSONEncoder().encode(topic.quiz) {
				try? data.write(to: documentsURL)
				UserDefaultsManager.savedQuestionsCounter += 1
				SetOfTopics.shared.loadSavedTopics()
			}
		}
	}
	
	func quizFrom(content: String?) -> Quiz? {
		
		if let data = content?.data(using: .utf8),
			let quizContent = try? JSONDecoder().decode(Quiz.self, from: data),
			Quiz.isValid(quizContent) {

			return quizContent
		}
		return nil
	}
	
	// MARK: - Convenience
	
	private func setOfTopicsFromJSONFilesOfDirectory(url contentURL: URL?) -> Set<TopicEntry> {
		
		let fileManager = FileManager.default
		
		if let validURL = contentURL, let contentOfFilesPath = (try? fileManager.contentsOfDirectory(at: validURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])) {
			
			var setOfSavedTopics = Set<TopicEntry>()
			
			for url in contentOfFilesPath where url.pathExtension == "json" {
				if let validTopic = TopicEntry(path: url) {
					setOfSavedTopics.insert(validTopic)
				}
			}
			return setOfSavedTopics
		}
		return Set<TopicEntry>()
	}
}
