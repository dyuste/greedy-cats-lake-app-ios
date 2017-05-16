//
//  Adapter.swift
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
import UIKit

protocol Delegate : class {
	
}

class Manager : NSObject {
	private var enterForegroundNotification : NSObjectProtocol!
	private var resignForegroundNotification : NSObjectProtocol!
	
	override init () {
		delegates = [];
		super.init()
		
		enterForegroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
			[unowned self] notification in
				self.managerWillEnterForeground()
		}
		resignForegroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
			[unowned self] notification in
			self.managerWillResignForeground()
		}
		
		managerWillStart()
	}
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(enterForegroundNotification)
		NSNotificationCenter.defaultCenter().removeObserver(resignForegroundNotification)
	}
	
	
	func managerWillStart() {
	}
	
	func managerWillResignForeground() {
	}
	
	func managerWillEnterForeground() {
	}
	
	
	var delegates : Array<Delegate>
	func addDelegate (delegateObject : Delegate) {
		delegates.append(delegateObject);
	}
	
	func removeDelegate (delegateObject : AnyObject) {
		var newDelegates : Array<Delegate> = []
		for delegate in delegates {
			if delegate !== delegateObject {
				newDelegates.append(delegate)
			}
		}
		delegates = newDelegates
	}
}
