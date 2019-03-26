//
//  DownloadManager.swift
//
//  Created by Daniel Illescas Romero on 19/10/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import Foundation

public class DownloadManager {

	static let shared = DownloadManager()
	
	private var tasks: [URLSessionTask] = []
	private var cachedData = NSCache<NSNumber, NSURL>()
	
	public enum Errors {
		// case task already in tasks ??
		case invalidInputURL
		case invalidFileURL
		case invalidData
	}
	
	func manageData(from url: String?, savingOnDisk: Bool = true,
					onSuccess: @escaping ((Data) -> Void), onError: @escaping ((DownloadManager.Errors) -> Void) = {_ in }) {
		
		guard let url = url else {
			DispatchQueue.main.async {
				onError(.invalidInputURL)
			}
			return
		}
		let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedURL.isEmpty else {
			DispatchQueue.main.async {
				onError(.invalidInputURL)
			}
			return
		}
		self.manageData(from: URL(string: trimmedURL), savingOnDisk: savingOnDisk, onSuccess: onSuccess, onError: onError)
	}
	
	func manageData(from url: URL?, savingOnDisk: Bool = true,
					onSuccess: @escaping ((Data) -> Void), onError: @escaping ((DownloadManager.Errors) -> Void) = {_ in }) {
		guard let url = url else {
			DispatchQueue.main.async {
				onError(.invalidInputURL)
			}
			return
		}
		
		if savingOnDisk, let recoveredCachedData = self.cachedData.object(forKey: NSNumber(value: url.hashValue)) {
			self.manageDataTask(dataURL: recoveredCachedData as URL, urlResponse: nil, error: nil, onSuccess: onSuccess, onError: onError)
			return
		}
		
		let task = savingOnDisk
			? URLSession.shared.downloadTask(with: url) { (dataURL, response, error) in
				if let validDataURL = dataURL {
					self.cachedData.setObject(validDataURL as NSURL, forKey: NSNumber(value: url.hashValue))
				}
				self.manageDataTask(dataURL: dataURL, urlResponse: response, error: error, onSuccess: onSuccess, onError: onError)
			}
			: URLSession.shared.dataTask(with: url) { (data, response, error) in
				self.manageDownloadTask(data: data, urlResponse: response, error: error, onSuccess: onSuccess, onError: onError)
			}
		task.resume()
		self.tasks.append(task)
	}
	
	func cancelTaskWith(url: URL) {
		if let taskIndex = tasks.firstIndex(where: { $0.originalRequest?.url == url }) {
			self.tasks[taskIndex].cancel()
			self.tasks.remove(at: taskIndex)
		}
	}
	
	// MAKR: - Convenience
	
	private func manageDataTask(dataURL: URL?, urlResponse: URLResponse?, error: Error?,
								onSuccess: @escaping ((Data) -> Void), onError: @escaping ((DownloadManager.Errors) -> Void) = {_ in }) {
		if let dataURL = dataURL {
			DispatchQueue.global().async {
				if let data = try? Data(contentsOf: dataURL) {
					DispatchQueue.main.async {
						onSuccess(data)
					}
				} else {
					DispatchQueue.main.async {
						onError(.invalidData)
					}
				}
			}
		} else {
			DispatchQueue.main.async {
				onError(.invalidFileURL)
			}
		}
	}
	
	private func manageDownloadTask(data: Data?, urlResponse: URLResponse?, error: Error?,
								onSuccess: @escaping ((Data) -> Void), onError: @escaping ((DownloadManager.Errors) -> Void) = {_ in }) {
		DispatchQueue.main.async {
			if let data = data {
				onSuccess(data)
			} else {
				onError(.invalidData)
			}
		}
	}
}
