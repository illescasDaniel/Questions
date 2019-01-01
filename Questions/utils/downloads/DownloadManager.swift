//
//  DownloadManager.swift
//
//  Created by Daniel Illescas Romero on 19/10/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import Foundation

class DownloadManager {
	
	static let shared = DownloadManager()
	
	private var tasks: [URLSessionTask] = []

	func manageData(from url: URL?, _ handleData: @escaping ((Data?) -> Void)) {
		
		guard let url = url, !self.tasks.contains(where: { $0.originalRequest?.url == url && $0.state == .running }) else {
			return
		}

		let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
			DispatchQueue.main.async {
				if let url = url, let data = try? Data(contentsOf: url) {
					handleData(data)
				}
			}
		}
		
		task.resume()
		self.tasks.append(task)
	}
	
	func cancelTaskWith(url: URL) {
		if let taskIndex = tasks.index(where: { $0.originalRequest?.url == url }) {
			self.tasks[taskIndex].cancel()
			self.tasks.remove(at: taskIndex)
		}
	}
}
