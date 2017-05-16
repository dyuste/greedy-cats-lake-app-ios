//
//  UserTheme.swift
//  Hunter Cats
//
//  Created by David Yuste on 2/17/15.
//  Copyright (c) 2015 yugame. All rights reserved.
//

import Foundation
import UIKit

class UserTheme : Equatable, Bom {
	init() {
		self.id = 0
	}
	
	let skinColors : [UIColor] = [
		UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0),
		UIColor(red:1.00, green:0.87, blue:0.71, alpha:1.0),
		UIColor(red:1.00, green:0.73, blue:0.42, alpha:1.0),
		UIColor(red:1.00, green:0.61, blue:0.14, alpha:1.0),
		UIColor(red:0.55, green:0.46, blue:0.36, alpha:1.0),
		UIColor(red:0.44, green:0.29, blue:0.12, alpha:1.0),
		UIColor(red:0.43, green:0.24, blue:0.02, alpha:1.0),
		UIColor(red:1.00, green:0.94, blue:0.47, alpha:1.0),
		UIColor(red:0.96, green:0.87, blue:0.13, alpha:1.0),
		UIColor(red:0.75, green:0.67, blue:0.04, alpha:1.0),
		UIColor(red:0.93, green:0.95, blue:0.20, alpha:1.0),
		UIColor(red:0.89, green:0.93, blue:0.04, alpha:1.0),
		UIColor(red:0.99, green:0.82, blue:0.66, alpha:1.0),
		UIColor(red:0.98, green:0.69, blue:0.42, alpha:1.0),
		UIColor(red:0.99, green:0.56, blue:0.19, alpha:1.0),
		UIColor(red:0.98, green:0.47, blue:0.01, alpha:1.0),
		UIColor(red:0.80, green:0.47, blue:0.17, alpha:1.0),
		UIColor(red:0.69, green:0.35, blue:0.04, alpha:1.0),
		UIColor(red:0.57, green:0.29, blue:0.03, alpha:1.0),
		// green
		UIColor(red:0.56, green:0.98, blue:0.78, alpha:1.0),
		UIColor(red:0.31, green:0.96, blue:0.65, alpha:1.0),
		UIColor(red:0.03, green:0.85, blue:0.46, alpha:1.0),
		UIColor(red:0.03, green:0.60, blue:0.33, alpha:1.0),
		// blue
		UIColor(red:0.41, green:0.80, blue:0.97, alpha:1.0),
		UIColor(red:0.24, green:0.73, blue:0.95, alpha:1.0),
		UIColor(red:0.03, green:0.52, blue:0.73, alpha:1.0),
		UIColor(red:0.02, green:0.40, blue:0.56, alpha:1.0),
		// pink
		UIColor(red:0.99, green:0.64, blue:0.76, alpha:1.0),
		UIColor(red:0.96, green:0.41, blue:0.61, alpha:1.0),
		UIColor(red:0.66, green:0.06, blue:0.28, alpha:1.0),
		// blank
		UIColor(red:0.07, green:0.07, blue:0.08, alpha:1.0),
		UIColor(red:0.26, green:0.26, blue:0.27, alpha:1.0),
		UIColor(red:0.53, green:0.53, blue:0.53, alpha:1.0)
	]
	var color : UIColor {
		get {
			return skinColors[(id < 32 ? Int(id) : 0)]
			
		}
	}
	
	init (id : UInt64) {
		self.id = id
	}
	
	init(id : NSNumber) {
			self.id = id.unsignedLongLongValue
	}
	
	
	required init(dbIterator: DataBaseTraverserIterator) {
		self.id = dbIterator.colAsUInt64(0) as Identifier
	}
	
	// Bom: Net Json construction
	class func fromDictionary(dic: NSDictionary) -> Bom? {
		let id = dic["i"] as? NSNumber
		return UserTheme(id: id!)
	}
	
	// Construction from db (custom cache from db)
	class func hasCustomDataBaseLoader() -> Bool {
		return false
	}
	class func fromDataBase(id : NSNumber) -> Bom? {
		return nil
	}
	class func collectionFromDataBase(ids : [NSNumber]) -> [Bom] {
		return []
	}
	
	// Bom: Common required attributes
	func getKey() -> Identifier {
		return id;
	}
	
	func getTimeStamp() -> UInt64 {
		return 0;
	}
	
	// Bom: Data base interfacing
	class func getSQLSelect() -> String {
		return ""
	}
	class func getSQLKey() -> String {
		return "id"
	}
	func dataBaseStore() {
	}
	
	func getTitle() -> String {
		return "\(id)"
	}
	
	var id : Identifier
}

func ==(lhs: UserTheme, rhs: UserTheme) -> Bool {
	return lhs.id == rhs.id
}
