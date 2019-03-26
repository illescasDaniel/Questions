//  SideVolumeHUD.swift
//  by Daniel Illescas Romero
//  Github: @illescasDaniel
//  License: MIT

import UIKit
import class MediaPlayer.MPVolumeView

public class SideVolumeHUD {
	
	public static let shared = SideVolumeHUD()
	
	private let window = UIWindow()
	
	fileprivate init() {
		self.window.backgroundColor = UIColor.clear
		self.window.frame = UIScreen.main.bounds
		self.window.windowLevel = .normal
		self.window.alpha = 1
		self.window.isHidden = true
		self.hideDefaultVolumeHUD(from: UIApplication.shared.delegate?.window ?? nil)
		self.window.makeKey()
	}

	/// Default options: dark, vertical, slideLeftRight animation, with 'special effects'
	public func setup(withOptions options: Set<Option> = []) {
		
		let sideVolumeHUD = SideVolumeHUDHolderView(withOptions: self.optionSetToOptions(options: options), hudWindow: self.window)
		
		let viewController = UIViewController()
		viewController.view.frame = self.window.frame
		viewController.view.backgroundColor = .clear
		sideVolumeHUD.configure(for: viewController.view)
		viewController.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backgroundViewAction)))
		
		self.window.rootViewController = viewController
	}
	
	@objc private func backgroundViewAction(_ sender: UIView) {
		UIView.animate(withDuration: 0.15, animations: {
			self.window.alpha = 0
		}, completion: { completed in
			if completed {
				self.window.isHidden = true
				self.window.alpha = 1
			}
		})
	}
	
	private func hideDefaultVolumeHUD(from window: UIWindow?) {
		window?.addSubview(MPVolumeView())
	}
	
	private func optionSetToOptions(options: Set<Option>) -> Options {
		var optionsTheme: Option.Theme = .dark
		var optionsOrientation: Option.Orientation = .vertical
		var optionsAnimationStyle: Option.AnimationStyle = .slideLeftRight
		var optionsUseSpecialEffects: Bool = true
		
		for option in options {
			switch option {
			case .theme(let theme):
				optionsTheme = theme
			case .orientation(let orientation):
				optionsOrientation = orientation
			case .animationStyle(let animationStyle):
				optionsAnimationStyle = animationStyle
			case .useSpecialEffects(let useSpecialEffets):
				optionsUseSpecialEffects = useSpecialEffets
			}
		}
		
		return Options(theme: optionsTheme, orientation: optionsOrientation, animationStyle: optionsAnimationStyle, useSpecialEffects: optionsUseSpecialEffects)
	}
}

// MARK: - Details
extension SideVolumeHUD {
	public enum Option: Hashable {
		/// Only available if useSpecialEffects is true (which is its default value)
		case theme(Theme)
		case orientation(Orientation)
		case animationStyle(AnimationStyle)
		/// parallax effect, perfect round corners, etc
		case useSpecialEffects(Bool)
	}
	internal struct Options {
		public let theme: Option.Theme
		public let orientation: Option.Orientation
		public let animationStyle: Option.AnimationStyle
		public let useSpecialEffects: Bool
	}
}

public extension SideVolumeHUD.Option {
	enum AnimationStyle: Hashable {
		case enlarge
		case slideLeftRight
		case fadeInOut
	}
	enum Theme: Hashable {
		case dark
		case light
	}
	enum Orientation: Hashable {
		case vertical
		case horizontal
	}
}
