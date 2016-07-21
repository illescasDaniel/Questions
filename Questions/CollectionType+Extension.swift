import GameplayKit

extension CollectionType {

	func shuffle() -> [AnyObject] {
		return GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(self as! AnyObject as! [AnyObject])
	}
}
