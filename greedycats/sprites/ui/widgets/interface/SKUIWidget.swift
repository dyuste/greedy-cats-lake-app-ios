//
//  SKUIWidget.swift
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

class SKUIWidget : SKUILayer {
	var tapHandler : ((target : SKUIWidget) -> Void)?
	
	//MARK: ---
	//MARK: Sizing
	var size : CGSize {
		get {
			if _storedSize != nil {
				return _storedSize!
			} else {
				_storedSize = sizeForContent()
				return _storedSize!
			}
			
		}
	}
	private var _storedSize : CGSize?
	
	override init() {
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func invalidateSize() {
		_storedSize = nil
	}
	
	func sizeForContent() -> CGSize {
		var width : CGFloat = 0
		var height : CGFloat = 0
		for child in childWidgets {
			let childSize = child.size
			let childPosition = child.position
			let childRight : CGFloat = childPosition.x + childSize.width
			let childBottom : CGFloat = childPosition.y + childSize.height
			width = width < childRight ? childRight : width
			height = height < childBottom ? childBottom : height
		}
		return CGSizeMake(width, height)
	}
	
	
	//MARK: ---
	//MARK: Content node
	var contentNode : SKNode?
	
	func widgetCreateSubWidgets() {
		
	}
	
	func widgetCreateContent() -> SKNode {
		return SKNode()
	}
	
	func widgetKickOff() {
		
	}
	
	func nodeForChildWidget(widget : SKUIWidget) -> SKNode! {
		return contentNode!
	}
	
	func create() {
		widgetCreateSubWidgets()
		
		for child in childWidgets {
			child.create()
		}
		contentNode = widgetCreateContent()
		for child in childWidgets {
			let hook = nodeForChildWidget(child)
			child.attach(hook)
		}
		if contentNode != nil {
			addChild(contentNode!)
		}
		widgetKickOff()
	}
	
	func attach(node : SKNode) {
		node.addChild(self)//contentNode!)
	}
	
	func detach() {
		for child in childWidgets {
			child.detach()
		}
		/*contentNode?.*/removeFromParent()
		//contentNode = nil
	}
	
	//MARK: ---
	//MARK: Components
	var childWidgets : [SKUIWidget] = []
	
	func addChildWidget(widget : SKUIWidget) {
		childWidgets.append(widget)
	}

}
