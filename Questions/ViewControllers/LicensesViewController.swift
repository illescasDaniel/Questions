import UIKit

class LicensesViewController: UIViewController {

	@IBOutlet weak var textView: UITextView!
	
	private lazy var licensesAttributedText: NSAttributedString = {

		let headlineFontStyle = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
		let subheadFontStyle = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
		
		let bgMusicBensound = "Royalty Free Music from Bensound:\n".attributedStringWith(headlineFontStyle)
		let bgMusicBensoundLink = "http://www.bensound.com/royalty-free-music/track/the-lounge\n".attributedStringWith(subheadFontStyle)

		let correctSound = "\nCorrect.mp3, creator: LittleRainySeasons:\n".attributedStringWith(headlineFontStyle)
		let correctSoundLink = "https://www.freesound.org/people/LittleRainySeasons/sounds/335908\n".attributedStringWith(subheadFontStyle)
		
		let incorrectSound = "\nGame Sound Wrong.wav, creator: Bertrof\n\"This work is licensed under the Attribution License.\": \n".attributedStringWith(headlineFontStyle)
		let incorrectSoundLink = "https://www.freesound.org/people/Bertrof/sounds/131657/\n https://creativecommons.org/licenses/by/3.0/legalcode\n".attributedStringWith(subheadFontStyle)
		
		let sideVolumeHUD = "\nSideVolumeHUD - illescasDaniel. Licensed under the MIT License\n".attributedStringWith(headlineFontStyle)
		let sideVolumeHUDLink = "https://github.com/illescasDaniel/SideVolumeHUD\n".attributedStringWith(subheadFontStyle)
		
		let icons = "\nIcons 8\n".attributedStringWith(headlineFontStyle)
		let icon1 = "https://icons8.com/icon/1054/screenshot".attributedStringWith(subheadFontStyle)
		let icon2 = "https://icons8.com/icon/8186/create-filled".attributedStringWith(subheadFontStyle)
		let icon3 = "https://icons8.com/icon/2897/cloud-filled".attributedStringWith(subheadFontStyle)
		
		let attributedText = bgMusicBensound + bgMusicBensoundLink + correctSound + correctSoundLink + incorrectSound + incorrectSoundLink + sideVolumeHUD + sideVolumeHUDLink + icons + icon1 + icon2 + icon3
		
		return attributedText
	}()
	
	// MARK: View life cycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.title = Localized.Settings_Options_Licenses
		
		self.textView.attributedText = licensesAttributedText
		self.textView.textAlignment = .center
		self.textView.textContainerInset = UIEdgeInsets(top: 30, left: 10, bottom: 30, right: 10)
		self.loadCurrentTheme()
		
		self.textView.frame = UIScreen.main.bounds
		self.textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
	
	// MARK: Convenience
	
	@IBAction internal func loadCurrentTheme() {
		
		textView.tintColor = .themeStyle(dark: .warmColor, light: .coolBlue)
		
		if UserDefaultsManager.darkThemeSwitchIsOn {
			textView.backgroundColor = .themeStyle(dark: .black, light: .white)
			textView.textColor = .themeStyle(dark: .white, light: .black)
		}
	}
}
