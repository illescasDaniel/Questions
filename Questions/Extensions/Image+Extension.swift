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
