//
//  Bom.swift
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
import UIKit

typealias Identifier = UInt64

protocol Bom {
	// Construction from dictionary (net Json)
	static func fromDictionary(dic: NSDictionary) -> Bom?
	
	// Construction from db iterator (cache from db)
	init(dbIterator: DataBaseTraverserIterator)
	
	// Construction from db (custom cache from db)
	static func hasCustomDataBaseLoader() -> Bool
	static func fromDataBase(id : NSNumber) -> Bom?
	static func collectionFromDataBase(ids : [NSNumber]) -> [Bom]
	
	// Common required attributes
	func getKey() -> Identifier
	func getTimeStamp() -> UInt64
	
	// Data base interfacing
	static func getSQLSelect() -> String
	static func getSQLKey() -> String
	func dataBaseStore()
}

func ==(lhs: Bom, rhs: Bom) -> Bool {
	return lhs.getKey() == rhs.getKey()
}

// FIXME: It does not actually work on 64 bits
func IdentifierFromString(str: NSString?) -> Identifier? {
	if let nsStr = str as NSString? {
		let value = nsStr.intValue
		if value > 0 {
			if UInt64(value) >= UInt64.min && UInt64(value) <= UInt64.max {
				return UInt64(value)
			}
			return Optional<UInt64>.None
		} else {
			return .None
		}
	} else {
		return .None
	}
	
}
