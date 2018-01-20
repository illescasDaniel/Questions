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
	
	static var windowReference: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		
		UserDefaultsManager.loadDefaultValues()
		
		// Load configuration file (if it doesn't exist it creates a new one when the app goes to background)
		if let mySettings = NSKeyedUnarchiver.unarchiveObject(withFile: DataStore.path) as? DataStore {
			DataStore.shared = mySettings
		}
		
		Topic.loadSets()
		
		//
		
		AppDelegate.windowReference = self.window

		let navController = window?.rootViewController as? UINavigationController
		if #available(iOS 11.0, *) {
			navController?.navigationBar.prefersLargeTitles = true
		}
		
		if #available(iOS 9.0, *) {
			
			let readQRCode = UIMutableApplicationShortcutItem(type: ShortcutItemType.QRCode.rawValue,
			                                                 localizedTitle: "Scan QR Code".localized,
			                                                 localizedSubtitle: nil,
			                                                 icon: UIApplicationShortcutIcon(templateImageName: "QRCodeIcon"))
			
			let darkTheme = UIMutableApplicationShortcutItem(type: ShortcutItemType.DarkTheme.rawValue,
															 localizedTitle: "Dark Theme".localized,
															 localizedSubtitle: nil,
															 icon: UIApplicationShortcutIcon(templateImageName: "DarkThemeIcon"))
			
			let lightTheme = UIMutableApplicationShortcutItem(type: ShortcutItemType.LightTheme.rawValue,
															 localizedTitle: "Light Theme".localized,
															 localizedSubtitle: nil,
															 icon: UIApplicationShortcutIcon(templateImageName: "LightThemeIcon"))
			
			application.shortcutItems = [readQRCode, darkTheme, lightTheme]
		}

		AppDelegate.updateVolumeBarTheme()
		VolumeBar.shared.start()
		
		self.window?.dontInvertIfDarkModeIsEnabled()
		
		return true
	}

	static func updateVolumeBarTheme() {
		VolumeBar.shared.backgroundColor = .themeStyle(dark: .veryVeryDarkGray, light: .white)
		VolumeBar.shared.tintColor = .themeStyle(dark: .lightGray, light: .black)
		VolumeBar.shared.trackTintColor = .themeStyle(dark: UIColor.lightGray.withAlphaComponent(0.3), light: UIColor.black.withAlphaComponent(0.1))
	}
	
	@available(iOS 9.0, *)
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		
		if let itemType = ShortcutItemType(rawValue: shortcutItem.type) {
		
			switch itemType {
			
			case .QRCode:
				
				if let questionsVC = window?.rootViewController?.presentedViewController as? QuestionsViewController {
					questionsVC.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
				}
				
				if let presentedViewController = window?.rootViewController as? UINavigationController {
					
					if presentedViewController.topViewController is QRScannerViewController {
						return
					} else if !(presentedViewController.topViewController is MainViewController) {
						presentedViewController.popToRootViewController(animated: false)
					}
					
					presentedViewController.topViewController?.performSegue(withIdentifier: "QRScannerVC", sender: self)
				}
				else if (window?.rootViewController == nil) {
					
					let storyboard = UIStoryboard(name: "Main", bundle: nil)
					if let viewController = storyboard.instantiateViewController(withIdentifier: "mainViewController") as? MainViewController {
						
						let navController = UINavigationController(rootViewController: viewController)
						if #available(iOS 11.0, *) {
							navController.navigationBar.prefersLargeTitles = true
						}
						
						window?.rootViewController?.present(navController, animated: false)
						
						viewController.performSegue(withIdentifier: "QRScannerVC", sender: self)
					}
				}
				
			case .DarkTheme:
				UserDefaultsManager.darkThemeSwitchIsOn = true
				AppDelegate.updateVolumeBarTheme()
				
			case .LightTheme:
				UserDefaultsManager.darkThemeSwitchIsOn = false
				AppDelegate.updateVolumeBarTheme()
			}
		}
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		
		if AudioSounds.bgMusic?.isPlaying ?? false {
			AudioSounds.bgMusic?.pause()
			wasPlaying = true
		}
		else {
			wasPlaying = false
		}
		
		guard DataStore.shared.save() else {	print("Error saving settings"); return }
		
		self.window?.dontInvertIfDarkModeIsEnabled()
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		
		if wasPlaying {
			AudioSounds.bgMusic?.play()
		}
		
		self.window?.dontInvertIfDarkModeIsEnabled()
	}
}
