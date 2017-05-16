//
//  GameScene.swift
//  Greedy Cats
//
//  Created by David Yuste on 3/3/15.
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

class LoadingScene : SKUIScene {
	required init?(coder : NSCoder) {
		super.init(coder: coder)
	}
	
	override init (size: CGSize) {
		super.init(size: size)
	}
	
	override func sceneInit() {
		self.backgroundColor = Colors.EnacedBlackgroundColor
	}
	
	override func sceneCreateBackground() {
		setWaterBackground()
	}
	
	override func sceneCreateContent() {
		let overlay = SKUITextOverlayLayer()
		overlay.text = NSLocalizedString("Loading...", comment: "")
		overlay.presentInLayer(getUILayer(),
			withSize : size,
			during: nil)
	}
	
	override func didChangeSize(oldsize: CGSize) {
		if let shaderContainer = self.shaderContainer {
			shaderContainer.position = CGPointMake(size.width/2, size.height/2)
			shaderContainer.size = CGSizeMake(size.width, size.height)
			waterShader?.uniformNamed("u_fixed_size")?.floatVector2Value = GLKVector2Make(
				Float(shaderContainer.calculateAccumulatedFrame().size.width),
				Float(shaderContainer.calculateAccumulatedFrame().size.height))
		}
	}
	
	//
	// MARK: Water Background
	
	var shaderContainer : SKSpriteNode?
	var waterShader : SKShader?
	var waterShaderOffset : GLKVector2 = GLKVector2Make(Float(0), Float(0))
	
	func setWaterBackground() {
			let sandTexture = SKTexture(imageNamed:"Sand")
			let shaderContainer = SKSpriteNode(texture : sandTexture)
			shaderContainer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
			shaderContainer.size = CGSizeMake(self.frame.size.width, self.frame.size.height)
			shaderContainer.zPosition = 0
			
			let waterShader = SKShader(fileNamed:"water.fsh")
			waterShader.uniforms = [
				SKUniform(name:"u_point_size", float: Float(2.0)),
				SKUniform(name:"u_scale", float: Float(self.xScale)),
				SKUniform(name:"u_offset", floatVector2:self.waterShaderOffset),
				SKUniform(name:"u_texture_size", float:Float(sandTexture.size().width)),
				SKUniform(name:"u_fixed_size", floatVector2:GLKVector2Make(
					Float(shaderContainer.calculateAccumulatedFrame().size.width),
					Float(shaderContainer.calculateAccumulatedFrame().size.height)))
			]
		
			shaderContainer.shader = waterShader
			self.shaderContainer = shaderContainer
			self.waterShader = waterShader
			self.getBackgroundLayer().addChild(shaderContainer)
	}
}
