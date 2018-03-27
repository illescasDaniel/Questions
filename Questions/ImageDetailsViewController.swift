//
//  ImageDetailsViewController.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 27/03/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import UIKit

class ImageDetailsViewController: UIViewController {
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var closeViewButton: UIButton!
	
	private let originalBGColor = UIColor.themeStyle(dark: .black, light: .white)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = originalBGColor
	}
	
	@IBAction func closeViewAction(_ sender: UIButton) {
		self.dismiss(animated: true)
	}
	
	@IBAction func panGestureOverImageViewAction(_ sender: UIPanGestureRecognizer) {
		
		let translation = sender.translation(in: self.imageView)
		
		self.imageView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
		
		let translationFromCenter = abs(translation.y / self.view.center.y)
		self.view.backgroundColor = self.originalBGColor.withAlphaComponent(1 - translationFromCenter)
		
		if sender.state == .ended {
			
			let velocity = sender.velocity(in: self.imageView)
			
			if translationFromCenter >= 0.8 || velocity.x > 1000 || velocity.y > 1000 {
				self.dismiss(animated: true)
				return
			}
			
			UIView.transition(with: self.imageView, duration: 0.15, options: [.curveEaseIn], animations: {
				self.imageView.transform = .identity
				self.view.backgroundColor = self.originalBGColor
			})
		}
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
}
