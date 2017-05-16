//
//  GameGridNode.swift
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
import UIKit
import GLKit
import SpriteKit

let r : CGFloat = 65.0
let sq3 : CGFloat = sqrt(3.0)
let hsq3 : CGFloat = sqrt(3.0)/2.0
let hexHalfHeight : CGFloat = r*hsq3
let heightAspect : CGFloat = 0.70710678
let cellWidth : CGFloat = 2*hexHalfHeight
let cellHeight : CGFloat = 2*r*heightAspect

let gameBorderCells : Int = 2

class GameGridNode : GridNode, GridNodeTopologyDelegate {
	var game: Game?
	var playerNodes : [PlayerNode] = []
	var playerTransitionsOnGoing : Int = 0
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		topologyDelegate = self
		
		setOffset(CGPoint(x: -(2*r), y: -(2*r)))
	}
	
	override init() {
		super.init()
		topologyDelegate = self
		
		setOffset(CGPoint(x: -(2*r), y: -(2*r)))
	}
	
	/** REMOVED
	override func clear() {
		super.clear()
		game = nil
		playerNodes = []
	} */
	
	func setGame(game : Game) {
		if self.game == nil || self.game!.id != game.id || self.game!.cells.count != game.cells.count {
			let formerPlayers = self.game?.players
			self.game = game
			reset()
			for playerNode in playerNodes {
				playerNode.removeFromParent()
			}
			for player in game.players {
				let playerNode = PlayerNode(gameGrid: self, player : player)
				playerNode.zPosition = CGFloat(game.width * game.height) + 100
				rootNode.addChild(playerNode)
				playerNodes.append(playerNode)
			}
			updatePlayerNodes(formerPlayers)
			scrollTo(0, y: 0)
		} else {
			for pos in 0..<self.game!.cells.count {
				let oldCell = self.game!.cells[pos]
				let newCell = game.cells[pos]
				if oldCell != newCell {
					if let gridCellNode = landCellForGamePosition(UInt32(pos)) {
						gridCellNode.setGameCell(newCell, game: game)
					}
				}
			}
			let formerPlayers = self.game?.players
			self.game = game
			updatePlayerNodes(formerPlayers)
		}
	}
	
	func updatePlayerNodes(formerPlayers : [Player]?) {
		var targetPosition : CGPoint?
		playerTransitionsOnGoing += playerNodes.count
		for i in 0..<playerNodes.count {
			let player = game!.players[i]
			var extraPoints : UInt32 = 0
			if formerPlayers != nil && formerPlayers!.count == playerNodes.count {
				extraPoints = player.score - formerPlayers![i].score
			}
			let pos = game!.getPlayerPosition(player.playerId)
			let changedPosition = playerNodes[i].setGamePosition(pos, extraPoints: extraPoints, completion: playerTransitionDidComplete)
			playerNodes[i].score = player.score
			if changedPosition != nil {
				targetPosition = changedPosition
			}
		}
		if targetPosition != nil {
			scrollToAnimated(targetPosition!.x, y: targetPosition!.y)
		}
	}
	
	func playerTransitionDidComplete() {
		playerTransitionsOnGoing--
		
		if playerTransitionsOnGoing == 0 {
			for i in 0..<playerNodes.count {
				if game!.players[i].playerId != game!.turnPlayerId {
					playerNodes[i].setActivePlayer(false)
				}
			}
			
			let delayTime = dispatch_time(DISPATCH_TIME_NOW,
				Int64(0.5 * Double(NSEC_PER_SEC)))
			dispatch_after(delayTime, dispatch_get_main_queue()) {
				if self.game != nil {
					self.setActivePlayer(self.game!.turnPlayerId)
				}
			}
		}
		
	}
	
	func setActivePlayer(playerId : Identifier) {
		let inTurnPlayerPosition = self.game!.getPlayerPosition(playerId)
		let inTurnAbsPosition = pointForGridPosition(gridPositionForGamePosition(inTurnPlayerPosition))
		scrollToAnimated(inTurnAbsPosition.x, y: inTurnAbsPosition.y)
		
		// Update player state
		for i in 0..<playerNodes.count {
			if game!.players[i].playerId == playerId {
				playerNodes[i].setActivePlayer(true)
			}
		}
		
		// Show Who Play caption
		if game!.isLocalPlayer(playerId) && !game!.finished {
			if let player = game!.getPlayer(playerId) {
				let whoPlayCaption = (player.userId != nil && player.userId! == SessionManager.Singleton.userId) ? NSLocalizedString("You play", comment: "") : (player.title + NSLocalizedString(" plays", comment: ""))
				let scene = self.scene as! SKUIScene?
				scene?.overlayText(whoPlayCaption, withSize : size, during: 3)
			}
		}
	}
	
	func gridPositionForGamePosition(pos : UInt32) -> CGPoint {
		let gameGridPosition = self.game!.positionToCellPosition(pos)
		return CGPoint(x: gameGridPosition.x + CGFloat(gameBorderCells), y: gameGridPosition.y + CGFloat(gameBorderCells))
	}
	
	func gridPositionForGamePoint(point : CGPoint) -> CGPoint {
		return CGPoint(x: point.x + CGFloat(gameBorderCells), y: point.y + CGFloat(gameBorderCells))
	}
	
	func landCellForGamePosition(pos : UInt32) -> LandGridCellNode? {
		let gridPosition = gridPositionForGamePosition(pos)
		return existingCellForGridPosition(gridPosition) as! LandGridCellNode?
	}
	
	var gridWidth: Int {
		get {
			if game == nil {
				return 0
			} else {
				return Int(game!.width) + 2*gameBorderCells
			}
		}
	}
	
	var gridHeight: Int { 
		get {
			if game == nil {
				return 0
			} else {
				return Int(game!.height) + 2*gameBorderCells
			}
		}
	}
	
	func gridPositionForPoint(point : CGPoint) -> CGPoint {
		let Pi = point.x
		let Pj = point.y/heightAspect
		
		let Ti = floor(Pi/hexHalfHeight)
		let q = floor(2.0*Pj/r)
		let Pi_ = Pi - Ti * hexHalfHeight
		let Pj_ = Pj - q * r/2
		
		var Fi : CGFloat
		var Tj : CGFloat
		if Int(q + Ti) % 2 == 0 {
			Fi = hexHalfHeight - Pj_ * sq3
			if Pi_ < Fi {
				Tj = q
			} else {
				Tj = q + 1
			}
		} else {
			Fi = Pj_ * sq3
			if Pi_ > Fi {
				Tj = q
			} else {
				Tj = q + 1
			}
		}
		let Hj = floor((Tj - 1)/3.0)
		let Hi = floor(CGFloat((Ti-CGFloat(Hj%2))/2.0))
		
		return CGPoint(x: Hi, y: Hj)
	}
	
	func pointForGridPosition(gridPosition: CGPoint) -> CGPoint {
		let Hi = gridPosition.x
		let Hj = gridPosition.y
		let Pj = (r + r/2.0) * Hj
		let Pi = hexHalfHeight * (2.0*Hi + CGFloat(Int(Hj)%2))
		return CGPoint(x: Pi, y: Pj*heightAspect)
	}

	func centerPointForGridPosition(gridPosition: CGPoint) -> CGPoint {
		let Hi = gridPosition.x
		let Hj = gridPosition.y
		let Pj = (r + r/2.0) * Hj
		let Pi = hexHalfHeight * (2.0*Hi + CGFloat(Int(Hj)%2))
		return CGPoint(x: Pi + cellWidth/2, y: Pj*heightAspect + cellHeight/2)
	}
	
	func cellForGridPosition(grid : GridNode, position : CGPoint) -> GridCellNode {
		var cellType : String = "EmptyCell"
		var gameCell : Cell?
		if let gamePosition = gridPositionIntoGamePosition(position) {
			gameCell = game!.cells[Int(gamePosition.x) + Int(gamePosition.y)*Int(game!.width)]
			cellType = "LandCell"
		}
		
		var gridCell = dequeueReusableCellForType(cellType)
		if gridCell == nil {
			gridCell = buildGridCellForType(cellType)
		}
		if gameCell != nil {
			setupGridCellForGameCell(gridCell!, cellType: cellType, gameCell: gameCell!, game: game!)
		}
		return gridCell!
	}
	
	func gridPositionIntoGamePosition(gridPosition: CGPoint) -> CGPoint? {
		if game == nil {
			return nil
		}
		
		if (Int(gridPosition.x) < gameBorderCells)  || (Int(gridPosition.x) >= Int(gameBorderCells) + Int(game!.width))
			|| (Int(gridPosition.y) < gameBorderCells) || (Int(gridPosition.y) >= Int(gameBorderCells) + Int(game!.width)) {
			return nil
		} else {
			return CGPoint(x: Int(gridPosition.x) - gameBorderCells, y: Int(gridPosition.y) - gameBorderCells)
		}
	}
	
	func buildGridCellForType(cellType : String) -> GridCellNode {
		var cell : GridCellNode
		if cellType == "EmptyCell" {
			cell = EmptyGridCellNode(cellType: cellType)
		} else {
			cell = LandGridCellNode(cellType: cellType)
		}
		
		return cell
	}
	
	func setupGridCellForGameCell(gridCell : GridCellNode, cellType : String, gameCell : Cell, game: Game) {
		if cellType == "LandCell" {
			if let landCell = gridCell as? LandGridCellNode {
				landCell.setGameCell(gameCell, game: game)
			}
		}
	}
}

