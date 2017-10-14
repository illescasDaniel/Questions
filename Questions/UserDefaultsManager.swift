//
//  UserDefaultsManager.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 14/10/2017.
//  Copyright © 2017 Daniel Illescas Romero. All rights reserved.
//

import Foundation

class UserDefaultsManager {
	
	private static let defaults = UserDefaults.standard
	
	enum ItemsToSave: String {
		
		case backgroundMusicSwitch
		case hapticFeedbackSwitch
		case parallaxEffectSwitch
		case darkThemeSwitch
		
		case score
		case correctAnswers
		case incorrectAnswers
		
		fileprivate static var trueByDefaultSwitches: [ItemsToSave] {
			return [.backgroundMusicSwitch, .hapticFeedbackSwitch, .parallaxEffectSwitch, .hapticFeedbackSwitch]
		}
		
		fileprivate static var falseByDefaultSwitches: [ItemsToSave] {
			return [.darkThemeSwitch]
		}
	}
	
	static func loadDefaultValues() {
		
		for switchItem in ItemsToSave.trueByDefaultSwitches where defaults.object(forKey: switchItem.rawValue) == nil {
			defaults.set(true, forKey: switchItem.rawValue)
		}
		
		for switchItem in ItemsToSave.falseByDefaultSwitches where defaults.object(forKey: switchItem.rawValue) == nil {
			defaults.set(false, forKey: switchItem.rawValue)
		}
		
		let score = ItemsToSave.score.rawValue
		if defaults.object(forKey: score) == nil {
			UserDefaultsManager.score = 0
		}
		
		let correctAnswers = ItemsToSave.correctAnswers.rawValue
		if defaults.object(forKey: correctAnswers) == nil {
			UserDefaultsManager.correctAnswers = 0
		}
		
		let incorrectAnswers = ItemsToSave.incorrectAnswers.rawValue
		if defaults.object(forKey: incorrectAnswers) == nil {
			UserDefaultsManager.incorrectAnswers = 0
		}
	}
	
	static var backgroundMusicSwitchIsOn: Bool {
		get { return defaults.bool(forKey: ItemsToSave.backgroundMusicSwitch.rawValue) }
		set { defaults.set(newValue, forKey: ItemsToSave.backgroundMusicSwitch.rawValue) }
	}
	
	static var hapticFeedbackSwitchIsOn: Bool {
		get { return defaults.bool(forKey: ItemsToSave.hapticFeedbackSwitch.rawValue) }
		set { defaults.set(newValue, forKey: ItemsToSave.hapticFeedbackSwitch.rawValue) }
	}
	
	static var parallaxEffectSwitchIsOn: Bool {
		get { return defaults.bool(forKey: ItemsToSave.parallaxEffectSwitch.rawValue) }
		set { defaults.set(newValue, forKey: ItemsToSave.parallaxEffectSwitch.rawValue) }
	}
	
	static var darkThemeSwitchIsOn: Bool {
		get { return defaults.bool(forKey: ItemsToSave.darkThemeSwitch.rawValue) }
		set { defaults.set(newValue, forKey: ItemsToSave.darkThemeSwitch.rawValue) }
	}
	
	static var score: Int {
		get { return defaults.integer(forKey: ItemsToSave.score.rawValue) }
		set { defaults.set(newValue, forKey: ItemsToSave.score.rawValue) }
	}
	
	static var correctAnswers: Int {
		get { return defaults.integer(forKey: ItemsToSave.correctAnswers.rawValue) }
		set { defaults.set(newValue, forKey: ItemsToSave.correctAnswers.rawValue) }
	}
	
	static var incorrectAnswers: Int {
		get { return defaults.integer(forKey: ItemsToSave.incorrectAnswers.rawValue) }
		set { defaults.set(newValue, forKey: ItemsToSave.incorrectAnswers.rawValue) }
	}
}
