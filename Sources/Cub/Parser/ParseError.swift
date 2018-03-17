//
//  ParseError.swift
//  Cub
//
//  Created by Louis D'hauwe on 22/10/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public protocol DisplayableError: Error {

	func description(inSource source: String) -> String

}

public struct ParseError: DisplayableError, CustomStringConvertible {

	/// The parse error type
	let type: ParseErrorType

	/// The range of the token in the original source code
	let range: Range<Int>?

	init(type: ParseErrorType, range: Range<Int>? = nil) {
		self.type = type
		self.range = range
	}

	public func description(inSource source: String) -> String {

		guard let startIndex = range?.lowerBound else {
			return type.description()
		}

		let lineNumber = source.lineNumber(of: startIndex)

		return type.description(atLine: lineNumber)
	}

	public var description: String {
		return "\(type)"
	}

}

extension String {

	func getLine(_ index: Int) -> String {
		
		if self.isEmpty && index == 1 {
			return ""
		}
		
		let newLineIndices = [0] + self.indices(of: "\n").map { (index) -> Int in
			return self.distance(from: self.startIndex, to: index)
		}
		
		if self.hasSuffix("\n") && index == newLineIndices.count + 1 {
			return ""
		}

		let startI = newLineIndices[index - 1]

		let startIndex = self.index(self.startIndex, offsetBy: startI)
		
		if let endI = newLineIndices[safe: index] {
			
			let endIndex = self.index(self.startIndex, offsetBy: endI)

			var line = String(self[startIndex..<endIndex])
			
			if line.hasPrefix("\n") {
				line.removeCharactersAtStart(1)
			}
			
			return line

		} else {
			
			var line = String(self[startIndex...])
			
			if line.hasPrefix("\n") {
				line.removeCharactersAtStart(1)
			}
			
			return line
		}
	}
	
	func lineNumber(of index: Int) -> Int {

		let i = self.distance(from: self.startIndex, to: self.index(self.startIndex, offsetBy: index))

		let newLineIndices = self.indices(of: "\n").map { (index) -> Int in
			return self.distance(from: self.startIndex, to: index)
		}

		var lineNumber = 1

		for newLineIndex in newLineIndices {

			if i > newLineIndex {

				lineNumber += 1

			} else {

				break

			}

		}

		return lineNumber
	}

	func indices(of string: String, options: String.CompareOptions = .literal) -> [String.Index] {
		var result: [String.Index] = []
		var start = startIndex

		while let range = range(of: string, options: options, range: start..<endIndex) {
			result.append(range.lowerBound)
			start = range.upperBound
		}

		return result
	}

}
