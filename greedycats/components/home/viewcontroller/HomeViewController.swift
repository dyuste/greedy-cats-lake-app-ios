//
//  HomeViewController.swift
//  Hunter Cats
//
//  Created by David Yuste on 2/19/15.
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

class HomeViewController: YCTableViewController, ProfileDelegate, GameDelegate, SessionDelegate {
	required init() {
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func attachManagers() {
		super.attachManagers()
		GameManager.Singleton.addDelegate(self)
		ProfileManager.Singleton.addDelegate(self)
		SessionManager.Singleton.addDelegate(self)
		
		// Ensure data gets updated
		ProfileManager.Singleton.startProfileOfflineGetSummary()
		if let loggedUser = SessionManager.Singleton.user {
			userGroup?.data = [loggedUser]
		}
	}
	
	override func detachManagers() {
		super.detachManagers()
		GameManager.Singleton.removeDelegate(self)
		ProfileManager.Singleton.removeDelegate(self)
		SessionManager.Singleton.removeDelegate(self)
	}
	
	override func kickOffView() {
		super.kickOffView()
		ProfileManager.Singleton.startProfileGetSummary()
	}
	
	override func attachWidgets(topView : UIView) {
		super.attachWidgets(topView)
		
		let getPremiumWidget = GetPremiumWidget()
		getPremiumWidget.addToView(self, view: topView)
		
		if !IS_IPHONE {
			let shareWidget = ShareWidget()
			shareWidget.addToView(self, view: topView)
		}
	}
	
	override func attachBanner(bannerView : UIView) {
		super.attachBanner(bannerView)
		let adBannerWidget = AdBannerWidget()
		adBannerWidget.addToView(self, view: bannerView)
	}
	
	// MARK:-
	// MARK: Table contents
	var actionsGroup : YCTableViewGroup?
	var userGroup : YCTableViewGroup?
	var readyGamesGroup : YCTableViewGroup?
	var waitingGamesGroup : YCTableViewGroup?
	var finishedGamesGroup :  YCTableViewGroup?
	
	override func createTableView(bounds: CGRect) -> YCTableView? {
		let tableView = YCTableView(frame: bounds, style: UITableViewStyle.Grouped)
		actionsGroup = createActionsGroup(tableView)
		userGroup = createUserGroup(tableView)
		readyGamesGroup = createGamesGroup(tableView,
			headerTitle: NSLocalizedString("You Play", comment: ""),
			leftAlign: true
		)
		waitingGamesGroup = createGamesGroup(tableView,
			headerTitle: NSLocalizedString("They Play", comment: ""),
			leftAlign: false
		)
		finishedGamesGroup = createGamesGroup(tableView,
			headerTitle: NSLocalizedString("Finished Games", comment: ""),
			leftAlign: true
		)
		tableView.backgroundColor = Colors.TransparentColor
		tableView.separatorColor = Colors.TransparentColor
		return tableView
	}
	
	private func createActionsGroup(tableView : YCTableView) -> YCTableViewGroup {
		let group = YCFormTableViewGroup(table: tableView, name: "actions")
		group.setControls([
			YCFormTableViewControl.createButton(
				NSLocalizedString("Random Enemies", comment: ""),
				action: {
					GameManager.Singleton.startJoinRandom()
				}
			),
			YCFormTableViewControl.createButton(
				NSLocalizedString("New Game", comment: ""),
				action: {
					NavigationManager.Singleton.forwardToController(CreateGameViewController.self)
				}
			)
		])
		
		group.headerViewCreator = {
			return PaddingImageView(named: "MainPicture", top: 12, bottom: 8, left: 0, right: 0)
		}
		
		group.heightForHeader = {
			return Metrics.HeaderHeight + 20
		}
		
		return group
	}
	
	private func createUserGroup(tableView : YCTableView) -> YCTableViewGroup {
		let group = YCTableViewGroup(table: tableView, name: "user", cellIdentifier: "userCell")
		group.cellCreator = { reuseIdentifier, withData in
			return UserDetailTableViewCell(reuseIdentifier: reuseIdentifier)
		}
		group.cellConfigurer = { cell, withData in
			let wrapperCell = cell as! UserDetailTableViewCell
			let user = withData as! User
			wrapperCell.setUser(user)
			return cell
		}
		group.cellHeightConfigurer = { withData in
			return Metrics.UserDetailHeight
		}
		group.cellSelectHandler = { withData in
			NavigationManager.Singleton.forwardToController(SignUpViewController.self)
		}
		group.heightForHeader = {
			return 1.0
		}
		if let loggedUser = SessionManager.Singleton.user {
			group.data = [loggedUser]
		}

		return group
	}
	
	private func createGamesGroup(tableView : YCTableView, headerTitle : String, leftAlign : Bool) -> YCTableViewGroup {
		let group = YCTableViewGroup(table: tableView, name: "games", cellIdentifier: "gameCell")
		group.roundedBorder = true
		group.cellCreator = { reuseIdentifier, withData in
			return GameTableViewCell(reuseIdentifier: reuseIdentifier)
		}
		group.cellConfigurer = { cell, withData in
			let gameId = withData as! NSNumber
			let gameCell = cell as! GameTableViewCell
			let game = DataManager.Singleton.getGame(gameId.unsignedLongLongValue)
			gameCell.setGame(game)
			return gameCell
		}
		group.cellHeightConfigurer = { withData in
			return Metrics.GameRowHeight
		}
		group.cellSelectHandler = { withData in
			let gameId = withData as! NSNumber
			if let game = DataManager.Singleton.getGame(gameId.unsignedLongLongValue) {
				// Random games must have at least 4 participants
				if !game.random || game.players.count >= 3 {
					let gameViewController = NavigationManager.Singleton.forwardToController(GameViewController.self)
					gameViewController.gameId = gameId.unsignedLongLongValue
				}
			}
		}
		group.heightForHeader = {
			return Metrics.GroupTitleHeight
		}
		group.headerViewCreator = {
			let header = GamesHeaderTableViewCell(reuseIdentifier: "gameHeaderCell", leftAlign: leftAlign)
			header.captionLabel.text = headerTitle
			return header
		}
		group.data = [NSNumber(longLong: 0)]
		return group
	}
	
	// MARK:-
	// MARK: ProfileDelegate
	func profileSummaryDidChange (readyGameIds : NSArray, waitingGameIds : NSArray, finishedGameIds : NSArray) {
		var readyArray : [NSNumber] = []
		var waitingArray : [NSNumber] = []
		var finishedArray : [NSNumber] = []
		for id in readyGameIds { readyArray.append(id as! NSNumber) }
		for id in waitingGameIds { waitingArray.append(id as! NSNumber) }
		for id in finishedGameIds { finishedArray.append(id as! NSNumber) }
		readyGamesGroup?.data = readyArray.count > 0 ? readyArray : [NSNumber(longLong: 0)]
		waitingGamesGroup?.data = waitingArray.count > 0 ? waitingArray : [NSNumber(longLong: 0)]
		finishedGamesGroup?.data = finishedArray.count > 0 ? finishedArray : [NSNumber(longLong: 0)]
	}
	
	// MARK:-
	// MARK: GameDelegate
	func gameJoinRandomDidComplete(gameId : Identifier) {
		var waitingGameIds = waitingGamesGroup?.data
		if waitingGameIds == nil
			|| (waitingGameIds!.count == 1
				&& waitingGameIds![0].longLongValue == 0) {
			waitingGameIds = [NSNumber(unsignedLongLong: gameId)]
		} else {
			waitingGameIds!.append(NSNumber(unsignedLongLong: gameId))
		}
		waitingGamesGroup?.data = waitingGameIds!
	}
	
	// TODO: Make profilemanager listen for gamemanager and raise the event
	func gameUpdated(gameId : Identifier) {
		ProfileManager.Singleton.startProfileOfflineGetSummary()
	}
	
	func gameCreateDidComplete(gameId: Identifier) {
	
	}
	
	func gameCreateDidFail() {
		
	}
	
	
	// MARK:-
	// MARK: SessionDelegate
	func sessionSignInDidFail() {}
	func sessionSignInDidSuccess() {
		if let loggedUser = SessionManager.Singleton.user {
			userGroup?.data = [loggedUser]
		}
	}
	func sessionExtendAccountDidSuccess() {
		if let loggedUser = SessionManager.Singleton.user {
			userGroup?.data = [loggedUser]
		}
	}
	func sessionExtendAccountDidFail() {}
	func sessionSignUpDidFail() {}
	func sessionLookUpUserNameDidSuccess(userName: String, available: Bool) {}
	func sessionLookUpUserNameDidFail() {}
}

