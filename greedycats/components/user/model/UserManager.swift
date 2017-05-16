//
//  UserManager.swift
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

protocol UserDelegate : Delegate {
	func userSearchDidComplete(pattern: String, results: [User])
}

class UserManager : Manager, NetDelegate {
	
	class var Singleton : UserManager {
		struct singleton {
			static let instance = UserManager()
		}
		return singleton.instance
	}
	
	override init () {
		super.init();
	}
	var lastSearchQueryId : UInt64?
	
	func startSearchUser(pattern: String) {
		if lastSearchQueryId != nil {
			NetManager.Singleton.cancelQuery(lastSearchQueryId!)
		}
		lastSearchQueryId = NetManager.Singleton.executeQuery("user.search",
			args: ["pattern" : pattern], delegate: self)
	}
	
	func netQueryDidSuccess(queryId: UInt64, method: String, jsonPackageType: String?, jsonResult: NSDictionary?) {
		if jsonPackageType != nil && (jsonPackageType == "user.search") {
			let pattern = jsonResult!["p"] as? String
			let userIds = jsonResult!["u"] as? NSArray as? [NSNumber]
			
			if pattern != nil && userIds != nil {
				let users = DataManager.Singleton.getUsers(userIds!)
				for delegate in delegates {
					if let userDelegate = delegate as? UserDelegate {
						userDelegate.userSearchDidComplete(pattern!, results:users)
					}
				}
			}
		}
	}
	
	func netQueryDidFail(queryId: UInt64, method: String, diagnosis: NetErrorDiagnosis, jsonPackage: NSDictionary?) {
		
	}
}
