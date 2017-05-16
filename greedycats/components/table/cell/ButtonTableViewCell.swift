//
//  ButtonTableViewCell.swift
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

class ButtonTableViewCell: YCTableViewCell {
	var captionLabel: UILabel!
	var buttonView: UIButton!
	
	var preferredHeight : CGFloat = 60
	var preferredWidth : CGFloat = 300
	
	init(caption: String,
		reuseIdentifier: String?) {
			super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
			
			preferredWidth = Metrics.WideWidth
			
			createView(caption)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	private func createView(caption : String)
	{
		selectionStyle = UITableViewCellSelectionStyle.None
		
		buttonView = UIButton()
		buttonView.frame = frame
		buttonView.setBackgroundImage(UIImage(named:"CircleButton.png")!, forState: .Normal)
		buttonView.setBackgroundImage(UIImage(named:"CircleButtonDown.png")!, forState: .Highlighted)
		buttonView.titleLabel?.font = Fonts.DefaultH2Font
		buttonView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(buttonView)
		
		Layout.setCenterContraints(contentView,
			view: buttonView,
			widthConstraint: "\(preferredWidth)",
			heightConstraint: nil)	}
}
