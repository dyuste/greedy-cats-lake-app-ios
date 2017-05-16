//
//  Layout.swift
//  greedycats
//
//  Created by David Yuste on 11/7/15.
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

class Layout {
	static func setConstraints(view : UIView!, constraints : [String], metrics: [String : AnyObject]?, views: [String : AnyObject], options : NSLayoutFormatOptions?)
	{
		let actualOptions = options != nil ? options! : NSLayoutFormatOptions(rawValue: 0)
		for constraint in constraints {
			let cc = NSLayoutConstraint.constraintsWithVisualFormat(
				constraint, options: actualOptions,
				metrics: metrics, views: views)
			view.addConstraints(cc)
		}
	}
		
	static func setCenterContraints(superview : UIView!, view : UIView!, widthConstraint : String?, heightConstraint : String?)
	{
		var widthString : String
		if let constraint = widthConstraint {
			widthString = "(\(constraint))"
		} else {
			widthString = ""
		}
		
		var heightString : String
		if let constraint = heightConstraint {
			heightString = "(\(constraint))"
		} else {
			heightString = ""
		}
		
		// Center horizontally
		var constraints = NSLayoutConstraint.constraintsWithVisualFormat(
			"V:[superview]-(<=1)-[view\(heightString)]",
			options: NSLayoutFormatOptions.AlignAllCenterX,
			metrics: nil,
			views: ["superview":superview, "view":view])
		
		superview.addConstraints(constraints)
		
		// Center vertically
		constraints = NSLayoutConstraint.constraintsWithVisualFormat(
			"H:[superview]-(<=1)-[view\(widthString)]",
			options: NSLayoutFormatOptions.AlignAllCenterY,
			metrics: nil,
			views: ["superview":superview, "view":view])
		
		superview.addConstraints(constraints)
	} 
}
