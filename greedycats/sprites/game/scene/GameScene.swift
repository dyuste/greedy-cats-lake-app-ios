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

protocol GameSceneDelegate : class {
	func gameCellClicked(cellPosition : CGPoint)
	func gameFinished()
}

class GameScene : SKUIScene, GridNodeEventsDelegate {
	var gridNode : GridNode?
	weak var gameSceneDelegate : GameSceneDelegate?
	var game : Game!
	
	required init?(coder : NSCoder) {
		super.init(coder: coder)
	}
	
	init (size: CGSize, game : Game) {
		self.game = game
		super.init(size: size)
	}
	
	
	override func sceneInit() {
		self.backgroundColor = Colors.EnacedBlackgroundColor
	}
	
	override func sceneCleanUp() {
		super.sceneCleanUp()
		gameSceneDelegate = nil
		game = nil
		removeAllActions()
		removeAllChildren()
		SoundManager.Singleton.stopMusic()
		waterShader = nil
		gridNode = nil
	}
	
	override func scenePlayMusic() {
		// former: https://www.freesound.org/people/afleetingspeck/sounds/166748/
		// https://freesound.org/people/zagi2/sounds/216624/
		let backgroundMusicFileName = "game_music.m4a"

		SoundManager.Singleton.startMusic(backgroundMusicFileName)
	}
		
	override func sceneCreateBackground() {
		setWaterBackground()
	}
	
	override func sceneCreateWidgets() {
		gridNode = GameGridNode()
		gridNode!.size = size
		gridNode!.eventsDelegate = self
		addChildAtLayer(gridNode!, type: SKUISceneLayerType.Background)
	}
	
	override func didChangeSize(oldsize: CGSize) {
		gridNode?.size = size
		gridNode?.updateLayout()
		
		if let shaderContainer = self.shaderContainer {
			shaderContainer.position = CGPointMake(size.width/2, size.height/2)
			shaderContainer.size = CGSizeMake(size.width, size.height)
			waterShader?.uniformNamed("u_fixed_size")?.floatVector2Value = GLKVector2Make(
				Float(shaderContainer.calculateAccumulatedFrame().size.width),
				Float(shaderContainer.calculateAccumulatedFrame().size.height))
		}
	}
	
	func setGame(game : Game) {
		self.game = game
			
		if game.finished {
			gameFinished(game)
		}
		
		// Reset game grid
		if let gameGrid = gridNode as! GameGridNode? {
			gameGrid.setGame(game)
		}
	}
	
	private func gameFinished(game : Game) {
		let winner = game.getWinnerUser()
		var winnerTitle : String = ""
		if winner != nil {
			winnerTitle = winner!.getTitle()
		}
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64(NSEC_PER_SEC) * 2)), dispatch_get_main_queue(), {
			
			let playerList = PlayersSummaryListWidget(game: game)
			self.alertDialogWithSubView(NSLocalizedString("Game finished!", comment: ""),
				bodyText: winnerTitle + NSLocalizedString(" wins", comment: ""),
				subWidget: playerList,
				dismissText: NSLocalizedString("continue", comment: ""),
				dismissHandler: {
					SoundManager.Singleton.stopMusic()
					self.gameSceneDelegate?.gameFinished()
			})
		})
	}
	
	// --
	//  MARK: Grid Node Events Delegate
	func gridCellClicked(cellPosition : CGPoint) {
		if game != nil {
			let gamePosition = CGPoint(x: cellPosition.x - CGFloat(gameBorderCells), y: cellPosition.y - CGFloat(gameBorderCells))
			if gamePosition.x >= 0 && gamePosition.x < CGFloat(game!.width)
				&& gamePosition.y >= 0 && gamePosition.y < CGFloat(game!.height) {
					gameSceneDelegate?.gameCellClicked(gamePosition)
			}
		}
	}
	
	func gridScrolled(delta : CGPoint) {
		waterShader?.uniformNamed("u_offset")?.floatVector2Value = GLKVector2Make(
			Float(delta.x),
			Float(delta.y))
		//Logger.Info("Scrolled \(delta.x) - \(delta.y)")
	}
	
	func gridScaled(scale : CGFloat) {
		waterShader?.uniformNamed("u_scale")?.floatValue = Float(scale)
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
		self.getBackgroundLayer().addChild(self.shaderContainer!)
	}
}
