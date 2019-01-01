import UIKit

public final class OnlineImagesManager {
	
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
			OnlineImagesManager.shared.load(url: stringURL, onSuccess: { image in
				imageView.image = image
			})
		}
		public func into(buttonImage: UIButton) {
			DispatchQueue.main.async {
				if let placeholderImage = self.placeholderImage {
					buttonImage.setImage(placeholderImage, for: .normal)
				}
			}
			OnlineImagesManager.shared.load(url: stringURL, onSuccess: { image in
				buttonImage.setImage(image, for: .normal)
			})
		}
	}
	
	public enum Errors: Error {
		case emptyURL
		case couldNotSaveImage
		case couldNotDownloadImage
	}

	public static let shared = OnlineImagesManager()
	fileprivate init() { }
	
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

	// TODO: might need some testing to check if is worth it, but it should since it downloads the image and stores it in a file that will later be used
	public func preloadImage(withURL url: String, onError: @escaping (OnlineImagesManager.Errors) -> () = {_ in }) {
			
		let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedURL.isEmpty else {
			DispatchQueue.main.async {
				onError(.emptyURL)
			}
			return
		}
	
		UIImage.manageContentsOf(URL(string: trimmedURL), completionHandler: { (downloadedImage, url) in
			// empty on purpose
		}, errorHandler: {
			onError(.couldNotDownloadImage)
		})
	}
	
	public func load(url: String,
					 onSuccess: @escaping (UIImage) -> (),
					 prepareForDownload: @escaping () -> () = {},
					 onError: @escaping (OnlineImagesManager.Errors) -> () = {_ in }) {
			
		let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedURL.isEmpty else {
			DispatchQueue.main.async {
				onError(.emptyURL)
			}
			return
		}

		DispatchQueue.main.async {
			prepareForDownload()
		}

		DownloadManager.shared.manageData(from: URL(string: trimmedURL)) { data in
			if let data = data, let validImage = UIImage(data: data) {
				DispatchQueue.main.async {
					onSuccess(validImage)
				}
			} else {
				DispatchQueue.main.async {
					onError(.couldNotDownloadImage)
				}
			}
		}
	}
}
