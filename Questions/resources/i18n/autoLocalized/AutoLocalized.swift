import Foundation

var output = """
/* Automatically generated with "AutoLocalized.swift" */
class Localized {

"""

if let stringsDictionary = NSDictionary(contentsOfFile: "../en.lproj/Localizable.strings") as? [String: String] {
	for (key, _) in stringsDictionary where key.starts(with: "**") {
		let simpleName = key.trimmingCharacters(in: CharacterSet(charactersIn: "*"))
		output += """
			static let \(simpleName.replacingOccurrences(of: ".", with: "_")) = "\(key)".localized\n
		"""
	}
}


output += """
}
"""
print(output)
let url = URL(fileURLWithPath: "../Localized.swift")
if ((try? output.write(to: url, atomically: true, encoding: .utf8)) == nil) {
	print("Error writing Localized.swift")
}
	