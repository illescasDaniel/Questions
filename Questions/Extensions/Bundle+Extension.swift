//
//  Bundle+Extension.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 18/12/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import Foundation

extension Bundle {
	/// Returns nil if it couldn't find the file
	func fileContent(ofResource name: String?, withExtension ext: String?) -> String? {
		if let url = Bundle.main.url(forResource: name, withExtension: ext), let content = try? String(contentsOf: url) {
			return content
		}
		return nil
	}
}
