import Foundation

struct Settings {
	
	static func valueForKey(key: String) -> NSObject {
		return PlistManager.sharedInstance.getValueForKey(key)! as! NSObject
	}
	
	static func saveValue(value: AnyObject, forKey: String) {
		PlistManager.sharedInstance.saveValue(value, forKey: forKey)
	}
}

func removeFile(file: String, from: String) {
	
	let fileManager = NSFileManager.defaultManager()
	
	do {
		try fileManager.removeItemAtPath("\(from)/\(file)")
	}
	catch {
		print(error)
	}
}

func documentsDirectory() -> String {
	return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
}