import UIKit

class LicensesViewController: UIViewController {

	@IBOutlet weak var textView: UITextView!
	
	private lazy var licensesAttributedText: NSAttributedString = {

		let headlineFontStyle = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline)]
		let subheadFontStyle = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline)]
		
		let bgMusicBensound = "Royalty Free Music from Bensound:\n".attributedStringWith(headlineFontStyle)
		let bgMusicBensoundLink = "http://www.bensound.com/royalty-free-music/track/the-lounge\n".attributedStringWith(subheadFontStyle)

		let correctSound = "\nCorrect.mp3, creator: LittleRainySeasons:\n".attributedStringWith(headlineFontStyle)
		let correctSoundLink = "https://www.freesound.org/people/LittleRainySeasons/sounds/335908\n".attributedStringWith(subheadFontStyle)
		
		let incorrectSound = "\nGame Sound Wrong.wav, creator: Bertrof\n\"This work is licensed under the Attribution License.\": \n".attributedStringWith(headlineFontStyle)
		let incorrectSoundLink = "https://www.freesound.org/people/Bertrof/sounds/131657/\n https://creativecommons.org/licenses/by/3.0/legalcode\n".attributedStringWith(subheadFontStyle)
		
		let volumeBar = "\nVolumeBar - gizmosachin. Licensed under the MIT License\n".attributedStringWith(headlineFontStyle)
		let volumeBarLink = "https://github.com/gizmosachin/VolumeBar".attributedStringWith(subheadFontStyle)
		
		let attributedText = bgMusicBensound + bgMusicBensoundLink + correctSound + correctSoundLink + incorrectSound + incorrectSoundLink + volumeBar + volumeBarLink
		
		return attributedText
	}()
	
	// MARK: View life cycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.title = "Licenses".localized
		
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

