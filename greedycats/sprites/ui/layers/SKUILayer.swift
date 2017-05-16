//
//  SKUILayer.swift
//  greedycats
//
//  Created by David Yuste on 9/5/15.
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

class SKUILayer : SKNode {
	override init () {
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	var bounds : CGRect  {
		get {
			return scene != nil ? scene!.frame : CGRectMake(0,0,0,0)
		}
	}
	
	// --- MARK: Gesture events
	func tapHandler(layer : SKUILayer, node: SKNode, point : CGPoint) -> Void {
		var widgetNode : SKNode? = node
		while (widgetNode != nil && !(widgetNode! is SKUIWidget)) {
			widgetNode = widgetNode!.parent
		}
		if widgetNode != nil {
			let widget = widgetNode as! SKUIWidget
			widget.tapHandler?(target: widget)
		}
	}
	
	func panHandler(layer : SKUILayer, node: SKNode, delta : CGPoint) -> Void {
	}
	
	func pinchHandler(layer : SKUILayer, node: SKNode, state : UIGestureRecognizerState, scale : CGFloat) -> CGFloat {
		return scale
	}
}
