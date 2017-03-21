import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var wasPlaying = Bool()
	static var nightModeEnabled = false
	
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
	
	// Home Screen Quick Actions [3D Touch]

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		
		if #available(iOS 9.0, *) {
			
			let nightMode = UIMutableApplicationShortcutItem(type: "DarkTheme",
															 localizedTitle: "Night Mode".localized,
															 localizedSubtitle: "Switches to dark theme".localized,
															 icon: UIApplicationShortcutIcon(templateImageName: "DarkThemeIcon"),
															 userInfo: nil)
			
			let lightMode = UIMutableApplicationShortcutItem(type: "LightTheme",
															 localizedTitle: "Light Mode".localized,
															 localizedSubtitle: "Switches to light theme".localized,
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
					AppDelegate.nightModeEnabled = true
				case .LightTheme:
					AppDelegate.nightModeEnabled = false
			}
		}
	}
}
