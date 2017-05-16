//
//  ProfileAdapter.swift
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

protocol ProfileDelegate : Delegate {
	func profileSummaryDidChange (readyGameIds : NSArray, waitingGameIds : NSArray, finishedGameIds : NSArray)
}

class ProfileManager : Manager, NetDelegate {
	override init () {
		super.init();
	}
	
	class var Singleton : ProfileManager {
		struct singleton {
			static let instance = ProfileManager()
		}
		return singleton.instance
	}
	
	func startProfileGetSummary() {
		NetManager.Singleton.executeQuery("profile.get.summary",
			args: nil, delegate: self)
	}
	
	func startProfileOfflineGetSummary() {
		if let userId = SessionManager.Singleton.userId {
			var ready : [NSNumber] = []
			var waiting : [NSNumber] = []
			var finished : [NSNumber] = []
		
			let readyTraverser = DataBaseTraverser(sql: "SELECT DISTINCT(g.id) FROM \(TableGame) g " +
				"INNER JOIN \(TableGamePlayers) pp ON pp.game_id=g.id AND pp.player_id=g.turn_player_id " +
				"WHERE g.finished=0 AND (pp.user_id='\(userId)' OR (pp.user_id IS NULL AND g.owner_user_id='\(userId)')) AND (random_game=0 OR (SELECT COUNT(1) FROM \(TableGamePlayers) pp2 WHERE pp2.game_id=g.id)>3)")
			for it in readyTraverser {
				ready.append(NSNumber(unsignedLongLong:it.colAsUInt64(0)))
			}
		
			let waitingTraverser = DataBaseTraverser(sql: "SELECT DISTINCT(g.id) FROM \(TableGame) g " +
				"INNER JOIN \(TableGamePlayers) pp ON pp.game_id=g.id AND pp.player_id=g.turn_player_id " +
				"WHERE g.finished=0 AND (((pp.user_id!='\(userId)' AND (pp.user_id IS NOT NULL OR g.owner_user_id!='\(userId)')) AND EXISTS(SELECT 1 FROM \(TableGamePlayers) pp2 WHERE pp2.game_id=g.id " +
				"AND pp2.user_id='\(userId)')) OR (random_game=0 OR (SELECT COUNT(1) FROM \(TableGamePlayers) pp2 WHERE pp2.game_id=g.id)<4))")
			for it in waitingTraverser {
				waiting.append(NSNumber(unsignedLongLong:it.colAsUInt64(0)))
			}
		
			let finishedTraverser = DataBaseTraverser(sql: "SELECT DISTINCT(g.id) FROM \(TableGame) g " +
				"INNER JOIN \(TableGamePlayers) pp ON pp.game_id=g.id " +
				"WHERE g.finished=1 AND pp.user_id='\(userId)' ")
			for it in finishedTraverser {
				finished.append(NSNumber(unsignedLongLong:it.colAsUInt64(0)))
			}
		
			for delegate in delegates {
				if let profileDelegate = delegate as? ProfileDelegate {
					profileDelegate.profileSummaryDidChange(ready, waitingGameIds:waiting, finishedGameIds:finished)
				}
			}
		}
	}
	
	
	// Periodic full profile update
	var updateTimer : NSTimer?
	
	override func managerWillStart() {
		if updateTimer == nil {
			updateTimer = NSTimer.scheduledTimerWithTimeInterval(125, target: self, selector: Selector("startProfileGetSummary"), userInfo: nil, repeats: true)
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
			updateTimer = NSTimer.scheduledTimerWithTimeInterval(125, target: self, selector: Selector("startProfileGetSummary"), userInfo: nil, repeats: true)
		}
	}

	
	func netQueryDidSuccess(queryId: UInt64, method: String, jsonPackageType: String?, jsonResult: NSDictionary?) {
		if jsonPackageType != nil && (jsonPackageType == "profile.get.summary") {
			let ready = jsonResult!["r"] as? NSArray
			let waiting = jsonResult!["w"] as? NSArray
			let finished = jsonResult!["f"] as? NSArray
			
			if ready != nil && waiting != nil && finished != nil {
				// purge dead games
				var set : Set<Identifier> = Set()
				for id in ready! {
					set.insert(id.unsignedLongLongValue)
				}
				for id in waiting! {
					set.insert(id.unsignedLongLongValue)
				}
				for id in finished! {
					set.insert(id.unsignedLongLongValue)
				}
				if set.count > 0 {
					let idsString = JoinCollection(set, separator: ",")
					DataBaseAdapter.Singleton.executeChange("DELETE FROM \(TableGame) WHERE id NOT IN (\(idsString))")
					DataBaseAdapter.Singleton.executeChange("DELETE FROM \(TableGamePlayers) WHERE game_id NOT IN (\(idsString))")
					DataBaseAdapter.Singleton.executeChange("DELETE FROM \(TableGameCells) WHERE game_id NOT IN (\(idsString))")
				} else {
					DataBaseAdapter.Singleton.executeChange("DELETE FROM \(TableGame) WHERE 1")
					DataBaseAdapter.Singleton.executeChange("DELETE FROM \(TableGamePlayers) WHERE 1")
					DataBaseAdapter.Singleton.executeChange("DELETE FROM \(TableGameCells) WHERE 1")
				}
				
				// notify
				for delegate in delegates {
					if let profileDelegate = delegate as? ProfileDelegate {
						profileDelegate.profileSummaryDidChange(ready!, waitingGameIds:waiting!, finishedGameIds:finished!)
					}
				}
			}
		}
	}
	
	func netQueryDidFail(queryId: UInt64, method: String, diagnosis: NetErrorDiagnosis, jsonPackage: NSDictionary?) {
		Logger.Warn("ProfileManager::netQueryDidFail: Network or server is down, fallback to local data base")
		startProfileOfflineGetSummary()
	}
}
