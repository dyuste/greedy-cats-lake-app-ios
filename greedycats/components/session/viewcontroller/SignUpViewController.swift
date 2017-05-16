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

class SignUpViewController : YCTableViewController, SessionDelegate {
	var inputValidateTimer : NSTimer?
	var storedUserName : NSString?
	var validUserName : Bool?
	
	required init() {
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func attachManagers() {
		super.attachManagers()
		SessionManager.Singleton.addDelegate(self)
		inputValidateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("validateNetworkFields"), userInfo: nil, repeats: true)
	}
	
	override func detachManagers() {
		super.detachManagers()
		inputValidateTimer?.invalidate()
		SessionManager.Singleton.removeDelegate(self)
	}
	
	override func kickOffView() {
		super.kickOffView()
		initializeFormContents()
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
	var name : String = ""
	var pass1 : String = ""
	var pass2 : String = ""
	var email : String = ""
	var userNameControl : YCFormTableViewControl?
	var nameControl : YCFormTableViewControl?
	var pass1Control : YCFormTableViewControl?
	var pass2Control : YCFormTableViewControl?
	var emailControl : YCFormTableViewControl?
	
	private func createActionsGroup(tableView : YCTableView) -> YCTableViewGroup {
		let group = YCFormTableViewGroup(table: tableView, name: "actions")
		
		userNameControl = YCFormTableViewControl.createTextField(
			NSLocalizedString("Pick your user name", comment: ""),
			action: {},
			edit : { string in self.userName = string }
		)
		nameControl = YCFormTableViewControl.createTextField(
			NSLocalizedString("Type your real name", comment: ""),
			action: {},
			edit : { string in self.name = string }
		)
		emailControl = YCFormTableViewControl.createTextField(
			NSLocalizedString("Link your account with an email address", comment: ""),
			action: {},
			edit : { string in self.email = string }
		)
		pass1Control = YCFormTableViewControl.createTextField(
			NSLocalizedString("Create a password for your account", comment: ""),
			action: {},
			edit : { string in self.pass1 = string }
		)
		pass2Control = YCFormTableViewControl.createTextField(
			NSLocalizedString("Confirm your password", comment: ""),
			action: {},
			edit : { string in self.pass2 = string }
		)
		
		group.setControls([
			YCFormTableViewControl.createButton(
				NSLocalizedString("Login as another user", comment: ""),
				action: {
					NavigationManager.Singleton.forwardToController(SignInViewController.self)
				}
			),
			userNameControl!,
			nameControl!,
			emailControl!,
			pass1Control!,
			pass2Control!,
			YCFormTableViewControl.createButton(
				NSLocalizedString("Save Changes", comment: ""),
				action: {
					if self.validateFields(false) {
						SessionManager.Singleton.performExtendAccount(self.userName, pass: self.pass1, name: self.name, email: self.email)
					}
				}
			)
		])
		
		group.heightForHeader = {
			return 2*Metrics.StatusBarHeight
		}
		
		return group
	}
	
	func initializeFormContents() {
		if let loggedUser = SessionManager.Singleton.user {
			self.userName = loggedUser.userName
			let userNameCell = userNameControl?.cell as! TextFieldTableViewCell?
			userNameCell?.textField.text = userName
			
			if let name = loggedUser.name {
				self.name = name
				let nameCell = nameControl?.cell as! TextFieldTableViewCell?
				nameCell?.textField.text = name
			}
			if let email = loggedUser.email {
				self.email = email
				let emailCell = emailControl?.cell as! TextFieldTableViewCell?
				emailCell?.textField.text = email
			}
		}
	}
	
	func validateNetworkFields () {
		if storedUserName == nil {
			validUserName = nil
			storedUserName = userName
		} else if userName != storedUserName! {
			storedUserName = userName
			if storedUserName!.length > 0 {
				validUserName = nil
				SessionManager.Singleton.startLookUpUserName(storedUserName! as String)
			} else {
				validUserName = false
			}
			validateFields(true)
		}
	}
	
	func validateFields(auto : Bool) -> Bool {
		var valid : Bool = true
		if (!auto) {
			let nameCell = nameControl?.cell as! TextFieldTableViewCell?
			if name.isEmpty {
				valid = false
				nameCell?.textField.layer.borderColor = UIColor.redColor().CGColor
				nameCell?.textField.layer.borderWidth = 2.0
			} else {
				nameCell?.textField.layer.borderColor = UIColor.clearColor().CGColor
				nameCell?.textField.layer.borderWidth = 0
			}
			
			let pass1Cell = pass1Control?.cell as! TextFieldTableViewCell?
			let pass2Cell = pass2Control?.cell as! TextFieldTableViewCell?
			if pass1.isEmpty || pass1 != pass2 {
				valid = false
				pass1Cell?.textField.layer.borderColor = UIColor.redColor().CGColor
				pass2Cell?.textField.layer.borderColor = UIColor.redColor().CGColor
				pass1Cell?.textField.layer.borderWidth = 2.0
				pass2Cell?.textField.layer.borderWidth = 2.0
			} else {
				pass1Cell?.textField.layer.borderColor = UIColor.clearColor().CGColor
				pass2Cell?.textField.layer.borderColor = UIColor.clearColor().CGColor
				pass1Cell?.textField.layer.borderWidth = 0
				pass2Cell?.textField.layer.borderWidth = 0
			}
			
			let emailCell = emailControl?.cell as! TextFieldTableViewCell?
			if (email as NSString).length < 5 || (email as NSString).rangeOfString("@").location == NSNotFound {
				valid = false
				emailCell?.textField.layer.borderColor = UIColor.redColor().CGColor
				emailCell?.textField.layer.borderWidth = 2.0
			} else {
				emailCell?.textField.layer.borderColor = UIColor.clearColor().CGColor
				emailCell?.textField.layer.borderWidth = 0
			}
		}
		
		let userNameCell = userNameControl?.cell as! TextFieldTableViewCell?
		if validUserName == nil {
			valid = false
			userNameCell?.textField.layer.borderColor = UIColor.clearColor().CGColor
			userNameCell?.textField.layer.borderWidth = 0
		} else if !validUserName! {
			valid = false
			userNameCell?.textField.layer.borderColor = UIColor.redColor().CGColor
			userNameCell?.textField.layer.borderWidth = 2.0
		} else {
			userNameCell?.textField.layer.borderColor = UIColor.greenColor().CGColor
			userNameCell?.textField.layer.borderWidth = 2.0
		}

		return valid
	}
	
	//MARK:-
	//MARK: SessionAdapter
	func sessionSignInDidFail() {}
	
	func sessionSignInDidSuccess() -> Void {
		NavigationManager.Singleton.backToController(HomeViewController.self)
	}
	
	func sessionSignUpDidFail() {
		let pass1Cell = pass1Control?.cell as! TextFieldTableViewCell?
		let pass2Cell = pass2Control?.cell as! TextFieldTableViewCell?
		pass1Cell?.textField.text = ""
		pass2Cell?.textField.text = ""
	}
	
	func sessionLookUpUserNameDidSuccess(userName: String, available: Bool) {
		if userName == storedUserName {
			validUserName = available
			validateFields(true)
		}
	}
	
	func sessionLookUpUserNameDidFail() {}
	
	func sessionExtendAccountDidSuccess() {
		NavigationManager.Singleton.backToController(HomeViewController.self)
	}
	func sessionExtendAccountDidFail() {
		let pass1Cell = pass1Control?.cell as! TextFieldTableViewCell?
		let pass2Cell = pass2Control?.cell as! TextFieldTableViewCell?
		pass1Cell?.textField.text = ""
		pass2Cell?.textField.text = ""
	}
	
}
