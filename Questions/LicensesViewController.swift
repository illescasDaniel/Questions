import UIKit

class LicensesViewController: UIViewController {

	@IBOutlet weak var licensesNavItem: UINavigationItem!
	@IBOutlet weak var textView: UITextView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		licensesNavItem.title = "Licenses".localized
		
		textView.attributedText = licensesAttributedText()
		
		let darkModeEnabled = Settings.sharedInstance.darkThemeEnabled
		textView.backgroundColor = darkModeEnabled ? .gray : .white
		textView.textColor = darkModeEnabled ? .white : .black
		textView.tintColor = darkModeEnabled ? .warmYellow : .coolBlue
    }

	func licensesAttributedText() -> NSMutableAttributedString {
		
		let subheadFontStyle = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .subheadline)]
		let headlineFontStyle = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline)]
		
		let bgMusicBensound = "Royalty Free Music from Bensound: \n"
		let bgMusicBensoundLink = "http://www.bensound.com/royalty-free-music/track/the-lounge \n"
		
		let correctSound = "\nCorrect.mp3, creator: LittleRainySeasons: \n"
		let correctSoundLink = "https://www.freesound.org/people/LittleRainySeasons/sounds/335908 \n"
		
		let incorrectSound = "\nFailure 01.wav, creator: rhodesmas\n\"This work is licensed under the Attribution License.\": \n"
		let incorrectSoundLink = "https://www.freesound.org/people/rhodesmas/sounds/342756/ \n https://creativecommons.org/licenses/by/3.0/legalcode"
		
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
}
