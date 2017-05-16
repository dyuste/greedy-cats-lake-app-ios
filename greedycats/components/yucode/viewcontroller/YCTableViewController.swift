//
//  YCViewController.swift
//  greedycats
//
//  Created by David Yuste on 6/14/15.
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

class YCTableViewController: YCViewController {
	
	required init()
	{
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func attachManagers() {
		super.attachManagers()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
	}
	
	override func detachManagers() {
		super.detachManagers()
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	//MARK:-
	//MARK: Table aspect
	weak var baseConstraint: NSLayoutConstraint!
	var tableView : YCTableView!
	
	override func createContentView() -> UIView {
		tableView = createTableView(UIScreen.mainScreen().bounds)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.insertSubview(tableView, aboveSubview: backgroundView)
		
		Layout.setConstraints(view,
			constraints : [
				"V:|-\(Metrics.DefaultMargin)-[t]",
				"H:|-\(Metrics.BigSeparator)-[t]-\(Metrics.BigSeparator)-|"],
			metrics: nil,
			views: ["t" : tableView],
			options: nil)
		
		let constraint = NSLayoutConstraint(
			item: view,
			attribute: .Bottom,
			relatedBy: .Equal,
			toItem: tableView,
			attribute: .Bottom,
			multiplier: 1,
			constant: 0)
		view.addConstraints([constraint])

		baseConstraint = constraint
		return tableView
	}
	
	func createTableView(bounds: CGRect) -> YCTableView? {
		return nil;
	}
	
	//MARK:-
	//MARK: Keyboard interaction
	func keyboardWillShow(notification: NSNotification) {
		animateScrollViewWithKeyboard(notification)
	}
	
	func keyboardWillHide(notification: NSNotification) {
		animateScrollViewWithKeyboard(notification)
	}
	
	func animateScrollViewWithKeyboard(notification: NSNotification) {
		
		let userInfo = notification.userInfo!
		
		let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
		let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
		let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
		
		// baseContraint is your Auto Layout constraint that pins the
		// text view to the bottom of the superview.
		
		if notification.name == UIKeyboardWillShowNotification {
			baseConstraint.constant = +keyboardSize.height  // move up
		}
		else {
			baseConstraint.constant = 0 // move down
		}
		
		view.setNeedsUpdateConstraints()
		
		let options = UIViewAnimationOptions(rawValue: curve << 16)
		UIView.animateWithDuration(duration, delay: 0, options: options,
			animations: {
				self.view.layoutIfNeeded()
			},
			completion: nil
		)
	}
	
}
