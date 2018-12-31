//
//  UIImage+Extension.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 27/03/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import UIKit

extension UIImage {
	static func manageContentsOf(_ url: URL?, completionHandler: @escaping ((UIImage, URL?) -> ()), errorHandler: (() -> ())? = nil) {
		DownloadManager.shared.manageData(from: url) { data in
			if let data = data, let validImage = UIImage(data: data) {
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
