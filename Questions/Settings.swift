import Foundation

class Settings: NSObject, NSCoding {

	static let path = "\(Settings.documentsDirectory())/Settings.archive"
	var musicEnabled = true
	var completedSets = [Bool](count: Quiz.set.count, repeatedValue: false)
	var correctAnswers: Int32 = 0
	var incorrectAnswers: Int32 = 0

	static var sharedInstance = Settings()
	private override init() { }

	func encodeWithCoder(archiver: NSCoder) {
		
		archiver.encodeInt(correctAnswers, forKey: "Correct answers")
		archiver.encodeInt(incorrectAnswers, forKey: "Incorrect answers")
		archiver.encodeBool(musicEnabled, forKey: "Music")
		archiver.encodeObject(completedSets, forKey: "Completed sets")
	}

	required init (coder unarchiver: NSCoder) {
		super.init()

		correctAnswers = unarchiver.decodeIntForKey("Correct answers")
		incorrectAnswers = unarchiver.decodeIntForKey("Incorrect answers")
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
