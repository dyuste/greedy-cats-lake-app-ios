//
//  ShadowLabel.swift
//  greedycats
//
//  Created by David Yuste on 11/8/15.
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

class ShadowLabel : UILabel
{
	override func intrinsicContentSize() -> CGSize
	{
		var size = super.intrinsicContentSize()
		size.width  += 8
		return size
	}
	
	override func drawTextInRect(rect : CGRect)
	{
		let myShadowOffset : CGSize = CGSizeMake(0, 0)
		let myColorValues : [CGFloat] = [0, 0, 0, 0.8]
		let myContext = UIGraphicsGetCurrentContext()
		CGContextSaveGState(myContext)
	
		let myColorSpace = CGColorSpaceCreateDeviceRGB()
		let myColor = CGColorCreate(myColorSpace, myColorValues)
		CGContextSetShadowWithColor (myContext, myShadowOffset, 8, myColor)
	
		var realRect = rect
		realRect.origin.x += 4
		super.drawTextInRect(realRect)
	
		CGContextRestoreGState(myContext)
	}
}
