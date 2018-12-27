import AVFoundation

extension AVAudioPlayer {
	
	enum AudioTypes: String {
		case mp3
		case wav
		// ...
	}
	
	convenience init?(file: String, type: AudioTypes, volume: Float? = nil) {
		
		guard let path = Bundle.main.path(forResource: file, ofType: type.rawValue) else { print("Incorrect audio path"); return nil }
		let url = URL(fileURLWithPath: path)
		
		try? self.init(contentsOf: url)
		
		if let validVolume = volume, validVolume >= 0.0 && validVolume <= 1.0 {
			self.volume = validVolume
		}
	}
	
	func setVolumeLevel(to volume: Float, duration: TimeInterval? = nil) {
		if #available(iOS 10.0, *) {
			self.setVolume(volume, fadeDuration: duration ?? 1)
		} else {
			self.volume = volume
		}
	}
}
