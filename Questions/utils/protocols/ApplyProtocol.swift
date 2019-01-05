//
//  ApplyProtocol.swift
//
//  Created by Daniel Illescas Romero
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import Foundation

protocol ApplyProtocol { }
extension ApplyProtocol {
	@discardableResult
	func apply(closure: (Self) -> ()) -> Self {
		closure(self)
		return self
	}
}
