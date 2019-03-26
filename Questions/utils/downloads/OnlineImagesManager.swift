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
	public func preloadImage(withURL url: String?, onError: @escaping (DownloadManager.Errors) -> () = {_ in }) {
		DownloadManager.shared.manageData(from: url, onSuccess: { _ in
			// empty on purpose
		}, onError: onError)
	}
	
	public func load(url: String,
					 prepareForDownload: @escaping () -> () = {},
					 onSuccess: @escaping (UIImage) -> (),
					 onError: @escaping (DownloadManager.Errors) -> () = {_ in }) {

		DispatchQueue.main.async {
			prepareForDownload()
		}
		
		DownloadManager.shared.manageData(from: url, onSuccess:  { data in
			if let validImage = UIImage(data: data) { // TODO: use global async here
				DispatchQueue.main.async {
					onSuccess(validImage)
				}
			}
		}, onError: onError)
	}
}
