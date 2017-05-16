
//
//  PlayerNode.swift
//  Greedy Cats
//
//  Created by David Yuste on 3/23/15.
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

class PlayerNode : SKSpriteNode {
	weak var gameGrid : GameGridNode?
	var labelNode : SKUINiceLabelNode!
	var extraPointsNode : SKUINiceLabelNode!
	var helpNode : SKSpriteNode?
	var gamePosition : UInt32?
	var activePlayer : Bool?
	let animationFrame : CGFloat = 0.03
	var localUser : Bool = false
	var player : Player?
	
	required init?(coder : NSCoder) {
		super.init(coder: coder)
	}
	init (gameGrid : GameGridNode, player : Player) {
		self.player = player
		
		let textureFrames = TextureLoader.Singleton.getCollection(TextureCollections.PlayerIddleAtlas, collectionName: TextureCollections.ActiveToIddleAnimationName)
		let texture = textureFrames![textureFrames!.count - 1]
		super.init(texture: texture,  color: UIColor.clearColor(), size: texture.size())
		self.gameGrid = gameGrid
		setTheme(player.theme)
		
		localUser = player.userId == nil || (SessionManager.Singleton.userId != nil && player.userId! == SessionManager.Singleton.userId!)
	
		labelNode = SKUINiceLabelNode()
		labelNode.text = "\(player.title) (\(player.score))"
		labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
		labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
		labelNode.fontSize = Fonts.DefaultH3FontSize
		labelNode.fontName = Fonts.DefaultH3FontName
		labelNode.fontColor = SKColor.whiteColor()
		labelNode.position = CGPoint(x: 0, y: -23)
		labelNode.zPosition = 2
		self.addChild(labelNode)
		
		extraPointsNode = SKUINiceLabelNode()
		extraPointsNode.text = ""
		extraPointsNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
		extraPointsNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
		extraPointsNode.fontSize = Fonts.DefaultH1FontSize
		extraPointsNode.fontName = Fonts.DefaultH1FontName
		extraPointsNode.fontColor = SKColor.whiteColor()
		extraPointsNode.alpha = 0
		self.addChild(extraPointsNode)
		
		/*
		let r = cellWidth/2.0
		let hrsq3 = r*hsq3
		var points = UnsafeMutablePointer<CGPoint>.alloc(7)
		points[0] = CGPoint(x: 0, y: r/2.0)
		points[1] = CGPoint(x:hrsq3, y:0)
		points[2] = CGPoint(x:2.0*hrsq3, y:r/2.0)
		points[3] = CGPoint(x:2.0*hrsq3, y:r+r/2.0)
		points[4] = CGPoint(x:hrsq3, y:2.0*r)
		points[5] = CGPoint(x:0, y:r+r/2.0)
		points[6] =	CGPoint(x:0, y:r/2.0)
		let baseNode = SKShapeNode(points: points, count: 7)
		baseNode.lineWidth = 2
		baseNode.zPosition = 1
		self.addChild(baseNode)
		
		var points2 = UnsafeMutablePointer<CGPoint>.alloc(7)
		points2[0] = CGPoint(x: -texture.size().width/2, y: -texture.size().height/2)
		points2[1] = CGPoint(x:texture.size().width/2, y: -texture.size().height/2)
		points2[2] = CGPoint(x:texture.size().width/2, y: texture.size().height/2 )
		points2[3] = CGPoint(x:-texture.size().width/2, y: texture.size().height/2)
		points2[4] = CGPoint(x:-texture.size().width/2, y: -texture.size().height/2)
		let baseNode2 = SKShapeNode(points: points2, count: 5)
		baseNode2.lineWidth = 2
		baseNode2.zPosition = 1
		self.addChild(baseNode2)
*/
	}
	
	var score : UInt32 {
		set {
			if labelNode != nil {
				labelNode.text = "\(player!.title) (\(newValue))"
			}
		}
		get {
			return 0
		}
	}
	
	func setTheme(theme : UserTheme) {
		//color = theme.color
		//colorBlendFactor = 0.4
	}
	
