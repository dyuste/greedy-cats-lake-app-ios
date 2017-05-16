//
//  NetManager.swift
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

enum NetErrorDiagnosis {
	case NetworkError
	case ServerError
	case ServiceNotFound
	case QueryError
	case SessionError
	case UnexpectedError
}

protocol NetDelegate {
	func netQueryDidSuccess(queryId: UInt64, method: String, jsonPackageType: String?, jsonResult: NSDictionary?) -> Void
	func netQueryDidFail(queryId: UInt64, method: String, diagnosis: NetErrorDiagnosis, jsonPackage: NSDictionary?) -> Void
}

class NetManager : SessionDelegate {
	class var Singleton : NetManager {
		struct singleton {
			static let instance = NetManager()
		}
		return singleton.instance
	}
	
	init() {
		queryQueue = Dictionary<UInt64, QueryData>()
		deferredQueryQueue = Dictionary<UInt64, QueryData>()
		lastQueryId = 0
		
		SessionManager.Singleton.addDelegate(self)
	}
	
	private var lastQueryId : UInt64
	private var queryQueue : [UInt64 : QueryData]
	private var deferredQueryQueue : [UInt64 : QueryData]
	
	func executeQuery(method: String, args: NSDictionary?, delegate: NetDelegate?) -> UInt64 {
		let queryId = lastQueryId++
		let queryData = QueryData(queryId: queryId, method: method, args: args, delegate: delegate)

		dispatchQuery(queryData);
		
		return queryId
	}
	
	//FIXME: It doesn't work in case of query reschedule...
	func cancelQuery(queryId: UInt64) {
		if let queryData = self.queryQueue[queryId] {
			queryData.cancelled = true
		}
	}
	
	private func dispatchQuery(queryData : QueryData) {
		queryQueue[queryData.queryId] = queryData
		
		let session = NSURLSession.sharedSession()
		session.configuration.timeoutIntervalForRequest = 25.0
		
		// Use NSURLSession to get data from an NSURL
		let loadDataTask = session.dataTaskWithURL(
			queryData.request,
			completionHandler: { (data: NSData?, response: NSURLResponse?, netError: NSError?) -> Void in
				if !queryData.cancelled {
					Logger.Log("NetManager::dispatchQuery -on data-: received package")
					var httpResponse : NSHTTPURLResponse?
					var netFailed = true
					if response != nil {
						httpResponse = response as? NSHTTPURLResponse
						if httpResponse != nil {
							if httpResponse!.statusCode == 200 {
								netFailed = false
							}
						}
					}
					if netError != nil || data == nil || netFailed  {
						self.handleNetworkError(queryData, response: httpResponse, networkError: netError, jsonPackage: nil)
					} else {
						do {
							let jsonPackage = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
							if (jsonPackage == nil) {
								self.handleNetworkError(queryData, response: httpResponse, networkError: netError, jsonPackage: nil)
							} else {
								let jStatus = jsonPackage!["status"] as! Bool?
								if jStatus != nil && jStatus! {
									self.handleNetworkSuccess(queryData, jsonPackage: jsonPackage!)
								} else {
									self.handleNetworkError(queryData, response: httpResponse, networkError: netError, jsonPackage: jsonPackage)
								}
							}
						} catch let jsonError as NSError {
							Logger.Warn("NetManager::dispatchQuery -on data-: JSON decode failed: \(jsonError.localizedDescription)")
							self.handleNetworkError(queryData, response: httpResponse, networkError: jsonError, jsonPackage: nil)
						}
					}
				}
				self.queryQueue[queryData.queryId] = nil
			})
		
		loadDataTask.resume()
	}
	
	private func handleNetworkError(queryData : QueryData, response: NSHTTPURLResponse?, networkError : NSError?, jsonPackage : NSDictionary?) {
		Logger.Warn("NetManager::handleNetworkError: [\(queryData.method) : \(queryData.queryId)]")
		var notifyClient : Bool = true
		
		var diagnosis : NetErrorDiagnosis
		if networkError != nil || response == nil {
			diagnosis = .NetworkError
		} else if jsonPackage == nil {
			if response!.statusCode == 404 {
				diagnosis = .ServiceNotFound
			} else if response!.statusCode == 505 {
				diagnosis = .ServerError
			} else {
				diagnosis = .UnexpectedError
			}
		} else {
			let jsonPackageType = jsonPackage!["package_type"] as? NSString
			if jsonPackageType != nil && jsonPackageType == "session.failed.key" {
				Logger.Warn("NetManager::handleNetworkError: [\(queryData.method) : \(queryData.queryId)] error is session.failed.key")
				deferredQueryQueue[queryData.queryId] = queryData
				notifyClient = false
				SessionManager.Singleton.performSignIn(nil, pass: nil)
			}
			
			diagnosis = .QueryError
		}
		
		if notifyClient {
			dispatch_async(dispatch_get_main_queue()) {
				queryData.delegate?.netQueryDidFail(queryData.queryId, method: queryData.method, diagnosis: diagnosis,		jsonPackage: jsonPackage)
			}
		}
	}
	
