import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var wasPlaying = Bool()
	
	// Home Screen Quick Actions [3D Touch]

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		
		// Load configuration file (if it doesn't exist it creates a new one when the app goes to background)
		if let mySettings = NSKeyedUnarchiver.unarchiveObject(withFile: Settings.path) as? Settings {
			Settings.sharedInstance = mySettings
		}
		
		if #available(iOS 9.0, *) {
			
			let nightMode = UIMutableApplicationShortcutItem(type: "DarkTheme",
															 localizedTitle: "Dark Theme".localized,
															 localizedSubtitle: nil,
															 icon: UIApplicationShortcutIcon(templateImageName: "DarkThemeIcon"),
															 userInfo: nil)
			
			let lightMode = UIMutableApplicationShortcutItem(type: "LightTheme",
															 localizedTitle: "Light Theme".localized,
															 localizedSubtitle: nil,
															 icon: UIApplicationShortcutIcon(templateImageName: "LightThemeIcon"),
															 userInfo: nil)
			
			application.shortcutItems = [nightMode, lightMode]
		}
		
		return true
	}
	
	enum ShortcutItemType: String {
		case DarkTheme
		case LightTheme
	}
	
	@available(iOS 9.0, *)
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		
		if let itemType = ShortcutItemType(rawValue: shortcutItem.type) {
			switch itemType {
				case .DarkTheme:
					Settings.sharedInstance.darkThemeEnabled = true
					//AppDelegate.nightModeEnabled = true
				case .LightTheme:
					Settings.sharedInstance.darkThemeEnabled = false
					//AppDelegate.nightModeEnabled = false
			}
		}
	}
	
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
