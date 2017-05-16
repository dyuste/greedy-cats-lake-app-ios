//
//  GameAdapter.swift
//  Greedy Cats
//
//  Created by David Yuste on 2/21/15.
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

protocol GameDelegate : Delegate {
	func gameCreateDidComplete(gameId : Identifier)
	
	func gameJoinRandomDidComplete(gameId : Identifier)
	
	func gameCreateDidFail()
	
	func gameUpdated(gameId : Identifier)
}

class GameManager : Manager, NetDelegate {
	override init () {
		super.init();
	}
	
	class var Singleton : GameManager {
		struct singleton {
		static let instance = GameManager()
		}
		return singleton.instance
	}
	
	var updateTimer : NSTimer?
	
	override func managerWillStart() {
		if updateTimer == nil {
			updateTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("fetchUpdates"), userInfo: nil, repeats: true)
		}
	}
	
	override func managerWillResignForeground() {
		if updateTimer != nil {
			updateTimer!.invalidate()
			updateTimer = nil
		}
	}
	
	override func managerWillEnterForeground() {
		if updateTimer == nil {
			updateTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("fetchUpdates"), userInfo: nil, repeats: true)
		}
	}
	
	func fetchUpdates() {
		startGameGetUpdated()
	}
	
	func startCreateGame(userList: [User], localUserList : [User]) {
		var userIds : [NSNumber] = []
		for user in userList {
			userIds.append(NSNumber(unsignedLongLong: user.id))
		}
		var localUserNames : [String] = []
		for localUser in localUserList {
			localUserNames.append(localUser.userName)
		}
		
		NetManager.Singleton.executeQuery("game.create",
			args: ["user_ids" : userIds, "local_user_names" : localUserNames],
			delegate: self)
	}
	
	func startJoinRandom() {
		NetManager.Singleton.executeQuery("game.join.random",
			args: NSDictionary(),
			delegate: self)
	}
	
	func startGameGet(id: Identifier) {
		NetManager.Singleton.executeQuery("game.get",
			args: ["game_id" : NSNumber(unsignedLongLong: id)],
			delegate: self)
	}
	
	func startGameGetUpdated() {
		var gameIds : [NSNumber] = []
		var timeStamps : [NSNumber] = []
		let gameTraverser = DataBaseTraverser(sql: "SELECT id, time_stamp FROM \(TableGame)")
		for gameIt in gameTraverser {
			gameIds.append(NSNumber(unsignedLongLong: gameIt.colAsUInt64(0)))
			timeStamps.append(NSNumber(unsignedLongLong: gameIt.colAsUInt64(1)))
		}
		
		if gameIds.count > 0 {
			NetManager.Singleton.executeQuery("game.get.updated",
				args: ["game_ids" : gameIds, "time_stamps" : timeStamps],
				delegate: self)
		}
	}
	
	func startGameMove(id: Identifier, position: UInt32) {
		NetManager.Singleton.executeQuery("game.move",
			args: ["game_id" : NSNumber(unsignedLongLong:id), "position" : NSNumber(unsignedInt:position)],
			delegate: self)
	}
	
	func netQueryDidSuccess(queryId: UInt64, method: String, jsonPackageType: String?, jsonResult: NSDictionary?) {
		if jsonPackageType != nil {
			if jsonPackageType == "game.create" {
				let gameId = jsonResult!["g"] as? NSNumber
				
				if gameId != nil {
					for delegate in delegates {
						if let gameDelegate = delegate as? GameDelegate {
							gameDelegate.gameCreateDidComplete(Identifier(gameId!.unsignedLongLongValue))
						}
					}
				}
			} else if jsonPackageType == "game.join.random" {
				let gameId = jsonResult!["g"] as? NSNumber
				
				if gameId != nil {
					for delegate in delegates {
						if let gameDelegate = delegate as? GameDelegate {
							gameDelegate.gameJoinRandomDidComplete(Identifier(gameId!.unsignedLongLongValue))
						}
					}
				}
			} else if jsonPackageType == "game.get" || jsonPackageType == "game.move" {
				let gameId = jsonResult!["g"] as? NSNumber
				
				if gameId != nil {
					for delegate in delegates {
						if let gameDelegate = delegate as? GameDelegate {
							gameDelegate.gameUpdated(Identifier(gameId!.unsignedLongLongValue))
						}
					}
				}
			} else if jsonPackageType == "game.get.updated" {
				if let gameIds = jsonResult!["g"] as? NSArray {
					for gameId in gameIds {
						if let id = gameId as? NSNumber {
							startGameGet(Identifier(id.unsignedLongLongValue))
						}
					}
				}
			}
		}
	}
	
	
	func netQueryDidFail(queryId: UInt64, method: String, diagnosis: NetErrorDiagnosis, jsonPackage: NSDictionary?) {
		for delegate in delegates {
			if let gameDelegate = delegate as? GameDelegate {
				gameDelegate.gameCreateDidFail()
			}
		}
	}
	
}
