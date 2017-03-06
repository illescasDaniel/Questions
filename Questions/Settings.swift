import Foundation

class Settings: NSObject, NSCoding {
	
	static let path = "\(Settings.documentsDirectory())/Settings.archive"
	var completedSets = [Bool](repeating: false, count: Quiz.set.count)
	var correctAnswers: Int = 0
	var incorrectAnswers: Int = 0
	var parallaxEnabled = true
	var musicEnabled = true
	var darkThemeEnabled = false

	static var sharedInstance = Settings()
	fileprivate override init() { }

	func encode(with archiver: NSCoder) {
		archiver.encode(correctAnswers, forKey: "Correct answers")
		archiver.encode(incorrectAnswers, forKey: "Incorrect answers")
		archiver.encode(darkThemeEnabled, forKey: "DarkTheme")
		archiver.encode(parallaxEnabled, forKey: "Parallax")
		archiver.encode(musicEnabled, forKey: "Music")
		archiver.encode(completedSets, forKey: "Completed sets")
	}

	required init (coder unarchiver: NSCoder) {
		super.init()
		correctAnswers = unarchiver.decodeInteger(forKey: "Correct answers")
		incorrectAnswers = unarchiver.decodeInteger(forKey: "Incorrect answers")
		darkThemeEnabled = unarchiver.decodeBool(forKey: "DarkTheme")
		parallaxEnabled = unarchiver.decodeBool(forKey: "Parallax")
		musicEnabled = unarchiver.decodeBool(forKey: "Music")
		completedSets = unarchiver.decodeObject(forKey: "Completed sets") as! [Bool]
	}

	func save() -> Bool {
		return NSKeyedArchiver.archiveRootObject(self, toFile: Settings.path)
	}

	private static func documentsDirectory() -> String {
		return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
	}
}
