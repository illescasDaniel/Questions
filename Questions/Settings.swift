import Foundation

class Settings: NSObject, NSCoding {
	
	static let path = "\(Settings.documentsDirectory())/Settings.archive"
	var musicEnabled = true
	var completedSets = [Bool](repeating: false, count: Quiz.set.count)
	var correctAnswers: Int32 = 0
	var incorrectAnswers: Int32 = 0

	static var sharedInstance = Settings()
	fileprivate override init() { }

	func encode(with archiver: NSCoder) {
		archiver.encodeCInt(correctAnswers, forKey: "Correct answers")
		archiver.encodeCInt(incorrectAnswers, forKey: "Incorrect answers")
		archiver.encode(musicEnabled, forKey: "Music")
		archiver.encode(completedSets, forKey: "Completed sets")
	}

	required init (coder unarchiver: NSCoder) {
		super.init()
		correctAnswers = unarchiver.decodeCInt(forKey: "Correct answers")
		incorrectAnswers = unarchiver.decodeCInt(forKey: "Incorrect answers")
		musicEnabled = unarchiver.decodeBool(forKey: "Music")
		completedSets = unarchiver.decodeObject(forKey: "Completed sets") as! [Bool]
	}

	func save() -> Bool {
		return NSKeyedArchiver.archiveRootObject(self, toFile: Settings.path)
	}

	static func documentsDirectory() -> String {
		return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
	}
}
