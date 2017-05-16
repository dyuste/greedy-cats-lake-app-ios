//
//  SKUIButtonNode.swift
//  greedycats
//
//  Created by David Yuste on 5/23/15.
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
import SpriteKit

class SKUIButtonNode : SKUIWidget {
	var title : String {
		set {
			titleText = newValue
			updateContent()
		}
		get {
			return titleText as String
		}
	}
	
	private var titleText : NSString = ""
	private var surfaceNode : SKShapeNode!
	private var titleNode : SKUINiceLabelNode!
	
	init(title : String) {
		super.init()
		
		surfaceNode = SKShapeNode()
		surfaceNode.position = CGPointMake(0,0)
		surfaceNode.fillColor = Colors.PrimaryColor
		surfaceNode.strokeColor = Colors.PrimaryColor
		addChild(surfaceNode)
		
		titleNode = SKUINiceLabelNode()
		titleNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
		titleNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
		titleNode.fontName = Fonts.DefaultH2FontName
		titleNode.fontSize = Fonts.DefaultH2FontSize
		titleNode.fontColor = SKColor.whiteColor()
		titleNode.position = CGPointMake(0,0)
		addChild(titleNode)
		
		self.title = title
	}

	private func updateContent() {
		var size: CGSize = titleText.sizeWithAttributes([NSFontAttributeName: Fonts.HugeOverlayFont!])
		size.width += 16
		size.height += 10
		
		titleNode.text = title
		surfaceNode.path = CGPathCreateWithRoundedRect(
			CGRectMake(-size.width/2, -size.height/2, size.width, size.height), 5, 5, nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}

