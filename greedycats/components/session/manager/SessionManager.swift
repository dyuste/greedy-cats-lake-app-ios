//
//  SessionManager.swift
//  Greedy Cats
//
//  Created by David Yuste on 2/24/15.
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

protocol SessionDelegate : Delegate {
	func sessionSignInDidFail()
	func sessionSignInDidSuccess()
	
	func sessionSignUpDidFail()
	//NOTE: SingUp success is notified via SignIn, because it implies sing in
	
	func sessionExtendAccountDidSuccess()
	func sessionExtendAccountDidFail()
	
	func sessionLookUpUserNameDidSuccess(userName: String, available: Bool)
	func sessionLookUpUserNameDidFail()
}

class SessionManager : Manager, NetDelegate {
	override init () {
		super.init();
		let userIdString = DataManager.Singleton.getSetting("session_user_id")
		if userIdString != nil {
			let intValue = Int(userIdString!)
			if intValue != nil {
				self.userId = Identifier(intValue!)
			}
		}
	}
	
	class var Singleton : SessionManager {
		struct singleton {
			static let instance = SessionManager()
		}
		return singleton.instance
	}
	
	var sessionKey : String?
	var userId : Identifier?
	var user : User? {
		get {
			if userId == nil {
				return nil
			} else {
				return DataManager.Singleton.getUser(userId!)
			}
		}
	}
	private var savedUserName : String?
	private var savedPass : String?
	private var lastAttemptUserName : String?
	private var lastAttemptPass : String?
	
	func performSignIn(userName: String?, pass: String?) {
		if userName != nil && pass != nil {
			Logger.Info("SessionManager::performSignIn: sign in using supplied args")
			performSignInWithArgs(userName!, pass: StringToMd5(pass!))
		} else if savedUserName != nil && savedPass != nil {
			Logger.Info("SessionManager::performSignIn: sign in using in memory args")
			performSignInWithArgs(savedUserName!, pass: savedPass!)
		} else if savedUserName != nil {
			Logger.Info("SessionManager::performSignIn: sign in dialog (missing in memory pass only)")
			dispatch_async(dispatch_get_main_queue()) {
				NavigationManager.Singleton.forwardToController(SignInViewController.self)
			}
		} else {
			let dbUserName = DataManager.Singleton.getSetting("session_user_name")
			let dbPass = DataManager.Singleton.getSetting("session_pass")
			if dbUserName != nil && dbPass != nil {
				Logger.Info("SessionManager::performSignIn: sign in using stored args")
				performSignInWithArgs(dbUserName!, pass: dbPass!)
			} else if dbUserName != nil {
				Logger.Info("SessionManager::performSignIn: sign in dialog (missing stored pass only)")
				dispatch_async(dispatch_get_main_queue()) {
					NavigationManager.Singleton.forwardToController(SignInViewController.self)
				}
			} else {
				Logger.Info("SessionManager::performSignIn: dummy sign up")
				performDummySignUp()
			}
		}
	}
	
	func performSignInWithArgs(userName: String, pass: String) {
		lastAttemptUserName = userName
		lastAttemptPass = pass
		NetManager.Singleton.executeQuery("session.signin",
			args: ["user_name" : userName, "pass_md5" : pass], delegate: self)
	}
	
	func performDummySignUp() {
		NetManager.Singleton.executeQuery("session.signup.dummy",
			args: nil, delegate: self)
	}
	
	func performSignUp(userName: String, pass: String, name: String, email: String) {
		lastAttemptUserName = userName
		lastAttemptPass = StringToMd5(pass)
		NetManager.Singleton.executeQuery("session.signup",
			args: ["user_name" : userName, "pass_md5" : lastAttemptPass!, "name" : name, "email" : email], delegate: self)
	}
	
	func performExtendAccount(userName: String, pass: String, name: String, email: String) {
		lastAttemptUserName = userName
		lastAttemptPass = StringToMd5(pass)
		NetManager.Singleton.executeQuery("session.extend.account",
			args: ["user_name" : userName, "pass_md5" : lastAttemptPass!, "name" : name, "email" : email], delegate: self)
	}
	
	func startLookUpUserName(userName: String) {
		NetManager.Singleton.executeQuery("session.lookup.username",
			args: ["user_name" : userName], delegate: self)
	}
	
