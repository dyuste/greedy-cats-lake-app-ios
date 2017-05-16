//
//  SKUIDialog.swift
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

class SKUIDialog : SKUIWindowLayer {
	var titleText : String?
	var bodyText : String?
	var subWidget : SKUIWidget?
	var dismissButtonText : String?
	var dismissHandler : ((Void) -> Void)?
	
	override func presentInLayer(layer : SKUILayer, withFrame : CGRect?) {
		if subWidget != nil {
			subWidget!.create()
			subWidget!.position = CGPointMake(10, 10)
		}
		super.presentInLayer(layer, withFrame: withFrame)
	}
	
	override func createLayer(frame : CGRect) {
		super.createLayer(frame)
		
		if dismissButtonText == nil {
			dismissButtonText = NSLocalizedString("Ok", comment: "")
		}
		let dismissButton = SKUIButtonNode(title: dismissButtonText!)
		dismissButton.tapHandler = onDismissButton
		dismissButton.position = CGPointMake(frame.width/2, 60)
		addChild(dismissButton)
		
		let contentNode = SKNode()
		contentNode.position = CGPointMake(10, 100)
		createContent(contentNode, frame: CGRectMake(0, 0, frame.width - 20, frame.height - 80))
		addChild(contentNode)
	}
	
	func createContent(contentNode : SKNode, frame : CGRect) {
		if titleText == nil {
			titleText = ""
		}
		
		let titleNode = SKUINiceLabelNode()
		titleNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
		titleNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
		titleNode.fontName = Fonts.DefaultH1FontName
		titleNode.fontSize = Fonts.DefaultH1FontSize
		titleNode.fontColor = SKColor.whiteColor()
		titleNode.position = CGPointMake(frame.width/2,frame.height - 60)
		titleNode.text = titleText!
		contentNode.addChild(titleNode)
		
		if bodyText == nil {
			bodyText = ""
		}
		let bodyTextNode = SKUINiceLabelNode()
		bodyTextNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
		bodyTextNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
		bodyTextNode.fontName = Fonts.DefaultH2FontName
		bodyTextNode.fontSize = Fonts.DefaultH2FontSize
		bodyTextNode.fontColor = SKColor.whiteColor()
		if subWidget != nil {
			bodyTextNode.position = CGPointMake(frame.width/2,frame.height - 120)
		} else {
			bodyTextNode.position = CGPointMake(frame.width/2,frame.height/2)
		}
		bodyTextNode.text = bodyText!
		contentNode.addChild(bodyTextNode)
		
		subWidget?.attach(contentNode)
	}
	
	override func getFrameForLayer(layer : SKUILayer) -> CGRect {
		
		let titleSize: CGSize = titleText != nil ? titleText!.sizeWithAttributes([NSFontAttributeName: Fonts.DefaultH1Font!]) : CGSizeMake(0,0)
		let bodySize: CGSize = bodyText != nil ? bodyText!.sizeWithAttributes([NSFontAttributeName: Fonts.DefaultH2Font!]) : CGSizeMake(0,0)
		let minWidth = (titleSize.width < bodySize.width ? bodySize.width : titleSize.width) + 110
		let minHeight = 2 * (bodySize.height + titleSize.height + 60) + (subWidget != nil ? subWidget!.size.height : 0)
		
		let bounds = layer.bounds
		let origin = bounds.origin
		return CGRectMake(origin.x + (bounds.width - minWidth)/2, origin.y + (bounds.height - minHeight)/2,
			minWidth, minHeight)
	}
	
	private func onDismissButton(target : SKUIWidget) {
		dismiss()
		dismissHandler?()
	}
}
