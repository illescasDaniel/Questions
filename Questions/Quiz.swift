import Foundation

struct Quiz {
	
	private(set) var name = String()
	private(set) var plist: [[NSDictionary]]!
	
	init(name: String) {
		self.name = name
		plist = NSArray(contentsOfFile: Bundle.main.path(forResource: name, ofType: "plist")!)! as! [[NSDictionary]]
	}
	
	static let quizzes = [Quiz(name: "Technology"), Quiz(name: "Social"), Quiz(name: "People")]
}
