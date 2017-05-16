
//
//  IAPListViewController.swift
//  Hunter Cats
//
//  Created by David Yuste on 2/19/15.
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

class YCTableView : UITableView, UITableViewDelegate, UITableViewDataSource  {
	private var _groups : [YCTableViewGroup] = []
	
	override init(frame: CGRect, style: UITableViewStyle) {
		super.init(frame: frame, style: style)
		delegate      =   self
		dataSource    =   self
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func addGroup(group : YCTableViewGroup) {
		_groups.append(group)
	}
	
	// MARK:-
	// MARK: View
	
	override func layoutSubviews() {
		super.layoutSubviews()

		for var section = 0; section < _groups.count; ++section {
			let group = _groups[section]
			if group.roundedBorder {
				for var row = 0; row < group.rowCount(); ++row {
					let indexPath = NSIndexPath(forRow: row, inSection: section)
					if let cell = cellForRowAtIndexPath(indexPath) {
						let ycCell = cell as! YCTableViewCell
						ycCell.makeRoundedGroupBorder(self, indexPath: indexPath)
					}
				}
			}
		}
	}
	
	// MARK:-
	// MARK: TableView
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return _groups.count
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return _groups[section].rowCount()
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		return _groups[indexPath.section].cellForRow(indexPath.row)!
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return _groups[indexPath.section].heightForRow(indexPath.row)
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		_groups[indexPath.section].didSelectRow(indexPath.row)
	}
	
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		let ycCell = cell as! YCTableViewCell
		ycCell.willDisplayCell()
	}
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let handler = _groups[section].headerViewCreator
		if handler != nil {
			return handler!()
		} else {
			return nil
		}
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		let handler = _groups[section].heightForHeader
		if handler != nil {
			return handler!()
		} else {
			return Metrics.DefaultTableSectionHeaderHeight
		}
	}
	
	func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let handler = _groups[section].footerViewCreator
		if handler != nil {
			return handler!()
		} else {
			return nil
		}
	}
	
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		let handler = _groups[section].heightForFooter
		if handler != nil {
			return handler!()
		} else {
			return Metrics.DefaultTableSectionFooterHeight
		}
	}
	
}