	private func handleNetworkSuccess(queryData : QueryData, jsonPackage : NSDictionary) {
		let jsonHeader = jsonPackage["header"] as? NSDictionary
		let jsonPackageType = jsonPackage["package_type"] as? String
		let jsonResult = jsonPackage["result"] as? NSDictionary
		 
		Logger.Log("NetManager::handleNetworkSuccess: [\(queryData.method) : \(queryData.queryId)] handleNetworkSuccess: \(jsonPackageType!)")
		
		if jsonHeader != nil {
			DataManager.Singleton.addNetworkHeader(jsonHeader!)
		}
		
		dispatch_async(dispatch_get_main_queue()) {
			queryData.delegate?.netQueryDidSuccess(queryData.queryId, method: queryData.method, jsonPackageType: jsonPackageType, jsonResult: jsonResult)
		}
	}
	
	//MARK:-
	//MARK: SessionAdapter
	func sessionSignInDidSuccess() -> Void {
		for (_, queryData) in deferredQueryQueue {
			Logger.Info("NetManager::sessionSignInDidSuccess: redispatch \(queryData.method)")
			dispatchQuery(queryData)
		}
		deferredQueryQueue = Dictionary<UInt64, QueryData>()
	}
	func sessionSignInDidFail() {}
	func sessionSignUpDidFail() {}
	func sessionLookUpUserNameDidSuccess(userName: String, available: Bool) {}
	func sessionLookUpUserNameDidFail() {}
	func sessionExtendAccountDidSuccess() {}
	func sessionExtendAccountDidFail() {}
}

class QueryData {
	init (queryId : UInt64, method: String, args: NSDictionary?, delegate: NetDelegate?) {
		self.queryId = queryId
		self.method = method
		self.args = args
		self.delegate = delegate
		self.cancelled = false
	}
	var queryId : UInt64
	var method : String
	var args : NSDictionary?
	var delegate : NetDelegate?
	var cancelled : Bool
	
	var request : NSURL {
		get {
			var queryArgs : String? = ""
			if args != nil {
				queryArgs = encodeUrlArgsFromNsDictionary(args!)
			}
			assert(queryArgs != nil)
			var requestArgs : String = "method=\(method)&query_id=\(queryId)"
			var sessionArgs : String = ""
			if SessionManager.Singleton.sessionKey != nil {
				sessionArgs = "&session_key=\(SessionManager.Singleton.sessionKey!)"
			}
			if !queryArgs!.isEmpty {
				requestArgs = "\(requestArgs)\(sessionArgs)&\(queryArgs!)"
			} else {
				requestArgs = "\(requestArgs)\(sessionArgs)"
			}
			let baseUrl = "http://yucodesoftware.com/games/greedycats/api?"
			Logger.Log("QueryData::request:  Query \(baseUrl)\(requestArgs)")
			return NSURL(string: baseUrl + requestArgs)!
		}
	}
}

func encodeUrlArgsFromNsDictionary(dictionary : NSDictionary) -> String? {
	var url : String = ""
	var separator : String = ""
	for (key, value) in dictionary {
		if let strKey = key as? String {
			var lhs = "", rhs = ""
			lhs = strKey.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
			if value.isKindOfClass(NSString) {
				let strValue = value as? String
				rhs = strValue!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
			} else if value.isKindOfClass(NSNumber) {
				let numValue = value as! NSNumber
				rhs = "\(numValue)"
			} else if value.isKindOfClass(NSArray) {
				let arrayValue = value as! NSArray
				var separator2 : String = ""
				for arrayItem in arrayValue {
					if arrayItem.isKindOfClass(NSString) {
						let strArrayItem = arrayItem as! NSString
						rhs += separator2 + strArrayItem.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
						separator2 = ","
					} else if arrayItem.isKindOfClass(NSNumber) {
						let numArrayItem = arrayItem as! NSNumber
						rhs += separator2 + "\(numArrayItem)"
						separator2 = ","
					} else {
						return nil
					}
				}
			} else {
				return nil
			}
			if lhs.characters.count > 0 && rhs.characters.count > 0 {
				url += separator + lhs + "=" + rhs
				separator = "&"
			}
		} else {
			return nil
		}
	}
	return url
}


