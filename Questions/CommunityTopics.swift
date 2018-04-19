//
//  CommunityTopics.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 19/04/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import Foundation


struct CommunityTopic: Codable {
	let remoteContentURL: URL
	var isVisible: Bool
}

struct CommunityTopics: Codable {
	
	let topics: [CommunityTopic]
	
	static var shared: CommunityTopics? = nil
	static var areLoaded: Bool = false
	
	static func initialize(completionHandler: ((CommunityTopics?) -> ())? = nil) {
		DispatchQueue.global().async {
			if let communityTopicsURL = URL(string: QuestionsAppOptions.communityTopicsURL),
				let data = try? Data(contentsOf: communityTopicsURL),
				let communityTopics = try? JSONDecoder().decode(CommunityTopics.self, from: data) {
				CommunityTopics.shared = communityTopics
			}
			completionHandler?(CommunityTopics.shared)
		}
	}
	
	static func initializeSynchronously() {
		if let communityTopicsURL = URL(string: QuestionsAppOptions.communityTopicsURL),
			let data = try? Data(contentsOf: communityTopicsURL),
			let communityTopics = try? JSONDecoder().decode(CommunityTopics.self, from: data) {
			CommunityTopics.shared = communityTopics
		}
	}
}
