//
//  PlayersSummaryListNode.swift
//  greedycats
//
//  Created by David Yuste on 9/20/15.
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



struct ScoredPlayer : Comparable {
	init (player : Player) {
		self.player = player
	}
	var player : Player
}

func <(p: ScoredPlayer, q: ScoredPlayer) -> Bool {
	return p.player.score < q.player.score
}

func ==(p: ScoredPlayer, q: ScoredPlayer) -> Bool {
	return p.player.score == q.player.score
}

class PlayersSummaryListWidget : SKUIWidget {
	var game : Game
	var playerLabelNodes : [PlayerLabelWidget] = []
	
	init(game: Game) {
		self.game = game
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func widgetCreateSubWidgets() {
		var playerIndex = 0
		let players = getSortPlayerList(game)
		for player in players {
			let playerLabelNode = PlayerLabelWidget(player: player)
			playerLabelNode.position = CGPointMake(CGFloat(10), playerLabelNode.size.height * CGFloat(playerIndex))
			addChildWidget(playerLabelNode)
			++playerIndex
		}
	}
	
	func getSortPlayerList(game : Game) -> [Player] {
		var sortPlayerList : [ScoredPlayer] = []
		
		for player in game.players {
			let comparablePlayer = ScoredPlayer(player: player)
			sortPlayerList.append(comparablePlayer)
		}
		
		sortPlayerList = quicksort(sortPlayerList)
		
		var players : [Player] = []
		for scoredPlayer in sortPlayerList {
			players.append(scoredPlayer.player)
		}
		
		return players
	}
}
