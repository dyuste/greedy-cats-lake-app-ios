//
//  YCFormTableViewControl.swift
//  greedycats
//
//  Created by David Yuste on 11/14/15.
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

class YCFormTableViewControl : NSObject {
	enum ControlType {
		case Button
		case TextField
	}

	var type : ControlType
	
	// Common controls
	var caption : String
	var action : (()->Void)?
	
	// Edit control
	var defaultText : (()->String)?
	var edit : ((String)->Void)?
	var firstResponder : Bool = false
	
	weak var cell : YCTableViewCell?
	
	var height : CGFloat {
		get {
			switch type {
			case .Button: return Metrics.ButtonRowHeight
			case .TextField: return  Metrics.TextFieldRowHeight
			}
		}
	}
	var cellIdentifier : String {
		get {
			switch type {
			case .Button: return "button"
			case .TextField: return "textField"
			}
		}
	}
	init (type : ControlType, caption : String, action : (()->Void)) {
		self.type = type
		self.caption = caption
		self.action = action
	}
	
	func buttonClick(sender: UIButton!) {
		action?()
	}
	
	static func createButton(caption : String, action : (()->Void)) -> YCFormTableViewControl {
		return YCFormTableViewControl(type: .Button, caption: caption, action: action)
	}
	
	static func createTextField(caption : String, action : (()->Void), edit : ((String)->Void)) -> YCFormTableViewControl {
		let control = YCFormTableViewControl(type: .TextField, caption: caption, action: action)
		control.edit = edit
		return control
	}
	
	static func createTextField(caption : String, defaultText: (()->String), action : (()->Void), edit : ((String)->Void)) -> YCFormTableViewControl {
		let control = YCFormTableViewControl(type: .TextField, caption: caption, action: action)
		control.edit = edit
		control.defaultText = defaultText
		return control
	}
}
