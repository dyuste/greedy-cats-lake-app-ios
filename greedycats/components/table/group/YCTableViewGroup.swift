//
//  YCTableViewGroup.swift
//  greedycats
//
//  Created by David Yuste on 10/9/15.
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

class YCTableViewGroup {
	var name : String
	var cellIdentifier : String
	var roundedBorder : Bool = false
	
	var data : [AnyObject]  {
		set {
			_data = newValue
			_table.reloadData()
		}
		get {
			return _data
		}
	}
	
	private var _data : [AnyObject] = []
	private var _table : YCTableView
	
	init(table : YCTableView, name : String, cellIdentifier : String) {
		self._table = table
		self.cellIdentifier = cellIdentifier
		self.name = name
		table.addGroup(self)
	}
	
	func rowCount() -> Int {
		return _data.count
	}
	
	func cellForRow(row : Int) -> UITableViewCell? {
		var cell : YCTableViewCell?
		cell = _table.dequeueReusableCellWithIdentifier(cellIdentifier) as? YCTableViewCell
		if cell == nil {
			cell = cellCreator?(cellIdentifier: cellIdentifier, withData: _data[row])
		}
		if cell != nil {
			cellConfigurer?(cell: cell!, withData: _data[row])
		}
		return cell
	}
	
	func didSelectRow(row : Int) {
		cellSelectHandler?(withData: _data[row])
	}
	
	func heightForRow(row : Int) -> CGFloat {
		return cellHeightConfigurer != nil ? cellHeightConfigurer!(withData: _data[row]) : 30
	}
	
	var cellCreator : ((cellIdentifier : String, withData : AnyObject) -> YCTableViewCell)?
	var cellConfigurer : ((cell : YCTableViewCell, withData : AnyObject) -> YCTableViewCell)?
	var cellSelectHandler : ((withData : AnyObject) -> Void)?
	var cellHeightConfigurer : ((withData : AnyObject) -> CGFloat)?
	
	var headerViewCreator : (() -> UIView?)?
	var heightForHeader : (() -> CGFloat)?
	
	var footerViewCreator : (() -> UIView?)?
	var heightForFooter : (() -> CGFloat)?

}