	func setActivePlayer(active : Bool) {
		if activePlayer == nil || activePlayer! != active {
			activePlayer = active
			removeAllActions()
			alpha = active ? 1 : 0.75
			labelNode.alpha = active ? 1 : 0.4
			runAction(SKAction.sequence(getIddleAction(active)))
			
			if active && localUser {
				showHelp()
			} else {
				hideHelp()
			}
		}
	}
	
	func setGamePosition(nextPosition : UInt32, extraPoints: UInt32, completion block: (() -> Void)!) -> CGPoint? {
		if gameGrid == nil {
			return nil
		}
		var changedPosition : CGPoint?
		let pos = gameGrid!.pointForGridPosition(gameGrid!.gridPositionForGamePosition(nextPosition))
		if distanceBetween(point: position, andPoint: CGPoint(x: pos.x + cellWidth/2, y: pos.y + cellHeight/2)) > cellWidth/2.0 {
			changedPosition = CGPoint(x: pos.x + cellWidth/2, y: pos.y + cellHeight/2)
		}
		if gamePosition != nil {
			zPosition += CGFloat(gamePosition!)
			labelNode.runAction(SKAction.fadeOutWithDuration(0.25))
			animateTransition(gamePosition!, nextPosition: nextPosition, completion: {
				if extraPoints > 0 {
						self.displayExtraPoints(extraPoints)
				}
				
				self.labelNode.runAction(SKAction.fadeInWithDuration(0.25))
				block()
				self.zPosition -= CGFloat(nextPosition)
				})
			gamePosition = nextPosition
		} else {
			gamePosition = nextPosition
			position = CGPoint(x: pos.x + cellWidth/2, y: pos.y + cellHeight/2)
			block()
			zPosition -= CGFloat(nextPosition)
		}
		
		hideHelp()
		
		return changedPosition
	}
	
	enum PlayerDirection {
		case TopLeft
		case TopRight
		case Right
		case BottomRight
		case BottomLeft
		case Left
		case None
	}
	
	private func displayExtraPoints(extraPoints : UInt32) {
		extraPointsNode.text = "+ \(extraPoints)"
		extraPointsNode.position = CGPoint(x: 0, y: 40)
		extraPointsNode.alpha = 1
		extraPointsNode.runAction(
			SKAction.group([
				SKAction.moveTo(CGPoint(x: 0, y: 280), duration:NSTimeInterval(2)),
				SKAction.fadeAlphaTo(0, duration: NSTimeInterval(2))
				]))
	}
	
	private func animateTransition(currentPosition : UInt32, nextPosition : UInt32, completion block: (() -> Void)!) {
		if gameGrid == nil {
			return
		}
		
		let currentCellPosition = gameGrid!.game!.positionToCellPosition(currentPosition)
		let nextCellPosition = gameGrid!.game!.positionToCellPosition(nextPosition)
		let direction = getPlayerDirectionFromTransition(currentCellPosition, nextCellPosition: nextCellPosition)
		var currentAbsPosition = gameGrid!.pointForGridPosition(gameGrid!.gridPositionForGamePosition(currentPosition))
		currentAbsPosition = CGPoint(x: currentAbsPosition.x + cellWidth/2, y: currentAbsPosition.y + cellHeight/2)
		var nextAbsPosition = gameGrid!.pointForGridPosition(gameGrid!.gridPositionForGamePosition(nextPosition))
		nextAbsPosition = CGPoint(x: nextAbsPosition.x + cellWidth/2, y: nextAbsPosition.y + cellHeight/2)
		
		var beforeNextAbsPosition = CGPoint(x: nextAbsPosition.x, y: nextAbsPosition.y)
		var xF : CGFloat = 0.0, yF : CGFloat = 0.0, fF : CGFloat = 0.8
		switch direction {
		case .TopLeft:
			xF = 0.5
			yF = 0.866
			//fF = 0.75
		case .TopRight:
			xF = -0.5
			yF = 0.866
			//fF = 0.75
		case .BottomLeft:
			xF = 0.5
			yF = -0.866
			//fF = 0.75
		case .BottomRight:
			xF = -0.5
			yF = -0.866
			//fF = 0.75
		case .Left:
			xF = 1
			//fF = 0.75
		case .Right:
			xF = -1
			//fF = 0.75
		default:
			let _ = 0
		}
		
		beforeNextAbsPosition.x += fF * cellWidth * xF
		beforeNextAbsPosition.y += fF * cellHeight * yF
		
		if direction != .None {
			var actions : [SKAction] = []
			actions += getMoveDepartAction(direction)
			actions += getMoveFlyAction(currentAbsPosition, nextAbsPosition: beforeNextAbsPosition)
			actions += getMoveArriveAction(direction, nextAbsPosition: nextAbsPosition)
			//actions += getIddleAction()
			removeAllActions()
			runAction(SKAction.sequence(actions), completion: block)
		} else {
			block()
		}
	}
	
