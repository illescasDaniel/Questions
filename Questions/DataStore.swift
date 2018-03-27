import UIKit

class DataStore: NSObject, NSCoding {
	
	enum Keys: String {
		case completedSets
		case cachedImages
	}
	
	static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
	static let path = "\(DataStore.documentsDirectory)/DataStore.archive"
	
	var completedSets: [String: [Int:Bool]] = [:]
	var cachedImages: [Int: Data] = [:]//[Int: UIImage] = [:]
	
	static var shared = DataStore()
	fileprivate override init() { }

	func encode(with archiver: NSCoder) {
		archiver.encode(completedSets, forKey: Keys.completedSets.rawValue)
		archiver.encode(cachedImages, forKey: Keys.cachedImages.rawValue)
	}

	required init (coder unarchiver: NSCoder) {
		super.init()
		
		if let completedSets = unarchiver.decodeObject(forKey: Keys.completedSets.rawValue) as? [String: [Int:Bool]] {
			self.completedSets = completedSets
		}
		
		if let cachedImages = unarchiver.decodeObject(forKey: Keys.cachedImages.rawValue) as? [Int: Data] {
			self.cachedImages = cachedImages
		}
	}
	
	func saveAsCache(image: UIImage, withKey key: Int) {
		if let validImageData = UIImageJPEGRepresentation(image, 0.95) {
			self.cachedImages[key] = validImageData
		}
	}
	
	func cachedImage(withKey key: Int) -> UIImage? {
		if let validData = self.cachedImages[key] {
			return UIImage(data: validData)
		}
		return nil
	}
	
	func save() -> Bool {
		return NSKeyedArchiver.archiveRootObject(self, toFile: DataStore.path)
	}
}
