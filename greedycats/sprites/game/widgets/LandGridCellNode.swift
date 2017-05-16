//
//  LandGridCellNode.swift
//  Greedy Cats
//
//  Created by David Yuste on 3/11/15.
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

class LandGridCellNode : GridCellNode {
	// Textures
	private var LeafAtlas : String = "Leaf"
	private var LeafAnimationName : String = "Leaf"
	private var LeafDieAnimationName : String = "LeafDie"
	
	private var Leaf2pxAtlas : String = "Leaf2px"
	private var Leaf2pxAnimationName : String = "Leaf2px"
	private var Leaf2pxDieAnimationName : String = "Leaf2xDie"
	
	private var BirdsAtlas : String = "Birds"
	private var BirdGoAnimationName : [String] = ["Bird01Go", "Bird02Go", "Bird03Go"]
	private var BirdBackAnimationName : [String] = ["Bird01Back", "Bird02Back", "Bird03Back"]
	private var BirdDieAnimationName : String = "BirdDie"
	
	var landNode : SKSpriteNode?
	var resourcesNode : SKSpriteNode?
	var cell : Cell?
	var cellState : UInt32 = 0
	
	required init? (coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override init(cellType : String)  {
		super.init(cellType: cellType)
		
		/*var points = UnsafeMutablePointer<CGPoint>.alloc(7)
		points[0] = CGPoint(x: 0, y: r/2.0*heightAspect)
		points[1] = CGPoint(x:hexHalfHeight, y:0)
		points[2] = CGPoint(x:2.0*hexHalfHeight, y:r/2.0*heightAspect)
		points[3] = CGPoint(x:2.0*hexHalfHeight, y:(r+r/2.0)*heightAspect)
		points[4] = CGPoint(x:hexHalfHeight, y:2.0*r*heightAspect)
		points[5] = CGPoint(x:0, y:(r+r/2.0)*heightAspect)
		points[6] =	CGPoint(x:0, y:r/2.0*heightAspect)
		let baseNode = SKShapeNode(points: points, count: 7)
		baseNode.lineWidth = 2
		baseNode.zPosition = 1
		self.addChild(baseNode)*/
	}
		
	func setGameCell(cell : Cell, game: Game) {
		if self.cell != nil {
			if resourcesNode != nil {
				if cell.state == 0 || self.cell!.resources != cell.resources || cell.playerId != nil {
					removeResourcesNode()
				}
			}
			if landNode != nil {
				if cell.state == 0  {
					removeLandNode()
				}
			}
		}
		
		if cell.state > 0 {
			if landNode == nil {
				addLandNode(cell)
			} else if cell.state == 1 && cellState == 2 {
				downgradeLandNode(cell)
			}
			if cell.playerId == nil && resourcesNode == nil {
				addResourcesNodeForPlayer(cell.resources)
			}
		}
		self.cell = cell
		self.cellState = cell.state
	}
	
	func addLandNode(cell : Cell) {
		var textureFrames : [SKTexture]?
		if cell.state == 1 {
			textureFrames = TextureLoader.Singleton.getCollection(LeafAtlas, collectionName: LeafAnimationName)
		} else {
			textureFrames = TextureLoader.Singleton.getCollection(Leaf2pxAtlas, collectionName: Leaf2pxAnimationName)
		}
		landNode = SKSpriteNode(texture: textureFrames![0])
		landNode!.zPosition = 1
		landNode!.position = CGPoint(x: cellWidth/2, y: cellHeight/2)
		self.addChild(landNode!)
	}
	
	func downgradeLandNode(cell : Cell) {
		let dieFrames = TextureLoader.Singleton.getCollection(Leaf2pxAtlas, collectionName: Leaf2pxDieAnimationName)
		
		if landNode != nil {
			landNode!.runAction(
				SKAction.animateWithTextures(dieFrames!, timePerFrame:0.06, resize: true, restore: false),
				completion: {
					let textureFrames = TextureLoader.Singleton.getCollection(
						self.LeafAtlas, collectionName: self.LeafAnimationName)
					self.landNode?.texture = textureFrames![0]
			})
		}
	}
	
	func removeLandNode() {
		let dieFrames = TextureLoader.Singleton.getCollection(LeafAtlas, collectionName: LeafDieAnimationName)
		if landNode != nil {
			landNode!.runAction(SKAction.group([
				SKAction.animateWithTextures(dieFrames!,
					timePerFrame:0.06, resize: true, restore: false),
				SKAction.sequence(
					[SKAction.waitForDuration(NSTimeInterval(0.8)),
						SKAction.fadeAlphaTo(0, duration: NSTimeInterval(0.5))
					])
				]),
				completion: {
					if self.landNode != nil {
						self.landNode!.removeFromParent()
						self.landNode = nil
					}
			})
		}
	}
	
	func removeResourcesNode() {
		let dieFrames = TextureLoader.Singleton.getCollection(BirdsAtlas, collectionName: BirdDieAnimationName)
		
		resourcesNode!.runAction(SKAction.group([
			SKAction.animateWithTextures(dieFrames!, timePerFrame:0.06, resize: true, restore: false),
			SKAction.sequence(
				[SKAction.waitForDuration(NSTimeInterval(0.25)),
				 SKAction.fadeAlphaTo(0, duration: NSTimeInterval(0.6))
				 ])
			]),
			completion: {
				self.resourcesNode!.removeFromParent()
				self.resourcesNode = nil
		})
	}
	
	func addResourcesNodeForPlayer(resources : UInt32) {
		if resources > 0 && resources < 4 {
			
			let goFrames = TextureLoader.Singleton.getCollection(BirdsAtlas, collectionName: BirdGoAnimationName[Int(resources - 1)])
			let backFrames = TextureLoader.Singleton.getCollection(BirdsAtlas, collectionName: BirdBackAnimationName[Int(resources - 1)])
			
			resourcesNode = SKSpriteNode(texture: goFrames![0])
			resourcesNode!.position = CGPoint(x: cellWidth/2, y: cellHeight/2)
			resourcesNode!.zPosition = 10
			addChild(resourcesNode!)
			resourcesNode!.runAction(
				SKAction.repeatActionForever(
					SKAction.sequence([
						SKAction.waitForDuration(5, withRange: 35),
						SKAction.animateWithTextures(goFrames!, timePerFrame:0.06, resize: true, restore: false),
						SKAction.waitForDuration(5, withRange: 35),
						SKAction.animateWithTextures(backFrames!, timePerFrame:0.06, resize: true, restore: false)
						]
					)
				)
			)
		}
	}
}
