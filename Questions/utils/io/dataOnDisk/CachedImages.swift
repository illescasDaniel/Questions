/*
The MIT License (MIT)

Copyright (c) 2018 Daniel Illescas Romero <https://github.com/illescasDaniel/CachedImages>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import UIKit

/// An easy class to manage online images in Swift.
///
/// Reference and more info: [https://github.com/illescasDaniel/CachedImages]()
///
public final class CachedImages {
	
	public class LoadCachedImage {
		
		private let stringURL: String
		private var placeholderImage: UIImage? = nil
		
		public init(url: String) {
			self.stringURL = url
		}
		
		public func placeholder(image: UIImage) -> LoadCachedImage {
			placeholderImage = image
			return self
		}
		
		public func into(imageView: UIImageView) {
			DispatchQueue.main.async {
				if let placeholderImage = self.placeholderImage {
					imageView.image = placeholderImage
				}
			}
			CachedImages.shared.load(url: stringURL, onSuccess: { image in
				imageView.image = image
			})
		}
		public func into(buttonImage: UIButton) {
			DispatchQueue.main.async {
				if let placeholderImage = self.placeholderImage {
					buttonImage.setImage(placeholderImage, for: .normal)
				}
			}
			CachedImages.shared.load(url: stringURL, onSuccess: { image in
				buttonImage.setImage(image, for: .normal)
			})
		}
	}
	
	public enum Errors: Error {
		case emptyURL
		case couldNotSaveImage
		case couldNotDownloadImage
	}
	
	private let cachedImagesFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(".cachesImages")
	
	public static let shared = CachedImages()
	fileprivate init() { self.createImagesFolderIfItDoesntExist() }
	
	public func load(image imageURL: String, into imageView: UIImageView, placeholder: UIImage? = nil) {
		let loadCachedImage = LoadCachedImage(url: imageURL)
		if let placeholderImage = placeholder {
			let _ = loadCachedImage.placeholder(image: placeholderImage)
		}
		loadCachedImage.into(imageView: imageView)
	}
	
	public func load(image imageURL: String) -> LoadCachedImage {
		return LoadCachedImage(url: imageURL)
	}
	
	public func exists(withURL url: String) -> Bool {
		return self.exists(withKey: url.hash)
	}
	
	public func saveImage(withURL url: String, onError: @escaping (CachedImages.Errors) -> () = {_ in }) {
		
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
				if let validImageData = downloadedImage.jpegData(compressionQuality: 0.95) {
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
	
	public func load(url: String,
					 onSuccess: @escaping (UIImage) -> (),
					 prepareForDownload: @escaping () -> () = {},
					 onError: @escaping (CachedImages.Errors) -> () = {_ in }) {
		
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
				
				DownloadManager.shared.manageData(from: URL(string: trimmedURL)) { data in
					if let data = data, let validImage = UIImage(data: data) {
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
	@discardableResult
	public func clear() -> Bool {
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
		
		let cachedImagePath = self.cachedImagesFolder.appendingPathComponent("\(key)")
		
		if let imageData = try? Data(contentsOf: cachedImagePath) {
			return UIImage(data: imageData)
		}
		return nil
	}
	
	private func asyncSave(image: UIImage, withKey key: Int, onError: @escaping (CachedImages.Errors) -> () = {_ in}) {
		
		DispatchQueue.global().async {
			
			let cachedImage = self.cachedImagesFolder.appendingPathComponent("\(key)", isDirectory: false)
			guard !FileManager.default.fileExists(atPath: cachedImage.path) else { return }
			
			if let validImageData = image.jpegData(compressionQuality: 0.95) {
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
