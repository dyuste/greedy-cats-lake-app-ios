//
//  YCFormTableViewGroup.swift
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

class YCFormTableViewGroup : YCTableViewGroup {
	init(table : YCTableView, name : String) {
		super.init(table: table, name: name, cellIdentifier: "formCell")
		cellCreator = formCellCreator
		cellConfigurer = formCellConfigurer
		cellSelectHandler = formCellSelectHandler
		cellHeightConfigurer = formHeightForRow
	}
	
	func setControls(controls : [YCFormTableViewControl]) {
		data = controls
	}
	
	private func formCellCreator (cellIdentifier : String, withData : AnyObject) -> YCTableViewCell {
		let control = withData as! YCFormTableViewControl
		switch control.type {
		case .Button:
			let cell = ButtonTableViewCell(
				caption: control.caption,
				reuseIdentifier: control.cellIdentifier)
			cell.buttonView.addTarget(control, action: "buttonClick:", forControlEvents: .TouchUpInside)
			control.cell = cell
			return cell
		case .TextField:
			let cell = TextFieldTableViewCell(
				caption: control.caption,
				reuseIdentifier: control.cellIdentifier)
			cell.editCallback = control.edit
			control.cell = cell
			return cell
		}
	}
	
	private func formCellConfigurer (cell : YCTableViewCell, withData : AnyObject) -> YCTableViewCell {
		let control = withData as! YCFormTableViewControl
		switch control.type {
		case .Button:
			let controlCell = cell as! ButtonTableViewCell
			controlCell.buttonView.setTitle(control.caption, forState: .Normal)
		case .TextField:
			let controlCell = cell as! TextFieldTableViewCell
			controlCell.captionLabel.text = control.caption
			if control.defaultText != nil {
				controlCell.textField!.text = control.defaultText!()
			}
			if control.firstResponder {
				controlCell.textField!.becomeFirstResponder()
			}
		}
		return cell
	}
	
	private func formCellSelectHandler (withData : AnyObject) -> Void {
		let control = withData as! YCFormTableViewControl
		control.action?()
	}
	
	private func formHeightForRow (withData : AnyObject) -> CGFloat {
		let control = withData as! YCFormTableViewControl
		return control.height
	}
}
