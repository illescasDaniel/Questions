import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var wasPlaying = Bool()
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		
		if Audio.bgMusic?.isPlaying ?? false {
			Audio.bgMusic?.pause()
			wasPlaying = true
		}
		else {
			wasPlaying = false
		}
		
		guard Settings.sharedInstance.save() else {	print("Error saving settings"); return }
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		
		if wasPlaying {
			Audio.bgMusic?.play()
		}
	}
}
