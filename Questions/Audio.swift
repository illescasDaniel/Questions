import UIKit
import AVFoundation

class Audio {
	
	static var bgMusic: AVAudioPlayer?
	static var bgMusicVolume: Float = 0.12
	static var correct: AVAudioPlayer?
	static var incorrect: AVAudioPlayer?
	
	static func setVolumeLevel(to volume: Float) {
		
		if #available(iOS 10.0, *) {
			Audio.bgMusic?.setVolume(volume, fadeDuration: 1)
		} else {
			Audio.bgMusic?.volume = volume
		}
	}
}
