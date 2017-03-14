import Foundation

struct Quiz {
	
	static let topicsNames = NSArray(contentsOfFile: Bundle.main.path(forResource: "QuizTopics", ofType: "plist")!)! as! [String]
	static let technology = loadPlist(quiz: "Technology")
	static let social = loadPlist(quiz: "Social")
	static let people = loadPlist(quiz: "People")
	
	static func loadPlist(quiz: String) -> [[NSDictionary]] {
		return NSArray(contentsOfFile: Bundle.main.path(forResource: quiz, ofType: "plist")!)! as! [[NSDictionary]]
	}
}
