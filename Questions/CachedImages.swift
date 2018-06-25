//
//  CachedImages.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 22/06/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import UIKit

class CachedImages {
	
	enum Errors: Error {
		case emptyURL
		case couldNotSaveImage
		case couldNotDownloadImage
	}
	
	private let cachedImagesFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(".cachesImages")
	
	static let shared = CachedImages()
	fileprivate init() { self.createImagesFolderIfItDoesntExist() }
	
	func exists(withURL url: String) -> Bool {
		return self.exists(withKey: url.hash)
	}
	
	func saveImage(withURL url: String, onError: @escaping (CachedImages.Errors) -> () = {_ in }) {
		
		DispatchQueue.global().async {
			
			let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
			guard !trimmedURL.isEmpty else {
				DispatchQueue.main.async {
					onError(.emptyURL)
				}
				return
			}
			
			let cachedImage = self.cachedImagesFolder.appendingPathComponent("\(trimmedURL.hash)", isDirectory: false)
			guard !FileManager.default.fileExists(atPath: cachedImage.path) else { return }
			
			UIImage.manageContentsOf(URL(string: trimmedURL), completionHandler: { (downloadedImage, url) in
				if let validImageData = UIImageJPEGRepresentation(downloadedImage, 0.95) {
					do {
						try validImageData.write(to: cachedImage)
					} catch {
						print(error)
						DispatchQueue.main.async {
							onError(.couldNotSaveImage)
						}
					}
				}
			}, errorHandler: {
				onError(.couldNotDownloadImage)
			})
		}
	}
	
	func load(image imageURL: String, into imageView: UIImageView) {
		self.load(url: imageURL, onSuccess: { image in
			imageView.image = image
		})
	}
	
	func load(url: String, onSuccess: @escaping (UIImage) -> (), prepareForDownload: @escaping () -> () = {}, onError: @escaping (CachedImages.Errors) -> () = {_ in }) {
		DispatchQueue.global().async {
			
			let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
			guard !trimmedURL.isEmpty else {
				DispatchQueue.main.async {
					onError(.emptyURL)
				}
				return
			}
			let key = trimmedURL.hash
			
			if self.exists(withKey: key), let image = self.image(withKey: key) {
				DispatchQueue.main.async {
					onSuccess(image)
				}
			}
			else {
				DispatchQueue.main.async {
					prepareForDownload()
				}
				
				DispatchQueue.global().async {
					if let validImage = UIImage(contentsOf: URL(string: trimmedURL)) {
						DispatchQueue.main.async {
							onSuccess(validImage)
						}
						CachedImages.shared.asyncSave(image: validImage, withKey: key, onError: onError)
					} else {
						DispatchQueue.main.async {
							onError(.couldNotDownloadImage)
						}
					}
				}
			}
		}
	}
	
	/// Returns `true` if cached images were cleared successfully
	@discardableResult func clear() -> Bool {
		let result = (try? FileManager.default.removeItem(atPath: self.cachedImagesFolder.path)) != nil
		self.createImagesFolderIfItDoesntExist()
		return result
	}
	
	// MARK: - Convenience
	
	private func createImagesFolderIfItDoesntExist() {
		if !FileManager.default.fileExists(atPath: self.cachedImagesFolder.path) {
			if (try? FileManager.default.createDirectory(atPath: self.cachedImagesFolder.path, withIntermediateDirectories: false)) == nil {
				print("Error while creating the cached images directory")
			}
		}
	}
	
	private func exists(withKey key: Int) -> Bool {
		let validCachedImageURL = self.cachedImagesFolder.appendingPathComponent("\(key)", isDirectory: false)
		return FileManager.default.fileExists(atPath: validCachedImageURL.path)
	}
	
	private func image(withKey key: Int) -> UIImage? {
		
		let cachedImageURL = self.cachedImagesFolder.appendingPathComponent("\(key)")
		
		if let imageData = try? Data(contentsOf: cachedImageURL) {
			return UIImage(data: imageData)
		}
		return nil
	}
	
	private func asyncSave(image: UIImage, withKey key: Int, onError: @escaping (CachedImages.Errors) -> () = {_ in}) {
		
		DispatchQueue.global().async {
			
			let cachedImage = self.cachedImagesFolder.appendingPathComponent("\(key)", isDirectory: false)
			guard !FileManager.default.fileExists(atPath: cachedImage.path) else { return }
			
			if let validImageData = UIImageJPEGRepresentation(image, 0.95) {
				do {
					try validImageData.write(to: cachedImage)
				} catch {
					print(error)
					DispatchQueue.main.async {
						onError(.couldNotSaveImage)
					}
				}
			}
		}
	}
}
