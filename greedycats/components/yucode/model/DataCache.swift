//
//  DataCache.swift
//  Greedy Cats
//
//  Created by David Yuste on 3/1/15.
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

class DataCache<T : Bom> {
	private var collection : [Identifier : T]
	
	init () {
		collection = Dictionary<Identifier, T>()
	}
	
	func getObject(id : Identifier) -> T? {
		var cachedObj : T?
		
		objc_sync_enter(self)
		cachedObj = self.collection[id]
		objc_sync_exit(self)
		
		if cachedObj != nil {
			return cachedObj
		}
		
		let dbObj = getDataBaseObject(NSNumber(unsignedLongLong: id));
		
		if dbObj != nil {
			objc_sync_enter(self)
			self.collection[id] = dbObj
			objc_sync_exit(self)
		}
		
		return dbObj
	}
	
	func getObjectCollection(ids : [NSNumber]) -> [T] {
		var objs : [T] = []
		var missingIds : [NSNumber] = []
		objc_sync_enter(self)
		for id in ids {
			if self.collection[id.unsignedLongLongValue] != nil {
				objs.append(self.collection[id.unsignedLongLongValue]!)
			} else {
				missingIds.append(id)
			}
		}
		objc_sync_exit(self)
		
		if missingIds.count > 0 {
			let dbObjs = getDataBaseObjectCollection(missingIds)
			objc_sync_enter(self)
			for dbObj in dbObjs {
				self.collection[dbObj.getKey()] = dbObj
				objs.append(dbObj)
			}
			objc_sync_exit(self)
		}
		
		return objs
	}
	
	func addNetworkObject(obj : T) {
		var cachedObj : T?
		
		objc_sync_enter(self)
		cachedObj = self.collection[obj.getKey()]
		objc_sync_exit(self)
		
		if cachedObj == nil || cachedObj!.getTimeStamp() < obj.getTimeStamp() {
			
			objc_sync_enter(self)
			self.collection[obj.getKey()] = obj
			objc_sync_exit(self)
			
			obj.dataBaseStore()
		}
	}
	
 	private func getDataBaseObject(id : NSNumber) -> T? {
		if T.hasCustomDataBaseLoader() {
			return T.fromDataBase(id) as! T?
		} else {
			let select = T.getSQLSelect()
			let key = T.getSQLKey()
			let traverser = DataBaseTraverser(sql: "\(select) WHERE \(key)='\(id)'")
			let it = traverser.begin()
			if it == nil {
				return nil
			}
			return T(dbIterator: it!)
		}
	}
	
	private func getDataBaseObjectCollection(ids : [NSNumber]) -> [T] {
		if T.hasCustomDataBaseLoader() {
			return T.collectionFromDataBase(ids) as! [T]
		} else {
			let select = T.getSQLSelect()
			let key = T.getSQLKey()
			let idsStr = JoinCollection(ids, separator: ",")
			let traverser = DataBaseTraverser(sql: "\(select) WHERE \(key) IN (\(idsStr))")
			var collection : [T] = []
			for it in traverser {
				collection.append(T(dbIterator: it))
			}
			return collection
		}
	}
}
