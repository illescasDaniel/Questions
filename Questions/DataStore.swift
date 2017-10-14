import Foundation

class DataStore: NSObject, NSCoding {
	
	static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
	static let path = "\(DataStore.documentsDirectory)/DataStore.archive"
	
	var completedSets: [String: [Int:Bool]] = [:]
	
	static var shared = DataStore()
	fileprivate override init() { }

	func encode(with archiver: NSCoder) {
		archiver.encode(completedSets, forKey: "completedSets")
	}

	required init (coder unarchiver: NSCoder) {
		super.init()
		
		if let completedSets = unarchiver.decodeObject(forKey: "completedSets") as? [String: [Int:Bool]] {
			self.completedSets = completedSets
		}
	}

	func save() -> Bool {
		return NSKeyedArchiver.archiveRootObject(self, toFile: DataStore.path)
	}
}
