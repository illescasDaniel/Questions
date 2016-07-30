import Foundation

struct Quiz {
	static let set = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Quiz", ofType: "plist")!)!
}