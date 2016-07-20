import Foundation

class Settings: NSObject, NSCoding {
	
	var music = Bool()
	//var questionSets: [[Quiz]] = [[]]
	var completedSets: [Bool] = []
	static var path = "\(Settings.documentsDirectory())/Settings.archive"
	
	override init() {
		//questionSets = Quiz.sets
		music = true
		completedSets = [Bool](count: Quiz.setsCount, repeatedValue: false)
	}
	
	func encodeWithCoder(archiver: NSCoder) {
		
		archiver.encodeBool(music, forKey: "Music")
		//archiver.encodeObject(questionSets as? AnyObject, forKey:"Question sets")
		archiver.encodeObject(completedSets, forKey:"Completed sets")
	}
	
	required init (coder unarchiver: NSCoder) {
		
		super.init()
		music = unarchiver.decodeBoolForKey("Music")
		//questionSets = unarchiver.decodeObjectForKey("Question sets") as! [[Quiz]]
		completedSets = unarchiver.decodeObjectForKey("Completed sets") as! [Bool]
	}
	
	func save() -> Bool {
		return NSKeyedArchiver.archiveRootObject(self, toFile: Settings.path)
	}
	
	static func documentsDirectory() -> String {
		return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
	}
}