	func netQueryDidSuccess(queryId: UInt64, method: String, jsonPackageType: String?, jsonResult: NSDictionary?) {
		if jsonPackageType != nil {
			
			if jsonPackageType == "session.signin" || jsonPackageType == "session.signup" || jsonPackageType == "session.signup.dummy" {
				var success = false
				if jsonResult != nil {
					let nsUserId = jsonResult!["u"] as? NSNumber
					if nsUserId != nil && nsUserId!.unsignedLongLongValue > 0 {
						userId = nsUserId!.unsignedLongLongValue
					} else {
						userId = nil
					}
					sessionKey = jsonResult!["s"] as? String
				
					success = userId != nil && sessionKey != nil
					if success {
						if jsonPackageType == "session.signup.dummy" {
							let dummyUserName = jsonResult!["n"] as? NSString
							let dummyPass = jsonResult!["p"] as? NSString
							lastAttemptUserName = dummyUserName as String?
							lastAttemptPass = dummyPass as String?
							DataManager.Singleton.setSetting("session_dummy_user", value: "1")
						}
						savedUserName = lastAttemptUserName
						savedPass = lastAttemptPass
						updateUser(userId!, userName: savedUserName!, pass: savedPass!, name: nil, email: nil)
					}
				}
				
				Logger.Info("SessionManager::netQueryDidSuccess: sigin/signup did complete with status: \(success)")
				
				for delegate in delegates {
					if let sessionDelegate = delegate as? SessionDelegate {
						if success {
							sessionDelegate.sessionSignInDidSuccess()
						} else {
							sessionDelegate.sessionSignInDidFail()
						}
					}
				}
			} else if jsonPackageType == "session.extend.account" {
				savedUserName = lastAttemptUserName
				savedPass = lastAttemptPass
				
				updateUser(userId!, userName: savedUserName!, pass: savedPass!, name: nil, email: nil)
				
				for delegate in delegates {
					if let sessionDelegate = delegate as? SessionDelegate {
						sessionDelegate.sessionExtendAccountDidSuccess()
					}
				}
			} else if jsonPackageType == "session.lookup.username" {
				var success = false
				var userName : NSString?
				var available : NSNumber?
			
				if jsonResult != nil {
					userName = jsonResult!["u"] as? NSString
					available = jsonResult!["a"] as? NSNumber
					success = userName != nil && available != nil
				}

				for delegate in delegates {
					if let sessionDelegate = delegate as? SessionDelegate {
						if success {
							sessionDelegate.sessionLookUpUserNameDidSuccess(userName! as String, available: available! == 1)
						} else {
							sessionDelegate.sessionLookUpUserNameDidFail()
						}
					}
				}
			}
		}
	}
	
	func updateUser(userId : Identifier, userName : String, pass : String, name : String?, email : String?) {
		DataManager.Singleton.setSetting("session_user_id", value: "\(userId)")
		DataManager.Singleton.setSetting("session_user_name", value: userName)
		DataManager.Singleton.setSetting("session_pass", value: pass)
	}
	
	func netQueryDidFail(queryId: UInt64, method: String, diagnosis: NetErrorDiagnosis, jsonPackage: NSDictionary?) {
		if method == "session.signin" {
			for delegate in delegates {
				if let sessionDelegate = delegate as? SessionDelegate {
					sessionDelegate.sessionSignInDidFail()
				}
			}
			savedPass = nil
			lastAttemptPass = nil
			DataManager.Singleton.setSetting("session_pass", value: nil)
			performSignIn(nil, pass: nil)
			
		} else if method == "session.signup" {
			for delegate in delegates {
				if let sessionDelegate = delegate as? SessionDelegate {
					sessionDelegate.sessionSignUpDidFail()
				}
			}
		} else if method == "session.extend.account" {
			for delegate in delegates {
				if let sessionDelegate = delegate as? SessionDelegate {
					sessionDelegate.sessionExtendAccountDidFail()
				}
			}
		} else if method == "session.lookup.username" {
			for delegate in delegates {
				if let sessionDelegate = delegate as? SessionDelegate {
					sessionDelegate.sessionLookUpUserNameDidFail()
					
				}
			}
		}
	}
}
