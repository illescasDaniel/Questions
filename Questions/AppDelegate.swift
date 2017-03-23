import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var wasPlaying = Bool()
	
	// Home Screen Quick Actions [3D Touch]

	enum ShortcutItemType: String {
		case QRCode
		case DarkTheme
		case LightTheme
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		
		// Load configuration file (if it doesn't exist it creates a new one when the app goes to background)
		if let mySettings = NSKeyedUnarchiver.unarchiveObject(withFile: Settings.path) as? Settings {
			Settings.sharedInstance = mySettings
		}
		
		if #available(iOS 9.0, *) {
			
			let readQRCode = UIMutableApplicationShortcutItem(type: ShortcutItemType.QRCode.rawValue,
			                                                 localizedTitle: "Read QR Code".localized,
			                                                 localizedSubtitle: nil,
			                                                 icon: UIApplicationShortcutIcon(templateImageName: "QRCodeIcon"),
			                                                 userInfo: nil)
			
			let darkTheme = UIMutableApplicationShortcutItem(type: ShortcutItemType.DarkTheme.rawValue,
															 localizedTitle: "Dark Theme".localized,
															 localizedSubtitle: nil,
															 icon: UIApplicationShortcutIcon(templateImageName: "DarkThemeIcon"),
															 userInfo: nil)
			
			let lightTheme = UIMutableApplicationShortcutItem(type: ShortcutItemType.LightTheme.rawValue,
															 localizedTitle: "Light Theme".localized,
															 localizedSubtitle: nil,
															 icon: UIApplicationShortcutIcon(templateImageName: "LightThemeIcon"),
															 userInfo: nil)
			
			application.shortcutItems = [readQRCode, darkTheme, lightTheme]
		}
		
		return true
	}
	
	
	
	@available(iOS 9.0, *)
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		
		if let itemType = ShortcutItemType(rawValue: shortcutItem.type) {
		
			switch itemType {
				case .QRCode:

					let storyboard = UIStoryboard(name: "Main", bundle: nil)
					let viewController = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
					
					let navController = UINavigationController.init(rootViewController: viewController)
					window?.rootViewController?.present(navController, animated: false, completion: nil)
				
					viewController.performSegue(withIdentifier: "QRScannerVC", sender: self)

				case .DarkTheme:
					Settings.sharedInstance.darkThemeEnabled = true
				case .LightTheme:
					Settings.sharedInstance.darkThemeEnabled = false
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
