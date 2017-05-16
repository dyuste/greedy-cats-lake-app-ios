//
//  StringManipulation.swift
//  greedycats
//
//  Created by David Yuste on 10/11/15.
//  Copyright (c) 2015 David Yuste Romero
//
//  THIS MATERIAL IS PROVIDED AS IS, WITH ABSOLUTELY NO WARRANTY EXPRESSED
//  OR IMPLIED.  ANY USE IS AT YOUR OWN RISK.
//
//  Permission is hereby granted to use or copy this program
//  for any purpose,  provided the above notices are retained on all copies.
//  Permission to modify the code and to distribute modified code is granted,
//  provided the above notices are retained, and a notice that the code was
//  modified is included with the above copyright notice.
//

import Foundation

func StringToMd5(string : String) -> String {
	let data = (string as NSString).dataUsingEncoding(NSUTF8StringEncoding)
	let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))
	let resultBytes = UnsafeMutablePointer<CUnsignedChar>(result!.mutableBytes)
	CC_MD5(data!.bytes, CC_LONG(data!.length), resultBytes)
	
	let a = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: result!.length)
	let hash = NSMutableString()
	
	for i in a {
		hash.appendFormat("%02x", i)
	}
	
	return hash as String
}

extension String {
	func replace(regexPattern : String, replacement : String) -> String {
		let regex = try? NSRegularExpression(pattern: regexPattern, options: NSRegularExpressionOptions.CaseInsensitive )
		return regex!.stringByReplacingMatchesInString(self, options:NSMatchingOptions(), range:NSMakeRange(0, self.characters.count), withTemplate:replacement);
	}
}

func unique(source : [String]) -> [String] {
	var buffer : [String] = []
	for elem in source {
		if !buffer.contains(elem) {
			buffer.append(elem)
		}
	}
	return buffer
}
