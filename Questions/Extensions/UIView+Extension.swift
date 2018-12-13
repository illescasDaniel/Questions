//
//  UIView+Extension.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 22/08/2017.
//  Copyright © 2017 Daniel Illescas Romero. All rights reserved.
//

import UIKit

extension UIView {
	
	func dontInvertIfDarkModeIsEnabled() {
		if #available(iOS 11.0, *) {
			self.accessibilityIgnoresInvertColors = UserDefaultsManager.darkThemeSwitchIsOn
		}
	}
	
	func dontInvertColors() {
		if #available(iOS 11.0, *) {
			self.accessibilityIgnoresInvertColors = true
		}
	}
	
	func round(corners: UIRectCorner = .allCorners, withRadius radius: CGFloat) {
		
		guard radius > 0.0 else { return }
		
		let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		
		let maskLayer = CAShapeLayer()
		maskLayer.frame = self.bounds
		maskLayer.path = maskPath.cgPath
		
		self.layer.mask = maskLayer
	}
}
