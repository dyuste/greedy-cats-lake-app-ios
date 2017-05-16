//
//  User.swift
//  Hunter Cats
//
//  Created by David Yuste on 2/17/15.
//  Copyright (c) 2015 yugame. All rights reserved.
//

import Foundation

class User : Equatable, Bom {
	init() {
		self.id = 0
		self.userName = ""
		self.email = nil
		self.name = ""
		self.theme = 0
		self.lifes = 0
		self.score = 0
		self.timestamp = 0
	}
	
	init(id : NSNumber,
		userName : NSString,
		email : NSString?,
		name : NSString?,
		theme : NSNumber,
		lifes : NSNumber,
		score : NSNumber,
		timestamp : NSNumber,
		pictureUrl : NSString?,
		about : NSString?) {
			self.id = id.unsignedLongLongValue
			self.userName = userName as String
			self.email = email as String?
			self.name = name as String?
			self.theme = theme.unsignedLongLongValue
			self.lifes = lifes.unsignedIntValue
			self.score = score.unsignedIntValue
			self.timestamp = timestamp.unsignedLongLongValue
			self.pictureUrl = pictureUrl as String?
			self.about = about as String?
	}
	
	
	required init(dbIterator: DataBaseTraverserIterator) {
		self.id = dbIterator.colAsUInt64(0) as Identifier
		self.userName = dbIterator.colAsString(1)
		if !dbIterator.isNull(2) {
			self.email = dbIterator.colAsString(2)
		}
		if !dbIterator.isNull(3) {
			self.name = dbIterator.colAsString(3)
		}
		if !dbIterator.isNull(4) {
			self.pictureUrl = dbIterator.colAsString(4)
		}
		self.theme = dbIterator.colAsUInt64(5)
		self.lifes = dbIterator.colAsUInt32(6)
		self.score = dbIterator.colAsUInt32(7)
		if !dbIterator.isNull(8) {
			self.about = dbIterator.colAsString(8)
		}
		self.timestamp = dbIterator.colAsUInt64(9)
	}
	
// Bom: Net Json construction
	class func fromDictionary(dic: NSDictionary) -> Bom? {
		let id = dic["i"] as? NSNumber
		let userName = dic["u"] as? NSString
		let email = dic["e"] as? NSString
		let name = dic["n"] as? NSString
		let theme = dic["t"] as? NSNumber
		let lifes = dic["l"] as? NSNumber
		let score = dic["s"] as? NSNumber
		let timestamp = dic["ts"] as? NSNumber
		let pictureUrl = dic["p"] as? NSString
		let about = dic["a"] as? NSString
		if id == nil || userName == nil || lifes == nil || score == nil || timestamp == nil {
			return nil
		}
		return User(id: id!, userName: userName!, email: email, name: name, theme: theme!, lifes: lifes!, score: score!, timestamp: timestamp!, pictureUrl: pictureUrl, about: about)
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
		return timestamp;
	}
	
// Bom: Data base interfacing
	class func getSQLSelect() -> String {
		return "SELECT id, user_name, email, name, picture_url, theme, lifes, score, about, time_stamp FROM \(TableUser)"
	}
	class func getSQLKey() -> String {
		return "id"
	}
	func dataBaseStore() {
		var strPictureUrl = "NULL"
		if pictureUrl != nil {
			strPictureUrl = "'\(pictureUrl!)'"
		}
		var strEmail = "NULL"
		if email != nil {
			strEmail = "'\(email!)'"
		}
		var strName = "NULL"
		if name != nil {
			strName = "'\(name!)'"
		}
		var strAbout = "NULL"
		if about != nil {
			strAbout = "'\(about!)'"
		}
		DataBaseAdapter.Singleton.executeInsertOrReplace(TableUser,
			fields: "id, user_name, email, name, picture_url, theme, lifes, score, about, time_stamp",
			values: "(\(id), '\(userName)',\(strEmail), \(strName), \(strPictureUrl), \(theme), \(lifes), \(score), \(strAbout), \(timestamp))")
	}
	
	func getTitle() -> String {
		if name != nil && !name!.isEmpty {
			return name!
		} else {
			return userName
		}
	}
	
	var isLocal : Bool {
		get {
			return id == 0
		}
	}
	
	var id : Identifier
	var userName : String
	var email : String?
	var name : String?
	var theme : UInt64
	var lifes : UInt32
	var score : UInt32
	var timestamp : UInt64
	var pictureUrl : String?
	var about : String?
}

func ==(lhs: User, rhs: User) -> Bool {
	return lhs.id == rhs.id
}
