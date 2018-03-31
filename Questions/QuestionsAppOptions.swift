//
//  QuestionsAppOptions.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 28/03/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import Foundation

struct QuestionsAppOptions {
	
	static let correctAnswerPoints: Int = 20
	static let incorrectAnswerPoints: Int = -10
	static let helpActionPoints: Int = -5
	
	static let maximumHelpTries: UInt8 = 2 // 0 = (number of answers - 1)
	static let isHelpEnabled: Bool = true
	
	static let maximumRepeatTriesPerQuiz: UInt8 = 2
	
	static let privacyFeaturesEnabled: Bool = true
}
