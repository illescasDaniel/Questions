import AVFoundation

extension AVAudioPlayer {
	
	convenience init?(file: String, type: String) {
		
		guard let path = Bundle.main.path(forResource: file, ofType: type) else { print("Incorrect audio path"); return nil }
		let url = URL(fileURLWithPath: path)
		
		try? self.init(contentsOf: url)
	}
}
