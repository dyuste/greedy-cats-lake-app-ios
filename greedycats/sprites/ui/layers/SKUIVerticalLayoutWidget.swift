//
//  SKUIVerticalLayoutWidget.swift
//  greedycats
//
//  Created by David Yuste on 1/2/16.
//  Copyright (c) 2016 yucode. All rights reserved.
//

import Foundation
import SpriteKit

class SKUIVerticalLayoutWidget : SKUIWidget
{
	private var verticalOffset : CGFloat = 0
	
	override func addChildWidget(widget: SKUIWidget) {
		super.addChildWidget(widget)
		widget.position.y = verticalOffset
		verticalOffset += widget.size.height
	}
}