	private func getPlayerDirectionFromTransition(currentCellPosition : CGPoint, nextCellPosition : CGPoint) -> PlayerDirection {
		var hDirection : PlayerDirection
		if currentCellPosition.x < nextCellPosition.x {
			hDirection = .Right
		} else if currentCellPosition.x > nextCellPosition.x {
			hDirection = .Left
		} else {
			hDirection = .None
		}
		
		if currentCellPosition.y < nextCellPosition.y {
			if hDirection == .Left {
				return .BottomLeft
			} else if hDirection == .Right {
				return .BottomRight
			} else if (Int(currentCellPosition.y) % 2) == 0 {
				return .BottomRight
			} else {
				return .BottomLeft
			}
		} else if currentCellPosition.y > nextCellPosition.y {
			if hDirection == .Left {
				return .TopLeft
			} else if hDirection == .Right {
				return .TopRight
			} else if (Int(currentCellPosition.y) % 2) == 0 {
				return .TopRight
			} else {
				return .TopLeft
			}
		} else {
			return hDirection
		}
	}
	
	private func getMoveDepartAction(direction : PlayerDirection) -> [SKAction] {
		var animationName : String
		var atlasName : String
		switch direction {
		case .TopLeft:
			animationName = TextureCollections.DepartTopLeftAnimationName
			atlasName = TextureCollections.PlayerDepartTopLeftAtlas
		case .TopRight:
			animationName = TextureCollections.DepartTopRightAnimationName
			atlasName = TextureCollections.PlayerDepartTopRightAtlas
		case .BottomLeft:
			animationName = TextureCollections.DepartBottomLeftAnimationName
			atlasName = TextureCollections.PlayerDepartBottomLeftAtlas
		case .BottomRight:
			animationName = TextureCollections.DepartBottomRightAnimationName
			atlasName = TextureCollections.PlayerDepartBottomRightAtlas
		case .Left:
			animationName = TextureCollections.DepartLeftAnimationName
			atlasName = TextureCollections.PlayerDepartLeftAtlas
		case .Right:
			animationName = TextureCollections.DepartRightAnimationName
			atlasName = TextureCollections.PlayerDepartRightAtlas
		default:
			Logger.Warn("PlayerNode::getMoveDepartAction: Unexpected direction")
			return []
		}
		let textureFrames = TextureLoader.Singleton.getCollection(atlasName, collectionName: animationName)
		
		let depart = SKAction.animateWithTextures(textureFrames!,
			timePerFrame: NSTimeInterval(animationFrame),
			resize: false,
			restore: false)
		
		let meowSound = SKAction.playSoundFileNamed("cat_meow.wav", waitForCompletion: false)
		return [SKAction.group([meowSound,depart])]
	}
	
	private func getMoveArriveAction(direction : PlayerDirection, nextAbsPosition : CGPoint) -> [SKAction] {
		var animationName : String
		var atlasName : String
		switch direction {
		case .TopLeft:
			animationName = TextureCollections.ArriveTopLeftAnimationName
			atlasName = TextureCollections.PlayerArriveTopLeftAtlas
		case .TopRight:
			animationName = TextureCollections.ArriveTopRightAnimationName
			atlasName = TextureCollections.PlayerArriveTopRightAtlas
		case .BottomLeft:
			animationName = TextureCollections.ArriveBottomLeftAnimationName
			atlasName = TextureCollections.PlayerArriveBottomLeftAtlas
		case .BottomRight:
			animationName = TextureCollections.ArriveBottomRightAnimationName
			atlasName = TextureCollections.PlayerArriveBottomRightAtlas
		case .Left:
			animationName = TextureCollections.ArriveLeftAnimationName
			atlasName = TextureCollections.PlayerArriveLeftAtlas
		case .Right:
			animationName = TextureCollections.ArriveRightAnimationName
			atlasName = TextureCollections.PlayerArriveRightAtlas
		default:
			return []
		}
		let textureFrames = TextureLoader.Singleton.getCollection(atlasName, collectionName: animationName)
		
		let arrive = SKAction.animateWithTextures(textureFrames!,
			timePerFrame: NSTimeInterval(animationFrame),
			resize: false,
			restore: false)
		let move = SKAction.moveTo(nextAbsPosition, duration:0.0)
		return [SKAction.group([arrive, move]),
				SKAction.waitForDuration(0.5)];
	}
	
