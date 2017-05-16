//
//  Product.swift
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
import StoreKit

class Product : NSObject, NSCoding {
	
	enum Status : Int {
		case Undefined = 0
		case Available = 1
		case InProgress = 2
		case Purchasing = 3
		case Purchased = 4
		case Failed = 5
		case Restored = 6
		case Deferred = 7
	}
	
	enum Type : Int {
		case Undefined = 0
		case NonConsumable = 1
		case Consumable = 2
	}

	var id : String
	var status : Status
	var type : Type
	var skProduct : SKProduct?
	
	init(id : String) {
		self.id = id
		self.status = .Undefined
		self.type = .Undefined
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.id = ""
		if let id = aDecoder.decodeObjectForKey("id") as? String {
			self.id = id
		}
		self.status = .Undefined
		let statusValue = aDecoder.decodeIntegerForKey("status")
		if let status = Status(rawValue: statusValue) {
			self.status = status
		}
		
		self.type = .Undefined
		let typeValue = aDecoder.decodeIntegerForKey("type")
		if let type = Type(rawValue: typeValue) {
			self.type = type
		}
	}
	
	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(id, forKey: "id")
		aCoder.encodeInteger(status.rawValue, forKey: "status")
		aCoder.encodeInteger(type.rawValue, forKey: "type")
	}
	
	var purchased : Bool {
		get {
			return status == .Purchased
				|| status == .Restored
		}
	}
}

