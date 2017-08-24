//
//  UIView+Extension.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 22/08/2017.
//  Copyright © 2017 Daniel Illescas Romero. All rights reserved.
//

import UIKit

extension UIView {
	
	func dontInvertIfDarkModeIsEnabled0() {
		if #available(iOS 11.0, *) {
			self.accessibilityIgnoresInvertColors = Settings.shared.darkThemeEnabled
		}
	}
	
	func dontInvert() {
		if #available(iOS 11.0, *) {
			self.accessibilityIgnoresInvertColors = true
		}
	}
}
