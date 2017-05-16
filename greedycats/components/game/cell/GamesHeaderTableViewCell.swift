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

public class GamesHeaderTableViewCell: UITableViewCell {
	var captionLabel: UILabel!
	var bgImage: UIImageView!
	var leftAlign : Bool = true
	
	var preferredHeight : CGFloat = 30
	var preferredWidth : CGFloat = 200
	
	init(reuseIdentifier: String?, leftAlign : Bool) {
		super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
		self.leftAlign = leftAlign
		
		preferredWidth = Metrics.GroupTitleWidth
		preferredHeight = Metrics.GroupTitleHeight
		let frame = captionFrame()
			
		let image : UIImage = UIImage(named:"GameTitle.png")!
		bgImage = UIImageView(image: image)
		bgImage.frame = frame
		contentView.addSubview(bgImage)
			
			
		captionLabel = UILabel(frame: frame)
		captionLabel.textColor = Colors.ButtonTextColor
		captionLabel.autoresizingMask = UIViewAutoresizing.None
		captionLabel.textAlignment = NSTextAlignment.Center
		captionLabel.font = Fonts.TableHeaderFont
		backgroundColor = Colors.TransparentColor
		contentView.addSubview(captionLabel)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func willDisplayCell() {
		let frame = captionFrame()
		captionLabel.frame = frame
		bgImage.frame = frame
		self.backgroundColor = Colors.TransparentColor
	}
	
	func captionFrame() -> CGRect {
		let bounds = frame
		if leftAlign {
			return CGRect(x:25, y:0, width: preferredWidth, height: preferredHeight)
		} else {
			return CGRect(x:bounds.size.width - preferredWidth - 25, y:0, width: preferredWidth, height: preferredHeight)
		}
	}
	
}
