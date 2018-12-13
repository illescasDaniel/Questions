//
//  FeedbackGenerator.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 14/10/2017.
//  Copyright © 2017 Daniel Illescas Romero. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
struct FeedbackGenerator {
	
	static func impactOcurredWith(style: UIImpactFeedbackGenerator.FeedbackStyle) {
		if UserDefaultsManager.hapticFeedbackSwitchIsOn {
			UIImpactFeedbackGenerator(style: style).impactOccurred()
		}
	}
	
	static func notificationOcurredOf(type: UINotificationFeedbackGenerator.FeedbackType) {
		if UserDefaultsManager.hapticFeedbackSwitchIsOn {
			UINotificationFeedbackGenerator().notificationOccurred(type)
		}
	}
	
	static func selectionChanged() {
		if UserDefaultsManager.hapticFeedbackSwitchIsOn {
			UISelectionFeedbackGenerator().selectionChanged()
		}
	}
}

