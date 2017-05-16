//
//  DataManager.swift
//  Greedy Cats
//
//  Created by David Yuste on 2/22/15.
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

class DataManager {
	class var Singleton : DataManager {
		struct singleton {
			static let instance = DataManager()
		}
		return singleton.instance
	}
	
	init() {
		usersCache = DataCache<User>()
		virtualUsersCache = DataCache<User>()
		gamesCache = DataCache<Game>()
	}
	
// MARK: Settings
	func getSetting(key : String) -> String? {
		let traverser = DataBaseTraverser(sql: "SELECT value FROM \(TableSettings) WHERE key='\(key)'")
		let it = traverser.begin()
		if it == nil {
			return nil
		}
		if it!.isNull(0) {
			return nil
		} else {
			return it!.colAsString(0)
		}
	}
	
	func setSetting(key : String, value : String?) {
		var val : String
		if value != nil {
			val = "'\(value!)'"
		} else {
			val = "NULL"
		}
		DataBaseAdapter.Singleton.executeInsertOrReplace(TableSettings, fields: "key,value", values: "('\(key)',\(val))")
	}
	
// MARK: Bom Objects
	var usersCache : DataCache<User>
	
	func getUser(id : Identifier) -> User? {
		return usersCache.getObject(id)
	}
	
	func getUsers(ids : [NSNumber]) -> [User] {
		return usersCache.getObjectCollection(ids)
	}
	
	func getSelfUser() -> User? {
		if let userId = SessionManager.Singleton.userId {
			return getUser(userId)
		}
		return nil
	}
	
	var virtualUsersCache : DataCache<User>
	
	func getVirtualUser(id : Identifier) -> User? {
		return virtualUsersCache.getObject(id)
	}
	
	func getVirtualUsers(ids : [NSNumber]) -> [User] {
		return virtualUsersCache.getObjectCollection(ids)
	}
	
	var gamesCache : DataCache<Game>
	
	func getGame(id : Identifier) -> Game? {
		return gamesCache.getObject(id)
	}
	
	func getGames(ids : [NSNumber]) -> [Game] {
		return gamesCache.getObjectCollection(ids)
	}
	
//MARK: Headers
	
	//NOTE: Executed on network queue
	func addNetworkHeader(jsonHeader : NSDictionary) {
		addNetworkHeaderCollection(jsonHeader, headerTitle: "users", cache: usersCache)
		addNetworkHeaderCollection(jsonHeader, headerTitle: "virtual_users", cache: virtualUsersCache)
		addNetworkHeaderCollection(jsonHeader, headerTitle: "games", cache: gamesCache)
		// TODO other headers
	}
	
	private func addNetworkHeaderCollection<T : Bom> (jsonHeader : NSDictionary, headerTitle : String, cache : DataCache<T>) {
		if let header = jsonHeader[headerTitle] as! NSDictionary? {
			for (key, value) in header {
				let jsonObj = value as? NSDictionary
				let index = IdentifierFromString(key as? NSString)
				if jsonObj != nil && index != nil {
					if let obj = T.fromDictionary(jsonObj!) {
						cache.addNetworkObject(obj as! T)
					} else {
						Logger.Warn("DataManager::addNetworkHeaderCollection: failed to append object \(index) to cache \(headerTitle)")
					}
				} else {
					Logger.Warn("DataManager::addNetworkHeaderCollection: failed to append object to cache \(headerTitle)")
				}
			}
		}

	}
	
	
}
