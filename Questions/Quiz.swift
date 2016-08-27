import Foundation

struct Quiz {
	static let set = NSArray(contentsOfFile: Bundle.main.path(forResource: "Quiz", ofType: "plist")!)!
}
