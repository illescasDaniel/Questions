import Foundation

struct Quiz {
	static let setNames = NSArray(contentsOfFile: Bundle.main.path(forResource: "Quiz", ofType: "plist")!)! as! [String]
	static let technology = loadPlist(quiz: "Technology")
	static let social = loadPlist(quiz: "Social")
	static let people = loadPlist(quiz: "People")
	
	static let test = loadPlist(quiz: "Test")
	
	static func loadPlist(quiz: String) -> [[NSDictionary]] {
		return NSArray(contentsOfFile: Bundle.main.path(forResource: quiz, ofType: "plist")!)! as! [[NSDictionary]]
	}
}
