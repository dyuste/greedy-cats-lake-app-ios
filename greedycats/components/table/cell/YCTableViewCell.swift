//
//  YCTableViewCell.swift
//  greedycats
//
//  Created by David Yuste on 11/1/15.
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

class YCTableViewCell : UITableViewCell {
	
	func willDisplayCell() {
		self.backgroundColor = Colors.TransparentColor
	}
	
	func makeRoundedGroupBorder(tableView: UITableView, indexPath : NSIndexPath) {
		let cornerRadius : CGFloat = 10
		backgroundColor = UIColor.clearColor()
		let layer = CAShapeLayer()
		let pathRef = CGPathCreateMutable()
		let bounds = CGRectInset(self.bounds, 10, 0)
		var addLine = false
		if (indexPath.row == 0 && indexPath.row == tableView.numberOfRowsInSection(indexPath.section)-1) {
			CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius)
		} else if (indexPath.row == 0) {
			CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds))
			CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius)
			CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius)
			CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))
			addLine = true
		} else if (indexPath.row == tableView.numberOfRowsInSection(indexPath.section)-1) {
			CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds))
			CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius)
			CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius)
			CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds))
		} else {
			CGPathAddRect(pathRef, nil, bounds)
			addLine = true
		}
		layer.path = pathRef
		
		layer.strokeColor = Colors.SecondaryColor.CGColor
		layer.lineWidth = 3;
		layer.fillColor = UIColor(white:1, alpha:1).CGColor
		
		if addLine {
			let lineLayer = CALayer()
			let lineHeight : CGFloat = (1.0 / UIScreen.mainScreen().scale)
			lineLayer.frame = CGRectMake(CGRectGetMinX(bounds), bounds.size.height-lineHeight, bounds.size.width, lineHeight)
			lineLayer.backgroundColor = tableView.separatorColor!.CGColor
			layer.addSublayer(lineLayer)
		}
		
		let testView = UIView(frame:bounds)
		testView.layer.insertSublayer(layer, atIndex:0)
		testView.backgroundColor = UIColor.clearColor()
		backgroundView = testView;
	}
}
