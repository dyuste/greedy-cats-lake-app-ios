
//
//  GameViewController.swift
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
import SpriteKit

class GameViewController : YCViewController, GameSceneDelegate, GameDelegate {
	private var _gameId : Identifier?
	weak var gameScene : GameScene?
	var game : Game?
	
	required init()
	{
		super.init()
		appendBackgroundDuringLoad = false
	}

	required init?(coder aDecoder: NSCoder)
	{
	    fatalError("init(coder:) has not been implemented")
	}
	
	var gameId : Identifier!
	{
		get {
			return _gameId!
		}
		set {
			if _gameId != newValue {
				_gameId = newValue
			}
		}
	}
	
	override func createContentView() -> UIView {
		let contentView = GameView(frame: view.frame)
		view.insertSubview(contentView, aboveSubview: backgroundView)
		contentView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
		return contentView
	}
	
	override func showLoading() {
		loadLoadingScene()
	}
	
	override func attachManagers() {
		super.attachManagers()
		GameManager.Singleton.addDelegate(self)
	}
	
	override func detachManagers() {
		super.detachManagers()
		GameManager.Singleton.removeDelegate(self)
	}
	
	override func kickOffView() {
		super.kickOffView()
		AdManager.Singleton.loadInterstitial()
		if _gameId != nil {
			loadGameScene(_gameId!)
		}
	}
	
	override func attachWidgets(topView : UIView) {
		super.attachWidgets(topView)
		let backButton = BackButtonWidget()
		backButton.addToView(self, view: topView)
	}
	
	override func releaseView()
	{
		unloadGameScene()
	}
	
	override func applicationDidBecomeActive()
	{
		super.applicationDidBecomeActive()
		let skView = self.contentView as! SKView?
		gameScene?.paused = false
		skView?.paused = false
	}
	
	override func applicationWillResignActive()
	{
		super.applicationWillResignActive()
		let skView = self.contentView as! SKView?
		skView?.paused = true
		gameScene?.paused = true
	}
	
	override func viewWillTransitionToSize(size: CGSize,
		withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
			super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
			gameScene?.size = size
	}

	private func unloadGameScene() {
		gameScene?.sceneCleanUp()
		gameScene = nil
		game = nil
		if let skView = self.contentView as! SKView? {
			skView.presentScene(nil)
			self.contentView = nil
		}
	}
	
	private func loadLoadingScene() {
		let loadingScene = LoadingScene(size: UIScreen.mainScreen().bounds.size)
		loadingScene.scaleMode = .ResizeFill
			
		let skView = contentView as! SKView
		skView.ignoresSiblingOrder = true
		skView.presentScene(loadingScene)
	}
	
	private func loadGameScene(gameId : Identifier) {
		if let game = DataManager.Singleton.getGame(gameId) {
			self.game = game
			
			dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
				let gameScene = GameScene(size: UIScreen.mainScreen().bounds.size, game: game)
				gameScene.scaleMode = .ResizeFill
				gameScene.gameSceneDelegate = self
				gameScene.setGame(game)
				
				dispatch_async( dispatch_get_main_queue(), {
					self.gameScene = gameScene
					if let skView = self.contentView as? SKView {
						skView.ignoresSiblingOrder = true
						skView.presentScene(self.gameScene)
						self.gameScene!.paused = false
					}

				});
			});
		}
	}
	
// MARK: GameDelegate
	func gameUpdated(gameId : Identifier) {
		if gameId == self.gameId {
			if let game = DataManager.Singleton.getGame(gameId) {
				self.game = game
				if gameScene != nil {
					gameScene!.setGame(game)
				}
			}
		}
	}
	
	func gameCreateDidComplete(gameId : Identifier) {
		
	}
	
	func gameJoinRandomDidComplete(gameId : Identifier) {
		
	}
	
	func gameCreateDidFail() {
		
	}
	
// MARK: GameGridDelegate
	func gameCellClicked(cellPosition : CGPoint) {
		if game != nil {
			if game!.canMoveTo(cellPosition) {
				let position = game!.cellPositionToPosition(cellPosition)
				GameManager.Singleton.startGameMove(gameId!, position: position)
			}
		}
	}
	
	func gameFinished() {
		AdManager.Singleton.presentInterstitial({ status in
			self.dismissViewControllerAnimated(true, completion: nil)
		})
	}
	

}
