import UIKit

class LicensesViewController: UIViewController {

	@IBOutlet weak var licensesNavItem: UINavigationItem!
	@IBOutlet weak var textView: UITextView!
	
	private lazy var licensesAttributedText: NSAttributedString = {

		let headlineFontStyle = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline)]
		let subheadFontStyle = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline)]
		
		let bgMusicBensound = "Royalty Free Music from Bensound:\n".attributedStringWith(headlineFontStyle)
		let bgMusicBensoundLink = "http://www.bensound.com/royalty-free-music/track/the-lounge \n".attributedStringWith(subheadFontStyle)

		let correctSound = "\nCorrect.mp3, creator: LittleRainySeasons:\n".attributedStringWith(headlineFontStyle)
		let correctSoundLink = "https://www.freesound.org/people/LittleRainySeasons/sounds/335908 \n".attributedStringWith(subheadFontStyle)
		
		let incorrectSound = "\nGame Sound Wrong.wav, creator: Bertrof\n\"This work is licensed under the Attribution License.\": \n".attributedStringWith(headlineFontStyle)
		let incorrectSoundLink = "https://www.freesound.org/people/Bertrof/sounds/131657/ \n https://creativecommons.org/licenses/by/3.0/legalcode".attributedStringWith(subheadFontStyle)

		let attributedText = bgMusicBensound + bgMusicBensoundLink + correctSound + correctSoundLink + incorrectSound + incorrectSoundLink
		
		return attributedText
	}()
	
	// MARK: View life cycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		licensesNavItem.title = "Licenses".localized
		
		textView.attributedText = licensesAttributedText
		textView.textAlignment = .center
		textView.textContainerInset = UIEdgeInsets(top: 30, left: 10, bottom: 30, right: 10)
		loadCurrentTheme()
		
		setFrame()
		
		NotificationCenter.default.addObserver(self, selector: #selector(setFrame), name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(loadCurrentTheme), name: .UIApplicationDidBecomeActive, object: nil)
    }
	
	@available(iOS, deprecated: 9.0)
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: Convenience
	
	@objc func loadCurrentTheme() {
		textView.backgroundColor = .themeStyle(dark: .gray, light: .white)
		textView.textColor = .themeStyle(dark: .white, light: .black)
		textView.tintColor = .themeStyle(dark: .warmYellow, light: .coolBlue)
	}
	
	@objc func setFrame() {
		textView.frame = UIScreen.main.bounds
	}
	
	// MARK: UnwindSegue
	
	@IBAction func unwindToLicenses(_ unwindSegue: UIStoryboardSegue) {	}
}

