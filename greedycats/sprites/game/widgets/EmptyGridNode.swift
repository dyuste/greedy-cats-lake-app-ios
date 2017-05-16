//
//  EmptyGridNode.swift
//  Greedy Cats
//
//  Created by David Yuste on 3/11/15.
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

class EmptyGridCellNode : GridCellNode {
	required init? (coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override init(cellType : String)  {
		super.init(cellType: cellType)
		
		/*let r = cellWidth/2.0
		let hrsq3 = r*hsq3
		var points = UnsafeMutablePointer<CGPoint>.alloc(7)
		points[0] = CGPoint(x: 0, y: r/2.0)
		points[1] = CGPoint(x:hrsq3, y:0)
		points[2] = CGPoint(x:2.0*hrsq3, y:r/2.0)
		points[3] = CGPoint(x:2.0*hrsq3, y:r+r/2.0)
		points[4] = CGPoint(x:hrsq3, y:2.0*r)
		points[5] = CGPoint(x:0, y:r+r/2.0)
		points[6] =	CGPoint(x:0, y:r/2.0)
		let baseNode = SKShapeNode(points: points, count: 7)
		baseNode.lineWidth = 2
		baseNode.zPosition = 1
		self.addChild(baseNode)*/
	}
}
