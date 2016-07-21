import AVFoundation

extension AVAudioPlayer {
	convenience init?(file: NSString, type: NSString) {
		let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
		let url = NSURL.fileURLWithPath(path!)

		do {
			try self.init(contentsOfURL: url)
		} catch {
			return nil
		}
	}
}
