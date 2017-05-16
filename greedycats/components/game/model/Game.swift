//
//  Game.swift
//  Hunter Cats
//
//  Created by David Yuste on 2/17/15.
//  Copyright (c) 2015 yugame. All rights reserved.
//

import Foundation
import UIKit

class Cell {
	init() {
		self.playerId = nil
		self.resources = 0
		self.state = 0
	}
	
	init(playerId : NSNumber?, resources : NSNumber, state : NSNumber) {
		self.playerId = playerId?.unsignedLongLongValue
		self.resources = resources.unsignedIntValue
		self.state = state.unsignedIntValue
	}
	
	init(dbIterator : DataBaseTraverserIterator) {
		if !dbIterator.isNull(0) {
			self.playerId = dbIterator.colAsUInt64(0)
		}
		self.resources = dbIterator.colAsUInt32(1)
		self.state = dbIterator.colAsUInt32(2)
	}
	
	class func fromDictionary(dic: NSDictionary) -> Cell? {
		let playerId = dic["p"] as? NSNumber
		let resources = dic["r"] as? NSNumber
		let state = dic["s"] as? NSNumber
		
		if resources == nil || state == nil {
			return nil
		}
		
		return Cell(playerId: playerId, resources: resources!, state: state!)
	}
	
	class func collectionFromDictionary(array: NSArray) -> [Cell] {
		var col : [Cell] = []
		
		for obj in array {
			if let objDic = obj as? NSDictionary {
				if let cell = Cell.fromDictionary(objDic) {
					col.append(cell)
				}
			}
		}
		return col
	}
	
	var playerId : Identifier?
	var resources : UInt32
	var state : UInt32
}

func ==(lhs: Cell, rhs: Cell) -> Bool {
	return lhs.playerId == rhs.playerId && lhs.resources == rhs.resources && lhs.state == rhs.state
}

func !=(lhs: Cell, rhs: Cell) -> Bool {
	return !(lhs == rhs)
}

class Game : Bom {
	init() {
		self.id = 0
		self.sequenceNum = 0
		self.width = 0
		self.height = 0
		self.cells = []
		self.players = []
		self.ownerUserId = 0
		self.turnPlayerId = 0
		self.finished = false
		self.random = false
		self.timestamp = 0
	}
	
	init(id : NSNumber, sequenceNum : NSNumber, width : NSNumber, height : NSNumber, ownerUserId : NSNumber, turnPlayerId : NSNumber, finished : NSNumber, random : NSNumber, timestamp : NSNumber, cells : [Cell], players : [Player]) {
		self.id = id.unsignedLongLongValue
		self.sequenceNum = sequenceNum.unsignedLongLongValue
		self.width = width.unsignedIntValue
		self.height = height.unsignedIntValue
		self.cells = cells
		self.players = players
		self.ownerUserId = ownerUserId.unsignedLongLongValue
		self.turnPlayerId = turnPlayerId.unsignedLongLongValue
		if finished.unsignedIntValue != 0 {
			self.finished = true
		} else {
			self.finished = false
		}
		if random.unsignedIntValue != 0 {
			self.random = true
		} else {
			self.random = false
		}
		self.timestamp = timestamp.unsignedLongLongValue
	}
	
	required init(dbIterator: DataBaseTraverserIterator) {
		self.id = dbIterator.colAsUInt64(0)
		self.sequenceNum = dbIterator.colAsUInt64(1)
		self.width = dbIterator.colAsUInt32(2)
		self.height = dbIterator.colAsUInt32(3)
		self.cells = []
		self.players = []
		self.ownerUserId = dbIterator.colAsUInt64(4)
		self.turnPlayerId = dbIterator.colAsUInt64(5)
		if dbIterator.colAsInt32(6) != 0 {
			self.random = true
		} else {
			self.random = false
		}
		if dbIterator.colAsInt32(7) != 0 {
			self.finished = true
		} else {
			self.finished = false
		}
		self.timestamp = dbIterator.colAsUInt64(8)
	}

// Bom: Net Json construction
	class func fromDictionary(dic: NSDictionary) -> Bom? {
		let id = dic["i"] as? NSNumber
		let sequenceNum = dic["s"] as? NSNumber
		let width = dic["w"] as? NSNumber
		let height = dic["h"] as? NSNumber
		let cells = dic["c"] as? NSArray
		let players = dic["p"] as? NSArray
		let ownerUserId = dic["o"] as? NSNumber
		let turnPlayerId = dic["t"] as? NSNumber
		let finished = dic["f"] as? NSNumber
		let random = dic["r"] as? NSNumber
		let timestamp = dic["ts"] as? NSNumber
		
