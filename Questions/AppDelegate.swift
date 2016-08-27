import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		guard Settings.sharedInstance.save() else {	print("Error saving settings"); return }
	}
}
