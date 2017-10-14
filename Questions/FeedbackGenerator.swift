//
//  FeedbackGenerator.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 14/10/2017.
//  Copyright © 2017 Daniel Illescas Romero. All rights reserved.
//

import UIKit

struct FeedbackGenerator {
	
	static func impactOcurredWith(style: UIImpactFeedbackStyle) {
		if #available(iOS 10.0, *), UserDefaultsManager.hapticFeedbackSwitchIsOn {
			UIImpactFeedbackGenerator(style: style).impactOccurred()
		}
	}
	
	static func notificationOcurredOf(type: UINotificationFeedbackType) {
		if #available(iOS 10.0, *), UserDefaultsManager.hapticFeedbackSwitchIsOn {
			UINotificationFeedbackGenerator().notificationOccurred(type)
		}
	}
	
	static func selectionChanged() {
		if #available(iOS 10.0, *), UserDefaultsManager.hapticFeedbackSwitchIsOn {
			UISelectionFeedbackGenerator().selectionChanged()
		}
	}
}

