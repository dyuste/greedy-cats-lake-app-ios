//
//  GridNodeScene.swift
//  Greedy Cats
//
//  Created by David Yuste on 3/4/15.
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

class SKUIScene : SKScene {
	
	required init?(coder : NSCoder) {
		super.init(coder: coder)
		createScene()
	}
	
	override init (size: CGSize) {
		super.init(size: size)
		createScene()
	}
	
	private func createScene() {
		initLayers()
		sceneInit()
		sceneCreateBackground()
		sceneCreateWidgets()
		for (widget, _) in self.widgets {
			widget.create()
		}
		for (widget, layer) in self.widgets {
			if widget.contentNode != nil {
				layer.addChild(widget.contentNode!)
			}
		}
		sceneCreateContent()
	}
	
	override func didMoveToView(view : SKView) {
		setupGestureRecognizers(view)
		scenePlayMusic()
	}
	
	// MARK: ---
	// MARK: Handlers to override
	func sceneInit() {
	}
	
	func sceneCleanUp() {
		layers = []
		self.removeAllChildren()
	}
	
	func scenePlayMusic() {

	}
	
	func sceneCreateBackground() {
		
	}
	
	func sceneCreateWidgets() {
		
	}
	func sceneCreateContent() {
		
	}
	
	// MARK: ---
	// MARK: Widgets
	var widgets : [(widget:SKUIWidget, layer:SKUILayer)] = []
	
	func addWidgetAtLayer(widget : SKUIWidget, layer : SKUILayer) {
		widgets.append(widget: widget, layer: layer)
	}
	
	// MARK ---
	// MARK: General helpers
	func alertDialog(title: String, bodyText: String, dismissText: String, dismissHandler : ((Void) -> (Void))?) {
		let dialog = SKUIDialog()
		dialog.titleText = title
		dialog.bodyText = bodyText
		dialog.dismissButtonText = dismissText
		dialog.dismissHandler = dismissHandler
		dialog.presentInLayer(getUILayer(), withFrame: nil)
	}
	
	func alertDialogWithSubView(title: String, bodyText: String, subWidget: SKUIWidget, dismissText: String, dismissHandler : ((Void) -> (Void))?) {
		let dialog = SKUIDialog()
		dialog.titleText = title
		dialog.bodyText = bodyText
		dialog.dismissButtonText = dismissText
		dialog.dismissHandler = dismissHandler
		dialog.subWidget = subWidget
		dialog.presentInLayer(getUILayer(), withFrame: nil)
	}
	
	func overlayText(text : String, withSize : CGSize, during: Double?) -> SKUITextOverlayLayer {
		let overlay = SKUITextOverlayLayer()
		overlay.text = text
		overlay.presentInLayer(getUILayer(), withSize : withSize, during: during)
		return overlay
	}
	
	// MARK: ---
	// MARK: Layers
	private var layers : [SKUILayer] = []
	
	enum SKUISceneLayerType {
		case Background
		case UI
	}
	
	private func initLayers() {
		layers = [SKUILayer(), SKUILayer()]
		layers[0].zPosition = 1
		layers[0].name = "BackgroundLayer"
		addChild(layers[0])
		layers[1].zPosition = 10000000
		layers[1].name = "UILayer"
		addChild(layers[1])
	}
	
	func getBackgroundLayer() -> SKUILayer {
			return layers[0]
	}
	
	func getUILayer() -> SKUILayer {
		return layers[1]
	}
	
	func addChildAtLayer(node : SKUILayer, type : SKUISceneLayerType) {
		switch type {
		case .Background:
			layers[0].addChild(node)
		case .UI:
			layers[1].addChild(node)
		}
	}
	
	// MARK: ---
	// MARK: Touch events
	private var lastTranslation : CGPoint?
	private var activeLayer : SKUILayer?
	private var activeNode : SKNode?
	
	private func setupGestureRecognizers(view : SKView) {
		let panRecognizer = UIPanGestureRecognizer(target:self, action:"detectPan:")
		view.addGestureRecognizer(panRecognizer)
		let tapRecognizer = UITapGestureRecognizer(target:self, action:"detectTap:")
		view.addGestureRecognizer(tapRecognizer)
		let pinchRecognizer = UIPinchGestureRecognizer(target:self, action:"detectPinch:")
		view.addGestureRecognizer(pinchRecognizer)
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesBegan(touches, withEvent: event)
		if touches.count <= 0 {
			return
		}
		
		let touch:UITouch = touches.first!
		let positionInScene = touch.locationInNode(self)
		let touchedNodes = self.scene?.nodesAtPoint(positionInScene)
		var touchedNode : SKUILayer?
		
		for anyTouchedNode in touchedNodes! {
			if anyTouchedNode is SKUILayer {
				touchedNode = anyTouchedNode as? SKUILayer
				break
			}
		}
		
		activeNode = nil
		activeLayer = nil
		if touchedNode != nil {
			for layerCollectionIndex in 0..<layers.count {
				let layerCollection = layers[layerCollectionIndex]
				for layerIndex in 0..<layerCollection.children.count {
					if let layer = layerCollection.children[layerIndex] as? SKUILayer {
						if touchedNode!.inParentHierarchy(layer) || touchedNode === layer {
							activeLayer = layer
							activeNode = touchedNode
							break;
						}
					}
				}
				if activeLayer != nil {
					break
				}
			}
		}
		lastTranslation = nil
	}
	
	func detectPan(recognizer:UIPanGestureRecognizer) {
		if activeLayer != nil {
			let translation  = recognizer.translationInView(self.view!)
			var delta : CGPoint = CGPoint(x: -translation.x, y: translation.y)
			if lastTranslation != nil {
				delta = CGPoint(x: delta.x + lastTranslation!.x, y: delta.y - lastTranslation!.y)
			}
			lastTranslation = translation
		
			activeLayer!.panHandler(activeLayer!, node: activeNode!, delta: delta)
		}
	}
	
	func detectPinch(recognizer:UIPinchGestureRecognizer) {
		if activeLayer != nil {
			recognizer.scale = activeLayer!.pinchHandler(activeLayer!, node: activeNode!, state: recognizer.state, scale: recognizer.scale)
		}
	}
	
	func detectTap(recognizer:UITapGestureRecognizer) {
		if activeLayer != nil {
			let touchPoint = recognizer.locationOfTouch(0,inView: self.view)
			activeLayer!.tapHandler(activeLayer!, node: activeNode!, point: touchPoint)
		}
	}
}
