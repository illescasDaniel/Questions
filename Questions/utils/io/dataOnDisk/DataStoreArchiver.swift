import UIKit

class DataStoreArchiver: NSObject, NSCoding, NSSecureCoding {
	
	static var supportsSecureCoding: Bool {
		return true
	}
	
	enum Keys: String {
		case completedSets
	}
	
	static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
	static let path = "\(documentsDirectory)/.DataStore.archive"
	
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
		if #available(iOS 11, *) {
			guard let data = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true) else {
				return false
			}
			return FileManager.default.createFile(atPath: Self.path, contents: data)
		} else {
			return NSKeyedArchiver.archiveRootObject(self, toFile: DataStoreArchiver.path)
		}
	}
}