	private func getMoveFlyAction(currentAbsPosition : CGPoint, nextAbsPosition : CGPoint) -> [SKAction] {
		let x = nextAbsPosition.x - currentAbsPosition.x
		let y = nextAbsPosition.y - currentAbsPosition.y
		let distance = CGFloat(hypotf(Float(x), Float(y)))
		let duration = distance * animationFrame / 10.0
		if duration < animationFrame {
			return []
		}
		return [SKAction.moveTo(nextAbsPosition, duration:NSTimeInterval(duration))]
	}
	
	private func getIddleAction(active : Bool) -> [SKAction] {
		var textureFrames = TextureLoader.Singleton.getCollection(TextureCollections.PlayerIddleAtlas, collectionName: TextureCollections.ActiveToIddleAnimationName)
		if active {
			textureFrames = Array(textureFrames!.reverse())
		}
		
		let transition = SKAction.animateWithTextures(textureFrames!,
			timePerFrame: NSTimeInterval(animationFrame),
			resize: false,
			restore: false)
		var anim : [SKAction]
		if active {
			let activeCollection = TextureLoader.Singleton.getCollection(TextureCollections.PlayerIddleAtlas, collectionName: TextureCollections.ActiveAnim01AnimationName)!
			let activeAnim = SKAction.animateWithTextures(
				activeCollection,
				timePerFrame:0.06, resize: true, restore: false)
			if localUser {
				let longMeowSound = SKAction.playSoundFileNamed("cat_long_meow.mp3", waitForCompletion: false)
			
				anim = [transition,
					SKAction.repeatActionForever(
						SKAction.sequence([
							SKAction.waitForDuration(2, withRange: 5),
							activeAnim,
							SKAction.waitForDuration(2, withRange: 5),
							activeAnim,
							SKAction.waitForDuration(5, withRange: 5),
							SKAction.group([longMeowSound,activeAnim])
							]))]
			} else {
				anim = [transition,
					SKAction.repeatActionForever(
						SKAction.sequence([
							SKAction.waitForDuration(2, withRange: 5),
							activeAnim
							]))]
			}
		} else {
			anim = [transition]
		}
		return anim;
	}
	
	func showHelp() {
		if helpNode == nil {
			let animFrames = TextureLoader.Singleton.getCollection(TextureCollections.LeafAtlas, collectionName: TextureCollections.LeafHelpAnimationName)
			let texture = animFrames![animFrames!.count - 1]
			
			helpNode = SKSpriteNode()
			helpNode!.position = CGPointMake(0,0)//size.width/2, size.height/2)
			helpNode!.size = CGSizeMake(texture.size().width, texture.size().height)
			self.addChild(helpNode!)
			
			let helpAnim = SKAction.animateWithTextures(
				animFrames!,
				timePerFrame:0.08, resize: true, restore: false)
			let seqAnim = SKAction.sequence([
				SKAction.waitForDuration(10),
					SKAction.group([helpAnim,
						SKAction.fadeAlphaTo(1, duration: NSTimeInterval(0.6))]),
					SKAction.waitForDuration(0.5),
					helpAnim,
					SKAction.waitForDuration(0.5),
					SKAction.group([helpAnim,
						SKAction.fadeAlphaTo(0, duration: NSTimeInterval(0.6))])
				])
			
			helpNode!.runAction(seqAnim)
		}
	}
	
	func hideHelp() {
		if helpNode != nil {
			helpNode!.removeAllActions()
			helpNode!.removeFromParent()
			helpNode = nil
		}
	}
}
