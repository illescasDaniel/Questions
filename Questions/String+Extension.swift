import Foundation

extension String {

	var localized: String {
		return NSLocalizedString(self, comment: "")
	}

	func localizedWithComment(comment: String) -> String {
		return NSLocalizedString(self, comment: comment)
	}
}
