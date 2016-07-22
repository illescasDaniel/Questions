import Foundation

class Settings: NSObject, NSCoding {

	static let path = "\(Settings.documentsDirectory())/Settings.archive"
	var musicEnabled = Bool()
	var completedSets: [Bool] = []

	override init() {
		musicEnabled = true
		completedSets = [Bool](count: 3, repeatedValue: false)//[Bool](count: Quiz.set.count, repeatedValue: false)
	}

	func encodeWithCoder(archiver: NSCoder) {

		archiver.encodeBool(musicEnabled, forKey: "Music")
		archiver.encodeObject(completedSets, forKey: "Completed sets")
	}

	required init (coder unarchiver: NSCoder) {
		super.init()

		musicEnabled = unarchiver.decodeBoolForKey("Music")
		completedSets = unarchiver.decodeObjectForKey("Completed sets") as! [Bool]
	}

	func save() -> Bool {
		return NSKeyedArchiver.archiveRootObject(self, toFile: Settings.path)
	}

	static func documentsDirectory() -> String {
		return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
	}
}
