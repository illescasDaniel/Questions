import Foundation

class QuestionType: Codable, Equatable, CustomStringConvertible {
	
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
	let multipleCorrectAnswersAsMandatory: Bool?
	// case displayFullResults // YET to implement
}

struct Quiz: Codable, Equatable {
	
	let options: QuizOptions?
	let sets: [[QuestionType]]
	
	enum ValidationError: Error {
		
		case emptySet(count: Int)
		case emptyQuestion(set: Int, question: Int)
		case emptyAnswer(set: Int, question: Int, answer: Int)
		case incorrectAnswersCount(set: Int, question: Int)
		case incorrectCorrectAnswersCount(set: Int, question: Int, count: Int?)
		case incorrectCorrectAnswerIndex(set: Int, question: Int, badIndex: Int, maximum: Int)
		
		var log: (error: ValidationError, message: String, details: String) {
			switch self {
			case .emptySet(let count):
				return (error: self, message: "At least one set is empty.", details: "Sets count: \(count)")
			case .emptyQuestion(let set, let question):
				return (error: self, message: "At least one question is empty.", details: "Set index: \(set), question index: \(question)")
			case .emptyAnswer(let set, let question, let answer):
				return (error: self, message: "At least one answer is empty.", details: "Set index: \(set), question index: \(question), answer index: \(answer)")
			case .incorrectAnswersCount(let set, let question):
				return (error: self, message: "The number of valid answers is incorrect, repeated answers are not allowed.", details: "Set index: \(set), question index: \(question)")
			case .incorrectCorrectAnswersCount(let set, let question, let count):
				return (error: self, message: "The number of correct answers is incorrect.", details: "Set index: \(set), question index: \(question), correct answers count: \(count ?? 0)")
			case .incorrectCorrectAnswerIndex(let set, let question, let badIndex, let maximum):
				return (error: self, message: "The 'correct answer' index is incorrect.", details: "Set index: \(set), question index: \(question), bad index: \(badIndex), maximum index: \(maximum)")
			}
		}
	}
	
	func validate() -> ValidationError? {
		
		guard !self.sets.contains(where: { $0.isEmpty }) else { return .emptySet(count: self.sets.count) }
		
		for (indexSet, setOfQuestions) in self.sets.enumerated() {
			
			// ~ Number of answers must be consistent in the same set of questions (otherwise don't make this restriction, you might need to make other changes too)
			let fullQuestionAnswersCount = setOfQuestions.first?.answers.count ?? 4
			
			for (indexQuestion, fullQuestion) in setOfQuestions.enumerated() {
				
				if fullQuestion.correctAnswers == nil { fullQuestion.correctAnswers = [] }
				
				guard !fullQuestion.question.isEmpty else { return .emptyQuestion(set: indexSet, question: indexQuestion) }
				
				guard fullQuestion.answers.count == fullQuestionAnswersCount, Set(fullQuestion.answers).count == fullQuestionAnswersCount else {
					return .incorrectAnswersCount(set: indexSet, question: indexQuestion)
				}
				
				guard !fullQuestion.correctAnswers.contains(where: { $0 >= fullQuestionAnswersCount }),
					(fullQuestion.correctAnswers?.count ?? 0) < fullQuestionAnswersCount else {
						return .incorrectCorrectAnswersCount(set: indexSet, question: indexQuestion, count: fullQuestion.correctAnswers?.count)
				}
				
				if let singleCorrectAnswer = fullQuestion.correct {
					if singleCorrectAnswer >= fullQuestionAnswersCount {
						return .incorrectCorrectAnswerIndex(set: indexSet, question: indexQuestion, badIndex: Int(singleCorrectAnswer), maximum: fullQuestionAnswersCount)
					} else {
						fullQuestion.correctAnswers?.insert(singleCorrectAnswer)
					}
				}
				
				guard let correctAnswers = fullQuestion.correctAnswers, correctAnswers.count < fullQuestionAnswersCount, correctAnswers.count > 0 else {
					return .incorrectCorrectAnswersCount(set: indexSet, question: indexQuestion, count: fullQuestion.correctAnswers?.count)
				}
				
				for (indexAnswer, answer) in fullQuestion.answers.enumerated() {
					if answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
						return .emptyAnswer(set: indexSet, question: indexQuestion, answer: indexAnswer)
					}
				}
			}
		}
		
