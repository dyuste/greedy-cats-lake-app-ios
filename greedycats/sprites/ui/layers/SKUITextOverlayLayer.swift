//
//  OverlayTextNode.swift
//  greedycats
//
//  Created by David Yuste on 6/14/15.
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
import SpriteKit

class SKUITextOverlayLayer : SKUILayer {
	var labelNode : SKUINiceLabelNode!
	
	override init() {
		super.init()
		labelNode = SKUINiceLabelNode()
		labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
		labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
		labelNode.fontName = Fonts.HugeOverlayFontName
		labelNode.fontSize = Fonts.HugeOverlayFontSize
		labelNode.fontColor = SKColor.whiteColor()
		name = "SKUITextOverlayLayer"
		zPosition = 1
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	var text : String? {
		set {
			labelNode?.text = newValue!
		}
		get {
			return labelNode?.text
		}
	}
	
	var fontColor : UIColor? {
		set {
			labelNode?.fontColor = newValue!
		}
		get {
			return labelNode?.fontColor
		}
	}
	
	func presentInLayer(layer : SKUILayer, withSize : CGSize, during: Double?) {
		labelNode.position = CGPoint(x: withSize.width/2, y: withSize.height/2 + 45)
		addChild(labelNode)
		layer.addChild(self)
		
		if during != nil {
			let delayTime = dispatch_time(DISPATCH_TIME_NOW,
				Int64(during! * Double(NSEC_PER_SEC)))
			dispatch_after(delayTime, dispatch_get_main_queue()) {
				if self.parent != nil {
					self.dismiss(1.0)
				}
			}
		}
	}
	
	func dismiss(during : Double) {
		labelNode.runAction(SKAction.fadeOutWithDuration(during), completion: {
			if self.parent != nil {
				self.labelNode.removeFromParent()
				self.removeFromParent()
			}
		})
	}
	
	override func tapHandler(layer : SKUILayer, node: SKNode, point : CGPoint) -> Void {
	}
	
}

