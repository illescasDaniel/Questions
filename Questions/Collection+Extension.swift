import GameplayKit.GKRandomSource // .shuffled

extension Collection {
	func shuffled() -> [Iterator.Element] {
		let shuffledArray = (self as? NSArray)?.shuffled()
		let outputArray = shuffledArray as? [Iterator.Element]
		return outputArray ?? []
	}
	mutating func shuffle() {
		if let selfShuffled = self.shuffled() as? Self {
			self = selfShuffled
		}
	}
}