		if (id == nil || sequenceNum == nil || width == nil || height == nil) || (cells == nil || players == nil) || (ownerUserId == nil || turnPlayerId == nil || finished == nil || random == nil || timestamp == nil) {
			return nil
		}
		let cellCollection = Cell.collectionFromDictionary(cells!)
		let playerCollection = Player.collectionFromDictionary(players!)
		if (cellCollection.count < 2) {
			return nil
		}
		if (cellCollection.count < (Int(width!.intValue) * Int(height!.intValue))) {
			return nil
		}
		
		return Game(id: id!, sequenceNum: sequenceNum!, width: width!, height: height!, ownerUserId: ownerUserId!, turnPlayerId: turnPlayerId!, finished: finished!, random: random!, timestamp: timestamp!, cells: cellCollection, players : playerCollection)
	}
	
// Construction from db (custom cache from db)
	class func hasCustomDataBaseLoader() -> Bool {
		return true
	}
	class func fromDataBase(id : NSNumber) -> Bom? {
		let sqlGame = "SELECT id,sequence_num,width,height,owner_user_id,turn_player_id,random_game,finished,time_stamp " +
		"FROM \(TableGame) WHERE id =\(id)"
		let gameTraverser = DataBaseTraverser(sql: sqlGame)
		let gameRecord = gameTraverser.begin()
		if gameRecord == nil {
			return nil
		}
		let game = Game(dbIterator: gameRecord!)
		
		let playersSql = "SELECT player_id,user_id,virtual_user_id,can_move,score " +
			"FROM \(TableGamePlayers) WHERE game_id=\(id) ORDER BY player_id ASC"
		let playersTraverser = DataBaseTraverser(sql: playersSql)
		for playerRecord in playersTraverser {
			game.players.append(Player(dbIterator: playerRecord))
		}
		
		let cellsSql = "SELECT player_id,resources,state FROM \(TableGameCells) " +
			"WHERE game_id=\(id) ORDER BY position ASC"
		let cellsTraverser = DataBaseTraverser(sql: cellsSql)
		for cellRecord in cellsTraverser {
			game.cells.append(Cell(dbIterator: cellRecord))
		}
		
		return game
	}
	
	class func collectionFromDataBase(ids : [NSNumber]) -> [Bom] {
		var col : [Game] = []
		
		for id in ids {
			if let game = Game.fromDataBase(id) as? Game {
				col.append(game)
			} else {
				Logger.Warn("Game::collectionFromDataBase: failed to load game \(id) from database")
			}
		}
		
		return col
	}
	
// Bom: Common required attributes
	func getKey() -> Identifier {
		return id;
	}
	
	func getTimeStamp() -> UInt64 {
		return timestamp;
	}
	
// Bom: Data base interfacing
	class func getSQLSelect() -> String {
		return ""
	}
	class func getSQLKey() -> String {
		return "id"
	}
	func dataBaseStore() {
		var randomStr : String
		if random {
			randomStr = "1"
		} else {
			randomStr = "0"
		}
		var finishedStr : String
		if finished {
			finishedStr = "1"
		} else {
			finishedStr = "0"
		}
		DataBaseAdapter.Singleton.executeInsertOrReplace(TableGame,
			fields: "id,sequence_num,width,height,owner_user_id,turn_player_id,random_game,finished,time_stamp",
			values: "(\(id),\(sequenceNum),\(width),\(height),\(ownerUserId),\(turnPlayerId),\(randomStr),\(finishedStr),\(timestamp))")
		var cellValues : String = ""
		var separator : String = ""
		var pos : Int = 0
		for cell in cells {
			var playerIdStr : String
			if cell.playerId != nil {
				playerIdStr = "\(cell.playerId!)"
			} else {
				playerIdStr = "NULL"
			}
			cellValues += "\(separator)(\(id),\(pos),\(playerIdStr),\(cell.resources),\(cell.state))"
			pos++
			separator = ","
		}
		DataBaseAdapter.Singleton.executeChange("DELETE FROM \(TableGameCells) WHERE game_id=\(id)")
		DataBaseAdapter.Singleton.executeInsertOrReplace(TableGameCells,
			fields: "game_id,position,player_id,resources,state",
			values: cellValues)
		
		var playerValues : String = ""
		separator = ""
		for player in players {
			var _virtualUserId = "NULL"
			if player.virtualUserId != nil {
				_virtualUserId = "\(player.virtualUserId!)"
			}
			var _userId = "NULL"
			if player.userId != nil {
				_userId = "\(player.userId!)"
			}
			var canMoveStr : String
			if player.canMove {
				canMoveStr = "1"
			} else {
				canMoveStr = "0"
			}
			playerValues += "\(separator)(\(id),\(player.playerId),\(_userId),\(_virtualUserId),\(canMoveStr),\(player.score))"
			pos++
			separator = ","
		}
		DataBaseAdapter.Singleton.executeChange("DELETE FROM \(TableGamePlayers) WHERE game_id=\(id)")
		DataBaseAdapter.Singleton.executeInsertOrReplace(TableGamePlayers,
			fields: "game_id,player_id,user_id,virtual_user_id,can_move,score",
			values: playerValues)
	}
	
