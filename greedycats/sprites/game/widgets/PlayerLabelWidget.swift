//
//  PlayerNode.swift
//  Greedy Cats
//
//  Created by David Yuste on 20/9/15.
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

class PlayerLabelWidget : SKUIWidget {
	let MaxScoreForTexture : CGFloat = 120.0
	let MaxScoreTexture :CGFloat = 50.0
	
	init(player : Player)  {
		self.player = player
		super.init()
	}
	
	required init? (coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func widgetCreateContent() -> SKNode {
		let node = SKNode()
		
		let userNameLabel = SKLabelNode(fontNamed: Fonts.DefaultH2FontName)
		userNameLabel.text = ""
		userNameLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
		userNameLabel.fontSize = Fonts.DefaultH2FontSize
		userNameLabel.fontColor = SKColor.whiteColor()
		userNameLabel.position = CGPoint(x: 95, y:  self.size.height * 0.25)
		userNameLabel.zPosition = 20
		node.addChild(userNameLabel)
		self.userNameLabel = userNameLabel
		
		let textureFrames = TextureLoader.Singleton.getCollection(TextureCollections.PointsAtlas, collectionName: TextureCollections.PointsAnimationName)
		
		let pointsNode = SKSpriteNode(texture: textureFrames![0])
		pointsNode.zPosition = 15
		pointsNode.position = CGPoint(x: 42, y:  self.size.height * 0.5 + 8)
		node.addChild(pointsNode)
		self.pointsNode = pointsNode
		
		let scoreLabel = SKLabelNode(fontNamed: Fonts.DefaultH3FontName)
		scoreLabel.text = ""
		scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
		scoreLabel.fontSize = Fonts.DefaultH3FontSize
		scoreLabel.fontColor = SKColor(red: 0.95, green: 0.9, blue: 0.75, alpha: 1)
		scoreLabel.position = CGPoint(x: 0, y:  -21)
		scoreLabel.zPosition = 1
		pointsNode.addChild(scoreLabel)
		self.scoreLabel = scoreLabel
		
		self.setPlayer(player)
		
		return node
	}
	
	func setPlayer(player : Player)  {
		let formerScore = (self.player != nil ? self.player.score : player.score)
		self.player = player
		userNameLabel?.text = player.title
		if scoreLabel != nil {
			setScoreTo(player.score, fromScore: formerScore)
		}
	}
	
	func setScoreTo(score: UInt32, fromScore: UInt32) {
		scoreLabel.text = "\(score)"
		let normalScore = (CGFloat(score) < MaxScoreForTexture) ? CGFloat(score)/MaxScoreForTexture : 1.0
		let scoreTexture = Int(MaxScoreTexture * normalScore)
		pointsNode.texture = TextureLoader.Singleton.getCollection(TextureCollections.PointsAtlas, collectionName: TextureCollections.PointsAnimationName)![scoreTexture]
		if fromScore != score {
			let difference = score - fromScore
			let angle : CGFloat = difference > 5 ? (difference > 12 ? 0.4 : 0.3) : 0.2
			pointsNode.runAction(SKAction.sequence(
				[SKAction.rotateToAngle(-angle, duration: NSTimeInterval(0.06)),
					SKAction.rotateToAngle(angle, duration: NSTimeInterval(0.12)),
					SKAction.rotateToAngle(-angle, duration: NSTimeInterval(0.12)),
					SKAction.rotateToAngle(0, duration: NSTimeInterval(0.06))]
				))
		}
	}

	override func sizeForContent() -> CGSize {
		return CGSize(width: 80, height: 50)
	}
	
	weak var userNameLabel : SKLabelNode!
	weak var scoreLabel : SKLabelNode!
	weak var pointsNode : SKSpriteNode!
	var player : Player!
}
