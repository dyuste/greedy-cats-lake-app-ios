//
//  CreateViewController.swift
//  Greedy Cats
//
//  Created by David Yuste on 2/21/15.
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

class CreateGameViewController : YCTableViewController, UserDelegate, GameDelegate {
	var userNameInputTimer : NSTimer?
	
	required init() {
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func attachManagers() {
		super.attachManagers()
		UserManager.Singleton.addDelegate(self)
		GameManager.Singleton.addDelegate(self)
		userNameInputTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateUserNameInputPattern"), userInfo: nil, repeats: true)
	}
	
	override func detachManagers() {
		super.detachManagers()
		UserManager.Singleton.removeDelegate(self)
		GameManager.Singleton.removeDelegate(self)
		userNameInputTimer?.invalidate()
	}
	
	override func kickOffView() {
		super.kickOffView()
		ProfileManager.Singleton.startProfileGetSummary()
	}
	
	override func attachWidgets(topView : UIView) {
		super.attachWidgets(topView)
		let backButton = BackButtonWidget()
		backButton.addToView(self, view: topView)
	}
	
	// MARK:-
	// MARK: Table contents
	var topActionsGroup : YCFormTableViewGroup?
	var editActionsGroup : YCFormTableViewGroup?
	var playersGroup : YCTableViewGroup?
	var usersGroup : YCTableViewGroup?
	weak var inputControl : YCFormTableViewControl?
	var inputString : String = ""
	
	override func createTableView(bounds: CGRect) -> YCTableView? {
		let tableView = YCTableView(frame: bounds, style: UITableViewStyle.Grouped)
		createEmptyGroup(tableView)
		playersGroup = createPlayersGroup(tableView)
		playersGroup!.roundedBorder = true
		editActionsGroup = createEditActionsGroup(tableView)
		setEditActionsAddState()
		usersGroup = createUsersGroup(tableView)
		
		topActionsGroup = createTopActionsGroup(tableView)
		tableView.backgroundColor = Colors.TransparentColor
		tableView.separatorColor = Colors.TransparentColor
		return tableView
	}
	
	
	private func createEmptyGroup(tableView : YCTableView) -> YCTableViewGroup {
		let group = YCFormTableViewGroup(table: tableView, name: "empty")
		
		group.heightForHeader = {
			return 2*Metrics.StatusBarHeight
		}
		group.heightForFooter = {
			return Metrics.DefaultTableSectionFooterHeight
		}
		return group
	}
	
	private func createTopActionsGroup(tableView : YCTableView) -> YCFormTableViewGroup {
		let group = YCFormTableViewGroup(table: tableView, name: "topActions")
		group.setControls([
			YCFormTableViewControl.createButton(
				NSLocalizedString("Start Game", comment: ""),
				action: {
					self.createGame()
				}
			)
		])
		group.heightForHeader = {
			return Metrics.DefaultTableSectionFooterHeight
		}
		group.heightForFooter = {
			return Metrics.DefaultTableSectionFooterHeight
		}
		return group
	}
	
	private func createPlayersGroup(tableView : YCTableView) -> YCTableViewGroup {
		let group = YCTableViewGroup(table: tableView, name: "players", cellIdentifier: "playerCell")
		
		group.cellCreator = { reuseIdentifier, withData in
			let cell = UserTableViewCell(
				linkColor: Colors.BlackColor,
				withAddButton: false,
				reuseIdentifier: reuseIdentifier)
			cell.backgroundColor = Colors.WhiteColor
			cell.selectionStyle = UITableViewCellSelectionStyle.None
			return cell
		}
		group.cellConfigurer = { cell, withData in
			let userCell = cell as! UserTableViewCell
			let user = withData as! User
			userCell.setUser(user)
			return cell
		}
		group.cellHeightConfigurer = { withData in
			return Metrics.GameRowHeight
		}
		
		group.heightForHeader = {
			return Metrics.GroupTitleHeight
		}
		group.headerViewCreator = {
			let header = GamesHeaderTableViewCell(reuseIdentifier: "playersHeaderCell", leftAlign: true)
			header.captionLabel.text = NSLocalizedString("Players", comment: "")
			return header
		}

		if let loggedUser = SessionManager.Singleton.user {
			group.data = [loggedUser]
		}
		
		return group
	}
	
	private func createEditActionsGroup(tableView : YCTableView) -> YCFormTableViewGroup {
		return YCFormTableViewGroup(table: tableView, name: "editActions")
	}
	
	private func setEditActionsAddState() {
		editActionsGroup!.setControls([
			YCFormTableViewControl.createButton(
				NSLocalizedString("Add Player", comment: ""),
				action: {
					self.setEditActionsInputState()
				}
			)
		])
		self.inputControl = nil
	}
	
	private func setEditActionsInputState() {
		let inputControl = YCFormTableViewControl.createTextField(
			NSLocalizedString("Type the name of the new player", comment: ""),
			defaultText : {
				if self.usersGroup!.data.count >= 1 {
					let localUser = self.usersGroup!.data[0] as! User
					return localUser.userName
				}
				return ""
			},
			action: {},
			edit : { string in
				self.inputString = string
			})
		inputControl.firstResponder = true
		editActionsGroup!.setControls([inputControl])
		
		usersGroup!.data = [User()]
		self.inputControl = inputControl
	}
	
	private func createUsersGroup(tableView : YCTableView) -> YCTableViewGroup {
		let group = YCTableViewGroup(table: tableView, name: "users", cellIdentifier: "userCell")
		
		group.cellCreator = { reuseIdentifier, withData in
			let cell = UserTableViewCell(
				linkColor: Colors.WhiteColor,
				withAddButton: true,
				reuseIdentifier: reuseIdentifier)
			cell.backgroundColor = Colors.TransparentColor
			cell.selectionStyle = UITableViewCellSelectionStyle.None
			return cell
		}
		group.cellConfigurer = { cell, withData in
			let userCell = cell as! UserTableViewCell
			let user = withData as! User
			userCell.setUser(user)
			return cell
		}
		group.cellHeightConfigurer = { withData in
			return 60
		}
		group.cellSelectHandler = { withData in
			let user = withData as! User
			if !user.isLocal || user.userName.characters.count > 0 {
				var players = self.playersGroup!.data
				players.append(user)
				self.playersGroup!.data = players
				self.usersGroup!.data = []
				self.setEditActionsAddState()
			}
		}
		
		group.data = []
		
		return group
	}
		
	//MARK:-
	//MARK: User serach
	var inputSearchedPattern : String = ""

	func updateUserNameInputPattern () {
		if inputControl != nil {
			let inputCell = inputControl!.cell as! TextFieldTableViewCell?
			let inputField = inputCell?.textField
			if inputField != nil {
				if inputField!.text != inputSearchedPattern {
					inputSearchedPattern = inputField!.text!
					if inputSearchedPattern.characters.count > 2 {
						UserManager.Singleton.startSearchUser(inputSearchedPattern)
					}
					
					var users : [AnyObject] = self.usersGroup!.data
					var modified : Bool = false
					if usersGroup!.data.count >= 1 {
						let localUser = users[0] as! User
						if localUser.userName != inputSearchedPattern {
							localUser.userName = inputSearchedPattern
							modified = true
						}
					}
					
					if inputSearchedPattern.characters.count == 0 {
						if users.count > 1 {
							users = [users[0]]
							modified = true
						}
					}
					
					if modified {
						usersGroup!.data = users
					}
				}
			}
		}
	}
	
	// UserDelegate
	func userSearchDidComplete(pattern: String, results: [User]) {
		if inputControl != nil {
			var users : [AnyObject] = []
			if usersGroup!.data.count >= 1 {
				let localUser : AnyObject = usersGroup!.data[0]
				users.append(localUser)
			}
			for user in results {
				users.append(user)
			}
			usersGroup!.data = users
		}
	}
	
	//MARK:-
	//MARK: Game Creation
	private func createGame() {
		var users : [User] = []
		var localUsers : [User] = []
		
		for user in playersGroup!.data as! [User] {
			if user.isLocal {
				localUsers.append(user)
			} else {
				users.append(user)
			}
		}
		
		if (users.count <= 1 && localUsers.count == 0) {
			let requiredPlayersAlert = UIAlertController(
				title: NSLocalizedString("You did not add any player", comment: ""),
				message: NSLocalizedString("Press 'Add Player' to add a new local participant or a network one", comment: ""),
				preferredStyle: UIAlertControllerStyle.Alert)
			requiredPlayersAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
			presentViewController(requiredPlayersAlert, animated: true, completion: nil)
		} else {
			let actualUsers : [User] = Array(users[0..<users.count])
			GameManager.Singleton.startCreateGame(actualUsers, localUserList: localUsers)
		}
	}
	
	// GameDelegate
	func gameCreateDidComplete(gameId: Identifier) {
		let controller = NavigationManager.Singleton.forwardToController(GameViewController.self)
		controller.gameId = gameId
	}
	
	func gameJoinRandomDidComplete(gameId : Identifier) {
		
	}
	
	func gameCreateDidFail() {
	
	}
	
	func gameUpdated(gameId : Identifier) {
		
	}
}
