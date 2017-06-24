import Foundation
import GameplayKit // .shuffled

extension Collection {
	
	/// Return a copy of `self` with its elements shuffled
	func shuffled() -> [Iterator.Element] {
		
		if #available(iOS 10.0, *) {
			let shuffledArray = (self as? NSArray)?.shuffled()
			return shuffledArray as! [Self.Iterator.Element]
		}
		
		var list = Array(self)
		list.shuffleInPlace()
		return list
	}
}

extension MutableCollection where Index == Int {
	
	/// Shuffle the elements of `self` in-place.
	mutating func shuffleInPlace() {

		if count < 2 { return }
		
		for i in 0..<count.hashValue {
			let j = Int(arc4random_uniform(UInt32(count.hashValue - i))) + i
			guard i != j else { continue }
			self.swapAt(i, j)
		}
	}
}

