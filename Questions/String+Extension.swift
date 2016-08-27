import Foundation

extension String {
	
	var localized: String {
		return NSLocalizedString(self, comment: "")
	}

	func localized(withComment: String) -> String {
		return NSLocalizedString(self, comment: withComment)
	}
}
