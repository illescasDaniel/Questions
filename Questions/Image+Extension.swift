//
//  UIImage+Extension.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 27/03/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import UIKit

extension UIImage {
	convenience init?(contentsOf url: URL?) {
		
		guard let validURL = url else { return nil }
		
		if let imageData = try? Data(contentsOf: validURL) {
			self.init(data: imageData)
			return
		}
		return nil
	}
	
	static func manageContentsOf(_ url: URL?, completionHandler: @escaping ((UIImage, URL?) -> ()), errorHandler: (() -> ())? = nil) {
		DispatchQueue.global().async {
			if let validImage = UIImage(contentsOf: url) {
				DispatchQueue.main.async {
					completionHandler(validImage, url)
				}
			} else {
				DispatchQueue.main.async {
					errorHandler?()
				}
			}
		}
	}
}

extension CIImage {
	func nonInterpolatedImageWith(width: CGFloat, height: CGFloat) -> UIImage? {
		
		guard let cgImage = CIContext().createCGImage(self, from: extent) else { return nil }
		
		let size = CGSize(width: extent.size.width * width, height: extent.size.height * height)
		
		UIGraphicsBeginImageContextWithOptions(size, true, 0)
		
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		
		context.interpolationQuality = .none
		context.translateBy(x: 0, y: height)
		context.scaleBy(x: 1.0, y: -1.0)
		context.draw(cgImage, in: context.boundingBoxOfClipPath)
		
		let finalImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return finalImage
	}
}
