//
//  PaddingImageView.swift
//  greedycats
//
//  Created by David Yuste on 11/24/15.
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

class PaddingImageView : UIView {
	var imageView : UIImageView!

	private var top : CGFloat = 0;
	private var bottom : CGFloat = 0;
	private var left : CGFloat = 0;
	private var right : CGFloat = 0;
	
	init(named: String, top : CGFloat, bottom : CGFloat, left : CGFloat, right : CGFloat) {
		self.top = top
		self.bottom = bottom
		self.left = left
		self.right = right
		super.init(frame : CGRectMake(0,0,0,0))
		createLayout(named)
	}
	
	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	
	func createLayout(named: String) {
		let image = UIImage(named: named)
		let imageView = UIImageView(image: image!)
		imageView.contentMode = .ScaleAspectFit
		imageView.backgroundColor = Colors.TransparentColor
		imageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(imageView)
		Layout.setConstraints(self,
			constraints : [
				"V:|-\(top)-[t]-\(bottom)-|",
				"H:|-\(left)-[t]-\(right)-|"],
			metrics: nil,
			views: ["t" : imageView],
			options: nil)
	}
}
