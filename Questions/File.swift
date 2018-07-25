/*
The MIT License (MIT)

Copyright (c) 2018 Daniel Illescas Romero <https://github.com/illescasDaniel/Files-swift>

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

import class Foundation.NSFileManager.FileManager
import struct Foundation.URL

/// Manage files easier with this struct
public struct File {
	
	@discardableResult
	public static func save(_ content: String, to path: URL?) -> Bool {
		do {
			if let validURL = path {
				try content.write(to: validURL, atomically: true, encoding: .utf8)
			} else {
				return false
			}
		}
		catch {
			return false
		}
		return true
	}
	
	@discardableResult
	public static func append(_ newContent: String, to path: URL?) -> Bool {
		let previousContent = File.read(from: path) ?? ""
		return File.save(previousContent + newContent, to: path)
	}
	
	public static func read(from filePath: URL?) -> String? {
		
		var content = String()
		do {
			if let validURL = filePath {
				content = try String(contentsOf: validURL, encoding: .utf8)
			} else {
				return nil
			}
		}
		catch {
			return nil
		}
		
		return content
	}
	
	@discardableResult
	public static func copy(file filePath: URL?, to outputFilePath: URL?) -> Bool {
		guard let filePath = filePath, let outputFilePath = outputFilePath else { return false }
		do {
			try FileManager.default.copyItem(at: filePath, to: outputFilePath)
		} catch {
			return false
		}
		return true
	}
	
	@discardableResult
	public static func remove(file: String, from directory: String) -> Bool {
		do {
			try FileManager.default.removeItem(atPath: "\(directory)/\(file)")
		} catch {
			return false
		}
		return true
	}
	
	@discardableResult
	public static func remove(at filePath: URL?) -> Bool {
		guard let filePath = filePath else { return false }
		do {
			try FileManager.default.removeItem(at: filePath)
		} catch {
			return false
		}
		return true
	}
	
	public static var documentsDirectory: URL? {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	}
	
	public static var currentDirectory: URL? {
		return URL(string: FileManager.default.currentDirectoryPath)
	}
}
