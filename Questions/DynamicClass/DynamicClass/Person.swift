//
//  DynamicClass.swift
//  DynamicClass
//
//  Created by Daniel Illescas Romero on 05/09/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import Foundation

class Method {
	
	private let call_: (Any?) -> Any?
	
	func call() {
		let _ = call_(nil)
	}
	
	func withResult(parameter: Any?) -> Any? {
		return call_(parameter)
	}
	
	func with(parameter: Any?) {
		let _ = call_(parameter)
	}
	
	init(_ call: @escaping ((Any?) -> Any?)) {
		self.call_ = call
	}
	init(_ call: @escaping ((Any?) -> Void)) {
		self.call_ = { value in
			call(value)
			return nil
		}
	}
	init(_ call: @escaping (() -> Void)) {
		self.call_ = { _ in
			call()
			return nil
		}
	}
}

@dynamicMemberLookup
class Person: CustomStringConvertible {
	
	private lazy var values: [String: Any] = {[
		"name": "Daniel",
		"age": 21,
		"m_run": Method({
			print("running!")
		}),
		"m_nameTitle": Method({ name in
			return "Hi \(name!)"
		}),
		"d_otherThing": [
			"lol": 211,
			"wtf": "looool"
		],
		"a_numbers": [1,2,3,4]
	]}()
	
	var description: String {
		return self.values.description
	}
	
	public subscript(dynamicMember member: String) -> Any? {
		get {
			return self.values[member]
		}
		set {
			
			// we can protect some types of values with these
			if member.starts(with: "m_") && !(newValue is Method) { return }
			if member.starts(with: "d_") && !(newValue is Dictionary<String,Any>) { return }
			if member.starts(with: "a_") && !(newValue is Array<Any>) { return }
			
			// This might be too strict in my opinion
			// if !member.starts(with: "m_") && (newValue is Method) { return }
			// if !member.starts(with: "d_") && (newValue is Dictionary<String,Any>)) { return }
			// if !member.starts(with: "m_") && (newValue is Array<Any>) { return }
			
			self.values[member] = newValue
		}
	}
}
