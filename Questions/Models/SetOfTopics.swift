import Foundation

class SetOfTopics {
	
	enum Mode: Int {
		case app = 0
		case saved = 1
		case community = 2
	}
	
	static let shared = SetOfTopics()
	static let fileManager = FileManager.default
	
	var topicsEntry: [TopicEntry] = [] // Manually: [TopicEntry(name: "Technology"), TopicEntry(name: "Social"), TopicEntry(name: "People")]
	var savedTopics: [TopicEntry] = []
	var communityTopics: [TopicEntry] = []
	var current: Mode = .app
	
	var currentTopics: [TopicEntry] {
		switch current {
		case .app: return self.topicsEntry
		case .saved: return self.savedTopics
		case .community: return self.communityTopics
		}
	}

	// Automatically loads all .json files :)
	fileprivate init() {
		self.topicsEntry = Array(self.setOfTopicsFromJSONFilesOfDirectory(url: Bundle.main.bundleURL))
		self.loadSavedTopics()
		self.loadAllTopicsStates()
	}
	
	func loadAllTopicsStates() {
		self.loadSetState(for: self.topicsEntry)
		self.loadSetState(for: self.savedTopics)
	}
	
	func loadSetState(for topicSet: [TopicEntry]) {
		
		for topic in topicSet {
			for quiz in topic.topic.sets.enumerated() {
				
				if DataStoreArchiver.shared.completedSets[topic.displayedName] == nil {
					DataStoreArchiver.shared.completedSets[topic.displayedName] = [:]
				}
				
				if DataStoreArchiver.shared.completedSets[topic.displayedName]?[quiz.offset] == nil {
					DataStoreArchiver.shared.completedSets[topic.displayedName]?[quiz.offset] = false
				}
			}
		}
	}
	
	func loadSavedTopics() {

		let documentsURL = SetOfTopics.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
		self.savedTopics = Array(self.setOfTopicsFromJSONFilesOfDirectory(url: documentsURL))
		
		self.loadSetState(for: self.savedTopics)
	}
	
	func removeSavedTopics(named topicNames: [String], reloadAfterDeleting: Bool = false) {
		
		for topicName in topicNames where !topicName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

			let fileName =  "\(topicName).json"
			
			if let fileURL = SetOfTopics.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) {
				try? SetOfTopics.fileManager.removeItem(at: fileURL)
			}
		}
		
		if reloadAfterDeleting {
			SetOfTopics.shared.loadSavedTopics()
		}
	}
	
	func removeSavedTopics(withIndexPaths indexPaths: [IndexPath], reloadAfterDeleting: Bool = false) {
		
		for topicIndex in indexPaths.map({ $0.row }) where topicIndex < SetOfTopics.shared.savedTopics.count {
			
			let fileName =  "\(SetOfTopics.shared.savedTopics[topicIndex].displayedName).json"
			
			if let fileURL = SetOfTopics.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) {
				try? SetOfTopics.fileManager.removeItem(at: fileURL)
			}
		}
		
		if reloadAfterDeleting {
			SetOfTopics.shared.loadSavedTopics()
		}
	}
	
	func loadCommunityTopics(completionHandler loadCTCH: (() -> Void)? = nil) {
		
		self.communityTopics.removeAll(keepingCapacity: true)
		
		CommunityTopics.initialize(completionHandler: { loadedCommunityTopics in
			guard let loadedCommunityTopics = loadedCommunityTopics else { return }
			CommunityTopics.shared = loadedCommunityTopics
			
			self.communityTopics = loadedCommunityTopics.topics
				.filter { $0.isVisible }
				.map { topic in
					let topicName = topic.name ?? "Community Topic - \(self.communityTopics.count)"
					return TopicEntry(name: topicName, content: Topic(options: nil, sets: [[]]))
				}

			self.loadSetState(for: self.communityTopics)
			loadCTCH?()
		})
	}
	
	@discardableResult func save(topic: TopicEntry) -> Bool {
		// Won't save topics/set of questions with the same content
		guard !SetOfTopics.shared.savedTopics.contains(topic) else { return false }
		
		let fileName: String
		let topicName = topic.displayedName
		if topicName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			if let topicNameFromJSON = topic.topic.options?.name, !topicNameFromJSON.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				fileName = topicNameFromJSON.trimmingCharacters(in: .whitespacesAndNewlines) + ".json"
			} else {
				//fileName = "User Topic - \(UserDefaultsManager.savedQuestionsCounter).json" // Could be translated...
                fileName = topicName+".json"
			}
		}
		else if !topicName.hasSuffix(".json") {
			fileName = topicName + ".json"
		} else {
			fileName = topicName
		}
		
		if let documentsURL = SetOfTopics.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) {
			if let data = try? JSONEncoder().encode(topic.topic) {
				try? data.write(to: documentsURL)
				UserDefaultsManager.savedQuestionsCounter += 1
				SetOfTopics.shared.loadSavedTopics()
				return true
			}
		}
		return false
	}
	
	func quizFrom(content: Data?) -> Topic? {
		
		guard let data = content, let quizContent = try? JSONDecoder().decode(Topic.self, from: data) else {
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
	
	func quizFrom(content: String?) -> Topic? {
		
		guard let data = content?.data(using: .utf8), let quizContent = try? JSONDecoder().decode(Topic.self, from: data) else {
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
		
		if let validURL = contentURL,
			let contentOfFilesPath = (try? SetOfTopics.fileManager.contentsOfDirectory(at: validURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])) {
			
			var setOfSavedTopics = Set<TopicEntry>()
			
			for url in contentOfFilesPath where url.pathExtension == "json" {
				if let validTopic = TopicEntry(path: url) {
					setOfSavedTopics.insert(validTopic)
				}
			}
			
			return setOfSavedTopics
		}
		return []
	}
}
