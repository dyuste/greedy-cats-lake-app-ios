//
//  TextureLoader.swift
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

class TextureLoader : NSObject {
	class var Singleton : TextureLoader {
		struct singleton {
			static let instance = TextureLoader()
		}
		return singleton.instance
	}
	
	var textureCollections : [String : [String : [SKTexture]]] = Dictionary<String, Dictionary<String, [SKTexture]>>()
	
	private var memoryWarningNotification : NSObjectProtocol!
	
	override init () {
		super.init()
		
		memoryWarningNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidReceiveMemoryWarningNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
			[unowned self] notification in
			self.didReceiveMemoryWarning()
		}
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(memoryWarningNotification)
	}
	
	func didReceiveMemoryWarning() {
		Logger.Info("TextureLoader::didReceiveMemoryWarning - releasing collections")
		textureCollections = Dictionary<String, Dictionary<String, [SKTexture]>>()
	}
	
	func getCollection(atlasName : String, collectionName : String) -> [SKTexture]? {
		var atlas : [String : [SKTexture]]?
		atlas = textureCollections[atlasName]
		if atlas == nil {
			loadAtlas(atlasName)
			atlas = textureCollections[atlasName]
		}
		if atlas == nil {
			return nil
		}
		
		return atlas![collectionName]
	}
	
	func loadAtlas(atlasName : String) {
		if textureCollections[atlasName] != nil {
			return
		}
		
		let atlas = SKTextureAtlas(named: atlasName)
		textureCollections[atlasName] = Dictionary<String, [SKTexture]>()
		let textures = atlas.textureNames
		let filteredTextures = textures
			.map({ String($0 as NSString).replace("-\\d*(@\\dx)?\\.\\w*$", replacement: "") })
		
		var collections : [String] = []
		for filteredTexture in filteredTextures {
			if !collections.contains(filteredTexture) {
				collections.append(filteredTexture)
			}
		}
		
		for collection in collections {
			var textureCollection : [SKTexture] = []
			var collectionItems : [String] = []
			let numberedTextures = atlas.textureNames
				.filter { String($0 as NSString).rangeOfString(collection) != nil }
				.map { String($0 as NSString).replace("(@\\dx)?\\.\\w*$", replacement: "") }
			for numberedTexture in numberedTextures {
				if !collectionItems.contains(numberedTexture) {
					collectionItems.append(numberedTexture)
				}
			}
			
			for i  in 0..<collectionItems.count {
				let textureName = "\(collection)-\(i)"
				let texture = atlas.textureNamed(textureName)
				textureCollection.append(texture)
			}
			textureCollections[atlasName]![collection] = textureCollection
		}
	}
}

