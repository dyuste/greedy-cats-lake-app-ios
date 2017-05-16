//
//  SKUINiceLabelNode.swift
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

class SKUINiceLabelNode : SKLabelNode {
	var droppedShadow : SKLabelNode?
	
	override init() {
		super.init()
		droppedShadow = SKLabelNode(fontNamed: fontName)
		droppedShadow!.fontColor = UIColor.blackColor()
		droppedShadow!.alpha = 0.5
		droppedShadow!.zPosition = -1
		droppedShadow!.position = CGPointMake(1, -1)
		addChild(droppedShadow!)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override var text : String? {
		set {
			super.text = newValue
			droppedShadow?.text = newValue
		}
		get {
			return super.text
		}
	}

	override var fontName : String? {
		set {
			super.fontName = newValue
			droppedShadow?.fontName = newValue
		}
		get {
			return super.fontName
		}
	}
	
	override var fontSize : CGFloat {
		set {
			super.fontSize = newValue
			droppedShadow?.fontSize = newValue
		}
		get {
			return super.fontSize
		}
	}
	
	override var verticalAlignmentMode: SKLabelVerticalAlignmentMode {
		set {
			super.verticalAlignmentMode = newValue
			droppedShadow?.verticalAlignmentMode = newValue
		}
		get {
			return super.verticalAlignmentMode
		}
	}
	
	override var horizontalAlignmentMode: SKLabelHorizontalAlignmentMode {
		set {
			super.horizontalAlignmentMode = newValue
			droppedShadow?.horizontalAlignmentMode = newValue
		}
		get {
			return super.horizontalAlignmentMode
		}
	}
	
	override var colorBlendFactor: CGFloat {
		set {
			super.colorBlendFactor = newValue
			droppedShadow?.colorBlendFactor = newValue
		}
		get {
			return super.colorBlendFactor
		}
	}
}

