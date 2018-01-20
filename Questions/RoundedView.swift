//
//  RoundedView.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 20/01/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import UIKit

struct ShadowEffect {
	
	let shadowColor: UIColor
	let shadowOffset: CGSize
	let shadowOpacity: Float
	let shadowRadius: CGFloat
	
	init(shadowColor: UIColor = .black,
		 shadowOffset: CGSize = CGSize(width: 0.5, height: 4.0),
		 shadowOpacity: Float = 0.5,
		 shadowRadius: CGFloat = 5.0) {
		self.shadowColor = shadowColor
		self.shadowOffset = shadowOffset
		self.shadowOpacity = shadowOpacity
		self.shadowRadius = shadowRadius
	}
}

fileprivate protocol ShadowSettingsDelegate {
	var shadowColor: UIColor { get set }
	var shadowOffset: CGSize { get set }
	var shadowOpacity: Float { get set }
	var shadowRadius: CGFloat { get set }
}

@IBDesignable extension UIView: ShadowSettingsDelegate {
	
	@IBInspectable fileprivate var shadowColor: UIColor {
		get { return UIColor(cgColor: self.layer.shadowColor ?? UIColor.clear.cgColor) }
		set { self.layer.shadowColor = newValue.cgColor }
	}
	
	@IBInspectable fileprivate var shadowOffset: CGSize {
		get { return self.layer.shadowOffset }
		set { self.layer.shadowOffset = newValue }
	}
	
	@IBInspectable fileprivate var shadowOpacity: Float {
		get { return self.layer.shadowOpacity }
		set { self.layer.shadowOpacity = newValue }
	}
	
	@IBInspectable fileprivate var shadowRadius: CGFloat {
		get { return self.layer.shadowRadius }
		set { self.layer.shadowRadius = newValue }
	}
}

extension UIView {
	func setup(shadows: ShadowEffect = ShadowEffect()) {
		self.layer.shadowColor = shadows.shadowColor.cgColor
		self.layer.shadowOffset = shadows.shadowOffset
		self.layer.shadowRadius = shadows.shadowRadius
		self.layer.shadowOpacity = shadows.shadowOpacity
	}
}

@IBDesignable class RoundedView: UIView {
	
	@IBInspectable var cornerRadius: CGFloat = 0.0
	@IBInspectable var borderColor: UIColor = .clear
	@IBInspectable var borderWidth: CGFloat = 0.5
	
	private var customBackgroundColor = UIColor.white
	override var backgroundColor: UIColor? {
		didSet {
			customBackgroundColor = backgroundColor ?? .white
			super.backgroundColor = UIColor.clear
		}
	}
	
	private func setupPropertiesDefaultValues() {
		self.layer.shadowOpacity = 0.05; self.layer.shadowRadius = 3.5
		super.backgroundColor = UIColor.clear
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupPropertiesDefaultValues()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.setupPropertiesDefaultValues()
	}
	
	override func draw(_ rect: CGRect) {
		
		customBackgroundColor.setFill()
		UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).fill()
		
		let borderRect = bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
		let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius - borderWidth/2)
		
		borderColor.setStroke()
		borderPath.lineWidth = borderWidth
		borderPath.stroke()
	}
}

@IBDesignable class RoundedButton: UIButton {
	
	@IBInspectable var cornerRadius: CGFloat = 0.0
	@IBInspectable var borderColor = UIColor.clear
	@IBInspectable var borderWidth: CGFloat = 0.5
	
	private var customBackgroundColor = UIColor.white
	override var backgroundColor: UIColor? {
		didSet {
			customBackgroundColor = backgroundColor ?? .white
			super.backgroundColor = UIColor.clear
		}
	}
	
	private func setupPropertiesDefaultValues() {
		self.layer.shadowOpacity = 0.05; self.layer.shadowRadius = 3.5
		super.backgroundColor = UIColor.clear
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupPropertiesDefaultValues()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.setupPropertiesDefaultValues()
	}
	
	override func draw(_ rect: CGRect) {
		
		customBackgroundColor.setFill()
		UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).fill()
		
		let borderRect = bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
		let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius - borderWidth/2)
		
		borderColor.setStroke()
		borderPath.lineWidth = borderWidth
		borderPath.stroke()
	}
}
