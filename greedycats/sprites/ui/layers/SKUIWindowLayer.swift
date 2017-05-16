//
//  SKUIWindowLayer.swift
//  greedycats
//
//  Created by David Yuste on 9/6/15.
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

class SKUIWindowLayer : SKUILayer {
	func presentInLayer(layer : SKUILayer, withFrame : CGRect?) {
		let frame = withFrame != nil ? withFrame! : getFrameForLayer(layer)
		removeAllChildren()
		createLayer(frame)
		position = CGPointMake(frame.origin.x, frame.origin.y)
		zPosition = CGFloat(layer.children.count + 1)
		layer.addChild(self)
	}
	
	func dismiss() {
			removeFromParent()
	}
	
	func getFrameForLayer(layer : SKUILayer) -> CGRect {
		let bounds = layer.bounds
		let origin = bounds.origin
		return CGRectMake(origin.x + 0.1 * bounds.width, origin.y + 0.1 * bounds.height,
				bounds.width*0.8, bounds.height*0.8)
	}
	
	func createLayer(frame : CGRect) {
		let surfaceNode = SKShapeNode()
		surfaceNode.position = CGPointMake(0,0)
		surfaceNode.path = CGPathCreateWithRoundedRect(CGRectMake(0,0,frame.width, frame.height), 5, 5, nil)
		surfaceNode.fillColor = Colors.EnacedBlackgroundColor
		surfaceNode.strokeColor = Colors.EnacedBlackgroundColor
		surfaceNode.alpha = 0.9
		addChild(surfaceNode)
		
		let inlineNode = SKShapeNode()
		inlineNode.position = CGPointMake(0,0)
		inlineNode.path = CGPathCreateWithRoundedRect(CGRectMake(5,5,frame.width-10, frame.height-10), 5, 5, nil)
		inlineNode.fillColor = Colors.TransparentColor
		inlineNode.strokeColor = Colors.BlackColor
		inlineNode.alpha = 0.2
		inlineNode.glowWidth = 3
		addChild(inlineNode)
	}
}
