import UIKit

class LicensesViewController: UIViewController {

	@IBOutlet weak var licensesNavItem: UINavigationItem!
	@IBOutlet weak var textView: UITextView!
	
	// MARK: View life cycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		licensesNavItem.title = "Licenses".localized
		
		textView.attributedText = licensesAttributedText()
		textView.textAlignment = .center
		textView.textContainerInset = UIEdgeInsets(top: 30, left: 10, bottom: 30, right: 10)
		loadCurrentTheme()
		
		setFrame()
		
		NotificationCenter.default.addObserver(self, selector: #selector(setFrame),
		                                       name: Notification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(loadCurrentTheme),
		                                       name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
	
	@available(iOS, deprecated: 9.0)
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: Convenience
	
	func loadCurrentTheme() {
		textView.backgroundColor = .themeStyle(dark: .gray, light: .white)
		textView.textColor = .themeStyle(dark: .white, light: .black)
		textView.tintColor = .themeStyle(dark: .warmYellow, light: .coolBlue)
	}
	
	func setFrame() {
		textView.frame = UIScreen.main.bounds
	}

	func licensesAttributedText() -> NSMutableAttributedString {
		
		let subheadFontStyle = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .subheadline)]
		let headlineFontStyle = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline)]
		
		let bgMusicBensound = "Royalty Free Music from Bensound:\n"
		let bgMusicBensoundLink = "http://www.bensound.com/royalty-free-music/track/the-lounge \n"
		
		let correctSound = "\nCorrect.mp3, creator: LittleRainySeasons:\n"
		let correctSoundLink = "https://www.freesound.org/people/LittleRainySeasons/sounds/335908 \n"
		
		let incorrectSound = "\nGame Sound Wrong.wav, creator: Bertrof\n\"This work is licensed under the Attribution License.\": \n"
		let incorrectSoundLink = "https://www.freesound.org/people/Bertrof/sounds/131657/ \n https://creativecommons.org/licenses/by/3.0/legalcode"
		
		let attributedLicencesText = NSMutableAttributedString(string: bgMusicBensound + bgMusicBensoundLink +
																		correctSound + correctSoundLink +
																		incorrectSound + incorrectSoundLink,
		                                                       attributes: subheadFontStyle)
		
		var charactersCount = 0
		
		attributedLicencesText.addAttributes(headlineFontStyle, range: NSRange(location: charactersCount, length: bgMusicBensound.characters.count))
		
		charactersCount += bgMusicBensound.characters.count
		attributedLicencesText.addAttributes(headlineFontStyle,
		                                     range: NSRange(location: charactersCount + bgMusicBensoundLink.characters.count,
		                                                    length: correctSound.characters.count))
		
		charactersCount += bgMusicBensoundLink.characters.count
		attributedLicencesText.addAttributes(headlineFontStyle,
		                                     range: NSRange(location: charactersCount + correctSound.characters.count + correctSoundLink.characters.count,
		                                                    length: incorrectSound.characters.count))
		
		return attributedLicencesText
	}
	
	// MARK: UnwindSegue
	
	@IBAction func unwindToLicenses(_ unwindSegue: UIStoryboardSegue) {	}
}
