//
//  CommunityTopics.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 19/04/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import Foundation

struct CommunityTopic: Codable {
	let name: String?
	let remoteContentURL: URL
	var isVisible: Bool
}

// improve
struct CommunityTopics: Codable {
	
	var topics: [CommunityTopic] = []
	
	static var shared = CommunityTopics()
	
	static func initialize(completionHandler: ((CommunityTopics?) -> ())? = nil) {
		
		guard let url = URL(string: QuestionsAppOptions.communityTopicsURL) else { return }
		
		DownloadManager.shared.cancelTaskWith(url: url)
		CommunityTopics.shared.topics.forEach { DownloadManager.shared.cancelTaskWith(url: $0.remoteContentURL) }
		
		DownloadManager.shared.manageData(from: url) { data in
			if let data = data, let communityTopics = try? JSONDecoder().decode(CommunityTopics.self, from: data) {
				CommunityTopics.shared.topics = communityTopics.topics
			}
			completionHandler?(CommunityTopics.shared)
		}
	}
}
