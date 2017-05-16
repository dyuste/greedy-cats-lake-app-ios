//
//  SignInViewController.swift
//  Greedy Cats
//
//  Created by David Yuste on 2/26/15.
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

class SignInViewController : YCTableViewController, SessionDelegate {
	
	required init() {
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func attachManagers() {
		super.attachManagers()
		SessionManager.Singleton.addDelegate(self)
	}
	
	override func detachManagers() {
		super.detachManagers()
		SessionManager.Singleton.removeDelegate(self)
	}
	
	override func kickOffView() {
		super.kickOffView()
	}
	
	override func attachWidgets(topView : UIView) {
		super.attachWidgets(topView)
		let backButton = BackButtonWidget()
		backButton.addToView(self, view: topView)
	}
	
	override func createTableView(bounds: CGRect) -> YCTableView? {
		let tableView = YCTableView(frame: bounds, style: UITableViewStyle.Grouped)
		tableView.backgroundColor = Colors.TransparentColor
		tableView.separatorColor = Colors.TransparentColor
		createActionsGroup(tableView)
		return tableView
	}
	
	var userName : String = ""
	var pass1 : String = ""
	var userNameControl : YCFormTableViewControl?
	var pass1Control : YCFormTableViewControl?
	
	private func createActionsGroup(tableView : YCTableView) -> YCTableViewGroup {
		let group = YCFormTableViewGroup(table: tableView, name: "actions")
		
		userNameControl = YCFormTableViewControl.createTextField(
			NSLocalizedString("Type here your user name or email", comment: ""),
			action: {},
			edit : { string in self.userName = string }
		)
		pass1Control = YCFormTableViewControl.createTextField(
			NSLocalizedString("Type your password", comment: ""),
			action: {},
			edit : { string in self.pass1 = string }
		)
		
		group.setControls([
			userNameControl!,
			pass1Control!,
			YCFormTableViewControl.createButton(
				NSLocalizedString("Sign In", comment: ""),
				action: {
					self.signInAction()
				}
			),
			YCFormTableViewControl.createButton(
				NSLocalizedString("Create random user", comment: ""),
				action: {
					SessionManager.Singleton.performDummySignUp()
			})
		])
		
		group.heightForHeader = {
			return 2*Metrics.StatusBarHeight
		}
		return group
	}
	
	func signInAction() {
		let userNameCell = userNameControl?.cell as! TextFieldTableViewCell?
		userNameCell?.textField.layer.borderColor = UIColor.clearColor().CGColor
		userNameCell?.textField.layer.borderWidth = 0
		
		let pass1NameCell = pass1Control?.cell as! TextFieldTableViewCell?
		pass1NameCell?.textField.layer.borderColor = UIColor.clearColor().CGColor
		pass1NameCell?.textField.layer.borderWidth = 0
		
		SessionManager.Singleton.performSignIn(userName, pass: pass1)
	}
	
	//MARK:-
	//MARK: SessionAdapter
	func sessionSignInDidFail() {
		let userNameCell = userNameControl?.cell as! TextFieldTableViewCell?
		userNameCell?.textField.layer.borderColor = UIColor.redColor().CGColor
		userNameCell?.textField.layer.borderWidth = 2.0
		
		let pass1NameCell = pass1Control?.cell as! TextFieldTableViewCell?
		pass1NameCell?.textField.layer.borderColor = UIColor.redColor().CGColor
		pass1NameCell?.textField.layer.borderWidth = 2.0
		pass1NameCell?.textField.text = ""
	}
	
	func sessionSignInDidSuccess() {
		NavigationManager.Singleton.backToController(HomeViewController.self)
	}
	func sessionSignUpDidFail() {}
	func sessionLookUpUserNameDidSuccess(userName: String, available: Bool) {}
	func sessionLookUpUserNameDidFail() {}
	func sessionExtendAccountDidSuccess() {}
	func sessionExtendAccountDidFail() {}
}
