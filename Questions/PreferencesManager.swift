/*
The MIT License (MIT)

Copyright (c) 2018 Daniel Illescas Romero <https://github.com/illescasDaniel/PreferencesManagerSwift>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation

@dynamicMemberLookup
class PreferencesManager {
	
	enum Properties: String {
		
		case backgroundMusicSwitch
		case hapticFeedbackSwitch
		case parallaxEffectSwitch
		case darkThemeSwitch
		case score
		case correctAnswers
		case incorrectAnswers
		case savedQuestionsCounter
		
		var defaultvalue: Any {
			switch self {
			case .backgroundMusicSwitch: return true
			case .hapticFeedbackSwitch: return true
			case .parallaxEffectSwitch: return true
			case .darkThemeSwitch: return false
			case .score: return 0
			case .correctAnswers: return 0
			case .incorrectAnswers: return 0
			case .savedQuestionsCounter: return 0
			}
		}
		
		/// Custom classes must conform to `Codable` protocol
		enum Custom: String {
			case user
		}
	}
	
	static let standard = PreferencesManager()
	private let userDefaults: UserDefaults
	
	init() { self.userDefaults = .standard }
	
	init?(suiteName: String) {
		if let validUserDefaults = UserDefaults(suiteName: suiteName) {
			self.userDefaults = validUserDefaults
		}
		return nil
	}
	
	func valueOrDefault<T>(for property: Properties) -> T! {
		return self[property] ?? (property.defaultvalue as! T)
	}
	
	subscript<T>(property: Properties, default defaultvalue: T) -> T {
		return self[property] ?? defaultvalue
	}
	subscript<T: Codable>(property: Properties.Custom, default defaultvalue: T) -> T {
		return self[property] ?? defaultvalue
	}
	
	subscript<T>(property: Properties) -> T? {
		get { return self[dynamicMember: property.rawValue] }
		set { self[dynamicMember: property.rawValue] = newValue }
	}
	subscript<T>(dynamicMember propertyKey: String) -> T? {
		get { return self.userDefaults.value(fromKey: propertyKey) }
		set { self.userDefaults.set(newValue, forKey: propertyKey) }
	}
	
	subscript<T: Codable>(property: Properties.Custom) -> T? {
		get { return self.userDefaults.decodableValue(fromKey: property.rawValue) }
		set { self.userDefaults.set(newValue.inJSON, forKey: property.rawValue) }
	}
	
	func setMultiple(_ values: [Properties: Any]) {
		values.forEach { self[$0.key] = $0.value }
	}
	
	func setMultiple<T: Codable>(_ values: [Properties.Custom: T]) { // Might not be very useful because it would only allow one type (T)
		values.forEach { self[$0.key] = $0.value }
	}
	
	func remove(property: Properties) {
		self.userDefaults.removeObject(forKey: property.rawValue)
	}
}

extension UserDefaults {
	
	func value<T>(fromKey propertyKey: String) -> T? {
		guard self.object(forKey: propertyKey) != nil else { return nil }
		switch T.self {
		case is Int.Type: return self.integer(forKey: propertyKey) as? T
		case is String.Type: return self.string(forKey: propertyKey) as? T
		case is Double.Type: return self.double(forKey: propertyKey) as? T
		case is Float.Type: return self.float(forKey: propertyKey) as? T
		case is Bool.Type: return self.bool(forKey: propertyKey) as? T
		case is URL.Type: return self.url(forKey: propertyKey) as? T
		case is Data.Type: return self.data(forKey: propertyKey) as? T
		case is [String].Type: return self.stringArray(forKey: propertyKey) as? T
		case is [Any].Type: return self.array(forKey: propertyKey) as? T
		case is [String: Any?].Type: return self.dictionary(forKey: propertyKey) as? T
		default: return self.object(forKey: propertyKey) as? T
		}
	}
	
	func decodableValue<T: Decodable>(fromKey propertyKey: String) -> T? {
		guard self.object(forKey: propertyKey) != nil else { return nil }
		return self.string(forKey: propertyKey)?.decoded()
	}
}

extension Encodable {
	var inJSON: String {
		if let data = try? JSONEncoder().encode(self), let jsonQuiz = String(data: data, encoding: .utf8) {
			return jsonQuiz
		}
		return ""
	}
}

extension String {
	func decoded<T: Decodable>() -> T? {
		if let data = self.data(using: .utf8), let decodedValue = try? JSONDecoder().decode(T.self, from: data) {
			return decodedValue
		}
		return nil
	}
}