	func getTitle() -> String {
		var title = ""
		let separator = ""
		for player in players {
			title += "\(separator)\(player.title)"
		}
		return title
	}
	
	func canMoveTo(cellPosition: CGPoint) -> Bool {
		if finished {
			return false
		}
		
		let player = players[Int(turnPlayerId)]
		
		var canMove : Bool = false
		
		// Detect in turn
		if player.userId != nil {
			if player.userId == SessionManager.Singleton.userId {
				canMove = true
			}
		} else if ownerUserId == SessionManager.Singleton.userId {
			canMove = true
		}
		if !canMove {
			return false
		}
		
		// Verify valid destination
		if cellPosition.x < 0 || cellPosition.y < 0 || cellPosition.x >= CGFloat(width) || cellPosition.y >= CGFloat(height) {
			return false
		}
		
		// Detect current position
		var turnPlayerPosition : UInt32 = 0
		for cell in cells {
			if cell.playerId == turnPlayerId {
				break
			}
			++turnPlayerPosition
		}
		
		// TODO Verify movement
	
		return canMove
	}
	
	func cellPositionToPosition(cellPosition: CGPoint) -> UInt32 {
		return UInt32(cellPosition.x + cellPosition.y * CGFloat(height))
	}
	
	func positionToCellPosition(position: UInt32) -> CGPoint {
		return CGPoint(x: CGFloat(position - ((position/width) * width)), y: CGFloat(position/width))
	}
	
	func getPlayerPosition(playerId : Identifier) -> UInt32 {
		for pos in 0..<cells.count {
			let cell = cells[pos]
			if cell.playerId != nil && cell.playerId! == playerId {
				return UInt32(pos)
			}
		}
		
		Logger.Warn("Game::getPlayerPosition: player \(playerId) not found")
		
		return 0
	}
	
	func isLocalPlayer(playerId : Identifier) -> Bool {
		if let player = getPlayer(playerId) {
			return (player.virtualUserId != nil && ownerUserId == SessionManager.Singleton.userId) || (player.userId != nil && player.userId! == ownerUserId)
		}
		return false
	}
	
	func getPlayer(playerId : Identifier) -> Player? {
		for player in players {
			if player.playerId == playerId {
				return player
			}
		}
		return nil
	}
	
	func getWinnerUser() -> User? {
		var winner : Player?
		for player in players {
			if winner == nil {
				winner = player
			} else {
				if player.score > winner!.score {
					winner = player
				}
			}
		}
		var winnerUser : User?
		if winner!.userId != nil {
			winnerUser = DataManager.Singleton.getUser(winner!.userId!)
		} else if winner!.virtualUserId != nil {
			winnerUser = DataManager.Singleton.getVirtualUser(winner!.virtualUserId!)
		}
		return winnerUser
	}
	
	var id : Identifier
	var sequenceNum : Identifier
	var width : UInt32
	var height : UInt32
	var cells : [Cell]
	var players : [Player]
	var turnPlayerId : Identifier
	var ownerUserId : Identifier
	var finished : Bool
	var random : Bool
	var timestamp : UInt64
	
}
