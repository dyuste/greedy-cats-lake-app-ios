//
//  Player.swift
//  Greedy Cats
//
//  Created by David Yuste on 5/9/15.
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


class Player {
	init() {
		self.playerId = 0
		self.userId = nil
		self.virtualUserId = nil
		self.canMove = true
		self.score = 0
	}
	
	init(playerId : NSNumber, userId : NSNumber?, virtualUserId : NSNumber?, canMove : NSNumber, score : NSNumber) {
		self.playerId = playerId.unsignedLongLongValue
		self.userId = userId?.unsignedLongLongValue
		self.virtualUserId = virtualUserId?.unsignedLongLongValue
		if canMove.unsignedIntValue != 0 {
			self.canMove = true
		} else {
			self.canMove = false
		}
		self.score = score.unsignedIntValue
	}
	
	init(dbIterator : DataBaseTraverserIterator) {
		self.playerId = dbIterator.colAsUInt64(0)
		if dbIterator.isNull(1) {
			self.userId = nil
		} else {
			self.userId = dbIterator.colAsUInt64(1)
		}
		if dbIterator.isNull(2) {
			self.virtualUserId = nil
		} else {
			self.virtualUserId = dbIterator.colAsUInt64(2)
		}
		if dbIterator.colAsInt32(3) != 0 {
			self.canMove = true
		} else {
			self.canMove = false
		}
		self.score = dbIterator.colAsUInt32(4)
	}
	
	var title : String {
		get {
			var t : String = ""
			if userId != nil {
				if let user = DataManager.Singleton.getUser(userId!) {
					t = user.getTitle()
				}
			}
			if virtualUserId != nil {
				if let user = DataManager.Singleton.getVirtualUser(virtualUserId!) {
					t = user.getTitle()
				}
			}
			return t
		}
	}
	
	var theme : UserTheme {
		get {
			var theme : UserTheme = UserTheme(id: UInt64(0))
			if userId != nil {
				if let user = DataManager.Singleton.getUser(userId!) {
					theme = UserTheme(id: user.theme)
				}
			} else if virtualUserId != nil {
				if let virtualUser = DataManager.Singleton.getVirtualUser(virtualUserId!) {
					theme = UserTheme(id: virtualUser.theme)
				}
			}
			return theme
		}
	}
	
	class func fromDictionary(dic: NSDictionary) -> Player? {
		let playerId = dic["p"] as? NSNumber
		let userId = dic["u"] as? NSNumber
		let virtualUserId = dic["v"] as? NSNumber
		let canMove = dic["c"] as? NSNumber
		let score = dic["s"] as? NSNumber
		
		if playerId == nil || canMove == nil || score == nil {
			return nil
		}
		
		return Player(playerId: playerId!, userId: userId, virtualUserId: virtualUserId, canMove: canMove!, score: score!)
	}
	
	class func collectionFromDictionary(array: NSArray) -> [Player] {
		var col : [Player] = []
		
		for obj in array {
			if let objDic = obj as? NSDictionary {
				if let player = Player.fromDictionary(objDic) {
					col.append(player)
				}
			}
		}
		return col
	}
	
	var playerId : Identifier
	var userId : Identifier?
	var virtualUserId : Identifier?
	var canMove : Bool
	var score : UInt32
}


