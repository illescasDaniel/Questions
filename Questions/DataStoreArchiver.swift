import UIKit

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
