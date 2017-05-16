//
//  GameView.swift
//  greedycats
//
//  Created by David Yuste on 11/15/15.
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

class GameView: SKView {
	func CBApplicationDidBecomeActive() {
	}
	
	override init (frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}
