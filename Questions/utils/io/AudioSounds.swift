import AVFoundation

class AudioSounds {
	static let bgMusic = AVAudioPlayer(file: "bensound-thelounge", type: .mp3, volume: AudioSounds.defaultBGMusicLevel)?.apply {
		$0.numberOfLoops = -1
	}
	static let correct = AVAudioPlayer(file: "correct", type: .mp3, volume: 0.10)
	static let incorrect = AVAudioPlayer(file: "incorrect", type: .wav, volume: 0.25)
	static let defaultBGMusicLevel: Float = 0.12
}
