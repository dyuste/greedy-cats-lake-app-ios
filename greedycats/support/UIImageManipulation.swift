//
//  UIImageManipulation.swift
//  greedycats
//
//  Created by David Yuste on 10/11/15.
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

extension UIImage {
	
	func tintWithColor(color:UIColor)->UIImage {
		
		// create uiimage
		UIGraphicsEndImageContext()
		UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
		color.setFill()
		let bounds : CGRect = CGRectMake(0, 0, self.size.width, self.size.height);
		UIRectFill(bounds);
		drawInRect(bounds, blendMode:CGBlendMode.Overlay, alpha:1.0);
		drawInRect(bounds, blendMode:CGBlendMode.DestinationIn, alpha:1.0);
		
		let tintedImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return tintedImage
		
	}
	
}
