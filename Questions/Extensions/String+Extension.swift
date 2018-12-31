import Foundation

extension String {
	
	var localized: String {
		return NSLocalizedString(self, comment: "")
	}
	
	func attributedStringWith(_ attributes: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString {
		return NSAttributedString(string: self, attributes: attributes)
	}
	
	var deletingPathExtension: String {
		return (self as NSString).deletingPathExtension
	}
	
	/// Levenshtein distance returning a value from 0.0 to 1.0 indicating the similarity to other string
	public func similarityTo(string: String, ignoreCase: Bool = true, trimWhiteSpacesAndNewLines: Bool = true) -> Float {
		
		guard !self.isEmpty && !string.isEmpty else { return 0.0 }
		if self.count == string.count && self == string { return 1.0 }
		
		var firstString = self
		var secondString = string
		
		if ignoreCase {
			firstString = firstString.lowercased()
			secondString = secondString.lowercased()
			if firstString.count == secondString.count && firstString == secondString { return 1.0 }
		}
		if trimWhiteSpacesAndNewLines {
			firstString = firstString.trimmingCharacters(in: .whitespacesAndNewlines)
			secondString = secondString.trimmingCharacters(in: .whitespacesAndNewlines)
			guard !firstString.isEmpty && !secondString.isEmpty else { return 0.0 }
			if firstString.count == secondString.count && firstString == secondString { return 1.0 }
		}
		
		let empty = [Int](repeating:0, count: secondString.count)
		var last = [Int](0...secondString.count)
		
		for (i, tLett) in firstString.enumerated() {
			var cur = [i + 1] + empty
			for (j, sLett) in secondString.enumerated() {
				cur[j + 1] = tLett == sLett ? last[j] : Swift.min(last[j], last[j + 1], cur[j])+1
			}
			last = cur
		}
		
		// maximum string length between the two
		let lowestScore = max(firstString.count, secondString.count)
		
		if let validDistance = last.last {
			return  1 - (Float(validDistance) / Float(lowestScore))
		}
		
		return 0.0
	}
}

extension NSAttributedString {
	static func +(left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
		let result = NSMutableAttributedString()
		result.append(left)
		result.append(right)
		return result
	}
}

extension CustomStringConvertible {
	var description: String {
		return String(describing: Self.self) + "(" + Mirror(reflecting: self).children.map({ ($0 ?? "Unknown") + ": \($1)" }).joined(separator: ", ") + ")"
	}
}
