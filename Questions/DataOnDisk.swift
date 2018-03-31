import UIKit

class CachedImages {
	
	private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
	private var cachedImagesFolder: URL {
		return self.documentsDirectory.appendingPathComponent(".cachedImages")
	}
	
	static var shared = CachedImages()
	fileprivate init() {
		
		if !FileManager.default.fileExists(atPath: self.cachedImagesFolder.path) {
			if (try? FileManager.default.createDirectory(atPath: self.cachedImagesFolder.path, withIntermediateDirectories: false)) == nil {
				print("Error while creating the cached images directory")
			}
		}
	}
	
	func exists(key: Int) -> Bool {
		let validCachedImageURL = self.cachedImagesFolder.appendingPathComponent("\(key)")
		return FileManager.default.fileExists(atPath: validCachedImageURL.path)
	}
	
	func save(image: UIImage, withKey key: Int) {
		DispatchQueue.global().async {
			
			let cachedImage = self.cachedImagesFolder.appendingPathComponent("\(key)")
			guard !FileManager.default.fileExists(atPath: cachedImage.path) else { return }
			
			if let validImageData = UIImageJPEGRepresentation(image, 0.95) {
				if (try? validImageData.write(to: cachedImage)) == nil {
					print("Could not write image to folder")
				}
			}
		}
	}
	
	func image(withKey key: Int) -> UIImage? {
		
		let cachedImageURL = self.cachedImagesFolder.appendingPathComponent("\(key)")
		
		if let imageData = try? Data(contentsOf: cachedImageURL) {
			return UIImage(data: imageData)
		}
		return nil
	}
	
	func asyncManageImage(withKey key: Int, completionHandler: @escaping (UIImage) -> ()) {
		DispatchQueue.global().async {
			if let image = self.image(withKey: key) {
				DispatchQueue.main.async {
					completionHandler(image)
				}
			}
		}
	}
	
	@discardableResult func removeAll() -> Bool {
		return (try? FileManager.default.removeItem(atPath: self.cachedImagesFolder.path)) != nil
	}
}

class DataStoreArchiver: NSObject, NSCoding {
	
	enum Keys: String {
		case completedSets
	}
	
	static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
	static let path = "\(DataStoreArchiver.documentsDirectory)/.DataStore.archive"
	
	var completedSets: [String: [Int:Bool]] = [:]
	
	static var shared = DataStoreArchiver()
	fileprivate override init() { }

	func encode(with archiver: NSCoder) {
		archiver.encode(completedSets, forKey: Keys.completedSets.rawValue)
	}

	required init (coder unarchiver: NSCoder) {
		super.init()
		
		if let completedSets = unarchiver.decodeObject(forKey: Keys.completedSets.rawValue) as? [String: [Int:Bool]] {
			self.completedSets = completedSets
		}
	}
	
	func save() -> Bool {
		return NSKeyedArchiver.archiveRootObject(self, toFile: DataStoreArchiver.path)
	}
}