		return nil
	}
	
	var isValid: Bool {
		return Quiz.isValid(self)
	}

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
			
			switch contentToValidate.validate()?.log {
			case .none:
				self.quiz = contentToValidate
			case .some(_, let message, let details):
				print("Error loading \"\(name)\" topic: \(message).\nDetails: \(details)")
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
			
			switch contentToValidate.validate()?.log {
			case .none:
				self.quiz = contentToValidate
			case .some(_, let message, let details):
				print("Error loading \"\(self.displayedName)\" topic: \(message)\nDetails: \(details)")
				return nil
			}
		} catch {
			print("Error initializing quiz content. Quiz path: \(path.lastPathComponent)")
			return nil
		}
	}
	
	static func ==(lhs: TopicEntry, rhs: TopicEntry) -> Bool {
		return lhs.displayedName == rhs.displayedName || lhs.quiz == rhs.quiz
	}
	
	var hashValue: Int {
		return displayedName.hashValue + (quiz.sets.count * (quiz.sets.first?.count ?? 1))
	}
}


enum CurrentSetOfTopics {
	case app
	case saved
	case community
}

struct SetOfTopics {
	
	static var shared = SetOfTopics()
	
	var topics: [TopicEntry] = [] // Manually: [TopicEntry(name: "Technology"), TopicEntry(name: "Social"), TopicEntry(name: "People")]
	var savedTopics: [TopicEntry] = []
	var communityTopics: [TopicEntry] = []
	
	var currentSetOfTopics: CurrentSetOfTopics = .app
	
	var currentTopics: [TopicEntry] {
		switch currentSetOfTopics {
		case .app: return self.topics
		case .saved: return self.savedTopics
		case .community: return self.communityTopics
		}
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
				
				if DataStoreArchiver.shared.completedSets[topic.displayedName] == nil {
					DataStoreArchiver.shared.completedSets[topic.displayedName] = [:]
				}
				
				if DataStoreArchiver.shared.completedSets[topic.displayedName]?[quiz.offset] == nil {
					DataStoreArchiver.shared.completedSets[topic.displayedName]?[quiz.offset] = false
				}
			}
		}
	}
	
	mutating func loadSavedTopics() {

		let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		self.savedTopics = Array(self.setOfTopicsFromJSONFilesOfDirectory(url: documentsURL))
		
		self.loadSetState(for: self.savedTopics)
	}
	
	mutating func loadCommunityTopics() {
		
		self.communityTopics.removeAll(keepingCapacity: true)
		
		CommunityTopics.areLoaded = false
		CommunityTopics.initializeSynchronously()
		
		guard let communityTopics = CommunityTopics.shared else { return }
			
		for topic in communityTopics.topics where topic.isVisible {
			
			let topicName = topic.name ?? "Community Topic - \(self.communityTopics.count)"
			let topicEntry = TopicEntry(name: topicName, content: Quiz(options: nil, sets: [[]]))
			
			self.communityTopics.append(topicEntry)
			/*if let validTextFromURL = try? String(contentsOf: topic.remoteContentURL), let quiz = self.quizFrom(content: validTextFromURL) {
				let topicName = quiz.options?.name ?? "Community Topic - \(self.communityTopics.count)"
				let topicEntry = TopicEntry(name: topicName, content: quiz)
				self.communityTopics.append(topicEntry)
			}*/
		}
		
		self.loadSetState(for: self.communityTopics)
		CommunityTopics.areLoaded = true
	}
	
	@discardableResult func save(topic: TopicEntry) -> Bool {
		// Won't save topics/set of questions with the same content
		guard !SetOfTopics.shared.savedTopics.contains(topic) else { return false }
		
		let fileName: String
		let topicName = topic.displayedName
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
				return true
			}
		}
		return false
	}
	
	func quizFrom(content: String?) -> Quiz? {
		
		guard let data = content?.data(using: .utf8), let quizContent = try? JSONDecoder().decode(Quiz.self, from: data) else {
			return nil
		}
		
		switch quizContent.validate()?.log {
		case .none:
			return quizContent
		case .some(_, let message, let details):
			print(message, "\nDetails: \(details)")
			return nil
		}
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
