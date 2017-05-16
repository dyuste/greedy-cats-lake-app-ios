//
//  TextureCollections.swift
//  greedycats
//
//  Created by David Yuste on 5/23/15.
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

class TextureCollections {
	
	static let PlayerDepartTopLeftAtlas : String = "PlayerDepartTopLeft"
	static let DepartTopLeftAnimationName : String = "DepartTopLeft"
	
	static let PlayerDepartTopRightAtlas : String = "PlayerDepartTopRight"
	static let DepartTopRightAnimationName : String = "DepartTopRight"
	
	static let PlayerDepartBottomLeftAtlas : String = "PlayerDepartBottomLeft"
	static let DepartBottomLeftAnimationName : String = "DepartBottomLeft"
	
	static let PlayerDepartBottomRightAtlas : String = "PlayerDepartBottomRight"
	static let DepartBottomRightAnimationName : String = "DepartBottomRight"
	
	static let PlayerDepartLeftAtlas : String = "PlayerDepartLeft"
	static let DepartLeftAnimationName : String = "DepartLeft"
	
	static let PlayerDepartRightAtlas : String = "PlayerDepartRight"
	static let DepartRightAnimationName : String = "DepartRight"
	
	static let PlayerArriveTopLeftAtlas : String = "PlayerArriveTopLeft"
	static let ArriveTopLeftAnimationName : String = "ArriveTopLeft"
	
	static let PlayerArriveTopRightAtlas : String = "PlayerArriveTopRight"
	static let ArriveTopRightAnimationName : String = "ArriveTopRight"
	
	static let PlayerArriveBottomLeftAtlas : String = "PlayerArriveBottomLeft"
	static let ArriveBottomLeftAnimationName : String = "ArriveBottomLeft"
	
	static let PlayerArriveBottomRightAtlas : String = "PlayerArriveBottomRight"
	static let ArriveBottomRightAnimationName : String = "ArriveBottomRight"
	
	static let PlayerArriveLeftAtlas : String = "PlayerArriveLeft"
	static let ArriveLeftAnimationName : String = "ArriveLeft"
	
	static let PlayerArriveRightAtlas : String = "PlayerArriveRight"
	static let ArriveRightAnimationName : String = "ArriveRight"
	
	static let PlayerIddleAtlas : String = "PlayerIddle"
	static let ActiveToIddleAnimationName : String = "ActiveToIddle"
	static let ActiveAnim01AnimationName : String = "ActiveAnim01"
	
	static let PointsAtlas : String = "Points"
	static let PointsAnimationName : String = "Points"
	
	static let LeafAtlas : String = "Leaf"
	static let LeafAnimationName : String = "Leaf"
	static let LeafDieAnimationName : String = "LeafDie"
	static let LeafHelpAnimationName : String = "LeafHelp"
	
	static let Leaf2pxAtlas : String = "Leaf2px"
	static let Leaf2xDieAnimationName : String = "Leaf2xDie"
	static let Leaf2pxAnimationName : String = "Leaf2px"
	
	
	static func prefetchAllAtlas(complete: (() -> Void)) {
		dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
			let loader = TextureLoader.Singleton
			loader.loadAtlas(TextureCollections.PlayerDepartTopLeftAtlas)
			loader.loadAtlas(TextureCollections.PlayerDepartTopRightAtlas)
			loader.loadAtlas(TextureCollections.PlayerDepartBottomLeftAtlas)
			loader.loadAtlas(TextureCollections.PlayerDepartBottomRightAtlas)
			loader.loadAtlas(TextureCollections.PlayerDepartLeftAtlas)
			loader.loadAtlas(TextureCollections.PlayerDepartRightAtlas)
			loader.loadAtlas(TextureCollections.PlayerArriveTopLeftAtlas)
			loader.loadAtlas(TextureCollections.PlayerArriveTopRightAtlas)
			loader.loadAtlas(TextureCollections.PlayerArriveBottomLeftAtlas)
			loader.loadAtlas(TextureCollections.PlayerArriveBottomRightAtlas)
			loader.loadAtlas(TextureCollections.PlayerArriveLeftAtlas)
			loader.loadAtlas(TextureCollections.PlayerArriveRightAtlas)
			loader.loadAtlas(TextureCollections.PlayerIddleAtlas)
			loader.loadAtlas(TextureCollections.PointsAtlas)
			loader.loadAtlas(TextureCollections.LeafAtlas)
			loader.loadAtlas(TextureCollections.Leaf2pxAtlas)
			
			dispatch_async( dispatch_get_main_queue(), {
				complete()
			});
		});
		
	}
}
