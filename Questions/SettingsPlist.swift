import Foundation

struct Settings {
	
	static func valueForKey(key: String) -> NSObject {
		return PlistManager.sharedInstance.getValueForKey(key)! as! NSObject
	}
	
	static func saveValue(value: AnyObject, forKey: String) {
		PlistManager.sharedInstance.saveValue(value, forKey: forKey)
	}
}
