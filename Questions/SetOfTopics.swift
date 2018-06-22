import Foundation

struct SetOfTopics {
	
	enum Current {
		case app
		case saved
		case community
	}
	
	static var shared = SetOfTopics()
	
	var topics: [TopicEntry] = [] // Manually: [TopicEntry(name: "Technology"), TopicEntry(name: "Social"), TopicEntry(name: "People")]
	var savedTopics: [TopicEntry] = []
	var communityTopics: [TopicEntry] = []
	var current: Current = .app
	
	var currentTopics: [TopicEntry] {
		switch current {
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
		
		switch quizContent.validate() {
		case .none:
			return quizContent
		case .some(let error):
			print(error.localizedDescription, "\nDetails: \(error.recoverySuggestion ?? "")")
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
