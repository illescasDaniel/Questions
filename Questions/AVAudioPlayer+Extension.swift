import AVFoundation

extension AVAudioPlayer {
	
	convenience init?(file: String, type: String) {
		
		let path = Bundle.main.path(forResource: file, ofType: type)
		let url = URL(fileURLWithPath: path!)

		do {
			try self.init(contentsOf: url)
		} catch {
			return nil
		}
	}
}
