//
//  GameTableViewCell.swift
//  Greedy Cats
//
//  Created by David Yuste on 5/1/15.
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

class GameTableViewCell : YCTableViewCell {
	weak var game : Game?
	
	var preferredHeight : CGFloat = 80
	
	init(reuseIdentifier: String?) {
		super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
		preferredHeight = Metrics.GameRowHeight
		
		backgroundColor = UIColor.whiteColor()
		selectionStyle = UITableViewCellSelectionStyle.None
		detailTextLabel?.textColor = UIColor.blackColor()
		textLabel?.textColor = UIColor.blackColor()
		
		//textLabel?.font = Fonts.DefaultH2Font
		//detailTextLabel?.font = Fonts.DefaultH3Font
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func willDisplayCell() {
	}
	
	func setGame(game: Game?) {
		if (self.game == nil  && game != nil || self.game != nil && game == nil) || (self.game != nil && game != nil) && (self.game!.id != game!.id || self.game!.timestamp != game!.timestamp) {
			var yourScore :UInt32 = 0
			var players = ""
			var separator = ""
			var turnPlayerTitle : String? = nil
			var winningPlayerTitle = ""
			var winningPlayerScore : UInt32 = 0
			var isNetworkGame = false
			if game != nil {
				let turnPlayerId = game?.turnPlayerId
				var playerId : Identifier = 0
				for player in game!.players {
					if player.userId != nil && SessionManager.Singleton.userId != nil && player.userId! == SessionManager.Singleton.userId! {
						yourScore = player.score
					} else {
						players += "\(separator)\(player.title) (\(player.score))"
						separator = ", "
						if player.userId != nil {
							isNetworkGame = true
						}
						if player.playerId == turnPlayerId && !game!.finished {
							turnPlayerTitle = player.title
						}
					}
					if player.score > winningPlayerScore {
						winningPlayerScore = player.score
						winningPlayerTitle = player.title
					}
					++playerId;
				}
			
				self.game = game
				var mainCaption = NSLocalizedString("Your score", comment: "") + ": \(yourScore)"
				if winningPlayerScore > 0 {
					mainCaption += " (\(winningPlayerTitle) " + NSLocalizedString("wins", comment: "")
					if turnPlayerTitle != nil {
						mainCaption += ", \(turnPlayerTitle!) " + NSLocalizedString("plays", comment: "")
					}
					mainCaption += ")"
				}
				textLabel?.text = mainCaption
			
				let playersText = NSLocalizedString("with: ", comment: "") + players
				var detailText = ""
				if game!.random && game!.players.count < 4 {
					detailText += NSLocalizedString("waiting for participants...", comment: "")
					if game!.players.count > 1 {
						detailText += " \(playersText)"
					}
				} else {
					detailText = playersText
				}
				detailTextLabel?.text = detailText
				var userImage = "LocalUserPlain.png"
				if game?.random == true {
					userImage = "RandomUserPlain.png"
				} else if isNetworkGame {
					userImage = "NetworkUserPlain.png"
				}
				imageView?.image = UIImage(named: userImage)
			} else {
				textLabel?.text = nil
				detailTextLabel?.text = nil
				imageView?.image = nil
			}
		} else if game == nil {
			textLabel?.text = nil
			detailTextLabel?.text = nil
			imageView?.image = nil
		}
	}
}
