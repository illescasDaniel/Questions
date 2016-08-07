import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	func applicationDidEnterBackground(application: UIApplication) {
		Settings.sharedInstance.save() // MainViewController.settings.save()
	}
}
