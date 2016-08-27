import GameplayKit

extension Array {

	func shuffle() -> Array {
		return GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self) as! Array<Element>
	}
	
	func objectEnumerator() -> NSEnumerator {
		return (self as NSArray).objectEnumerator()
	}
}
