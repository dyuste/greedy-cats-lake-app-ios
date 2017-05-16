//
//  CustomTextField.swift
//  Greedy Cats
//
//  Created by David Yuste on 5/1/15.
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

class CustomTextField: UITextField {
	var bgImage : UIImageView?
	
	static var preferredHeight : CGFloat = 64
	
	override var frame : CGRect {
		didSet {
			bgImage?.frame = CGRect(x: 0, y: 5, width: self.bounds.width, height: self.bounds.height - 10)
		}
	}
	init(frame: CGRect, placeHolderText: String) {
		super.init(frame: frame)
		
		let image : UIImage = UIImage(named:"TextField.png")!
		bgImage = UIImageView(image: image)
		bgImage!.frame = frame
		self.addSubview(bgImage!)
		
		backgroundColor = Colors.TransparentColor
		borderStyle = UITextBorderStyle.None
		textColor = Colors.InputTextColor
		let attrString: NSMutableAttributedString = NSMutableAttributedString(string: placeHolderText)
		attrString.addAttribute(NSForegroundColorAttributeName,
			value: Colors.InputPlaceHolderColor,
			range: NSMakeRange(0, attrString.length))
		attributedPlaceholder = attrString
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)		
		backgroundColor = Colors.TransparentColor
		borderStyle = UITextBorderStyle.None
		textColor = Colors.InputTextColor
	}
	
	override func textRectForBounds(bounds : CGRect) -> CGRect {
		return CGRectInset(bounds, 10, 10)
	}
	
	override func editingRectForBounds(bounds : CGRect) -> CGRect {
		return CGRectInset(bounds, 10, 10)
	}
}
