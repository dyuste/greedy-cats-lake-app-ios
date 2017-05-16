//
//  GridNode.swift
//  Greedy Cats
//
//  Created by David Yuste on 3/3/15.
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

import UIKit
import SpriteKit

class GridCellNode : SKUILayer {
	required init? (coder: NSCoder) {
		/*gridPositionLabel = SKLabelNode(fontNamed: "Chalkduster")
		gridPositionLabel!.text = ""
		gridPositionLabel!.fontSize = 20
		gridPositionLabel!.fontColor = SKColor.whiteColor()
		gridPositionLabel!.position = CGPoint(x: 50, y: 50)*/
		self.cellType = ""
		
		super.init(coder: coder)
		//addChild(gridPositionLabel!)
		self.gridPosition = CGPoint(x: 0, y: 0)
	}
	init(cellType : String) {
		self.cellType = cellType
		
		super.init()
		self.gridPosition = CGPoint(x: 0, y: 0)
	}
	
	//var gridPositionLabel : SKLabelNode?
		
	var gridPosition : CGPoint {
		set {
			gridPositionData = newValue
			//gridPositionLabel?.text = "\(Int(newValue.x - 2)), \(Int(newValue.y - 2))"
		}
		get {
			return gridPositionData
		}
	}
	private var gridPositionData : CGPoint = CGPoint(x: 0, y: 0)
	var cellType : String
}

protocol GridNodeEventsDelegate : class {
	func gridCellClicked(cellPosition : CGPoint)
	func gridScrolled(delta : CGPoint)
	func gridScaled(scale : CGFloat)
}

protocol GridNodeTopologyDelegate : class {
	var gridWidth: Int { get }
	var gridHeight: Int { get }
	
	func gridPositionForPoint(point : CGPoint) -> CGPoint;
	func pointForGridPosition(gridPosition: CGPoint) -> CGPoint;

	func cellForGridPosition(grid : GridNode, position : CGPoint) -> GridCellNode;
}

class GridNode : SKUILayer {
	private var offsetTop : CGFloat = 0
	private var offsetLeft : CGFloat = 0
	private var scrollLeft : CGFloat = 0
	private var scrollTop : CGFloat = 0
	private var animScrollLeftOrigin : CGFloat = 0
	private var animScrollTopOrigin : CGFloat = 0
	private var animScrollLeftDelta : CGFloat = 0
	private var animScrollTopDelta : CGFloat = 0
	private var animScrollAction : SKAction?
	
	private var cells : [GridCellNode]
	private var cellPool : [String : [GridCellNode]]
	private var enabledCellPool : Bool = false
	
	var rootNode : SKNode = SKNode()
	var size : CGSize = CGSize(width: 100,  height:100)

	weak var topologyDelegate: GridNodeTopologyDelegate?
	weak var eventsDelegate : GridNodeEventsDelegate?
	
	required init? (coder: NSCoder) {
		self.cells = [];
		self.cellPool = Dictionary<String, [GridCellNode]>()
		super.init(coder: coder)
		addChild(rootNode)
	}
	
	override init() {
		self.cells = [];
		self.cellPool = Dictionary<String, [GridCellNode]>()
		super.init()
		addChild(rootNode)
	}
	
	/** REMOVED
	func clear() {
		for cell in cells {
			for child in cell.children {
				child.removeAllActions()
				child.removeAllChildren()
			}
			cell.removeAllActions()
			cell.removeAllChildren()
		}
		cells = []
		cellPool = Dictionary<String, [GridCellNode]>()
		topologyDelegate = nil
		eventsDelegate = nil
	} */
	
	func setOffset(offset : CGPoint) {
		offsetTop = offset.y
		offsetLeft = offset.x
		updateLayout()
		eventsDelegate?.gridScrolled(CGPointMake(-scrollLeft, -scrollTop))
	}
	
	func scrollTo(x : CGFloat, y : CGFloat) {
		scrollTop = -y + (size.height - offsetTop)/2
		scrollLeft = -x + (size.width - offsetLeft)/2
		updateLayout()
		eventsDelegate?.gridScrolled(CGPointMake(-scrollLeft, -scrollTop))
	}
	
	func scrollToAnimated(x : CGFloat, y : CGFloat) {
		let	finalScrollTop = (-y + (size.height/rootNode.yScale - offsetTop)/2)
		let finalScrollLeft = (-x + (size.width/rootNode.xScale - offsetLeft)/2)
		
		animScrollLeftOrigin = scrollLeft
		animScrollTopOrigin = scrollTop
		animScrollLeftDelta = CGFloat(finalScrollLeft - scrollLeft) / 0.5
		animScrollTopDelta = CGFloat(finalScrollTop - scrollTop) / 0.5
		
		if animScrollAction != nil {
			removeActionForKey("AnimScroll")
			animScrollAction = nil
		}
		animScrollAction = SKAction.customActionWithDuration(0.5) { node, elapsedTime in
			if let gridNode = node as? GridNode {
				gridNode.scrollLeft = gridNode.animScrollLeftOrigin + gridNode.animScrollLeftDelta * elapsedTime
				gridNode.scrollTop = gridNode.animScrollTopOrigin + gridNode.animScrollTopDelta * elapsedTime
				gridNode.updateLayout()
				self.eventsDelegate?.gridScrolled(CGPointMake(
					-gridNode.scrollLeft,
					-gridNode.scrollTop))
			}
			
		}
		runAction(animScrollAction!, withKey: "AnimScroll")
	}
	
	func scrollDelta(delta : CGPoint) {
		scrollTop = scrollTop - delta.y/rootNode.xScale
		scrollLeft = scrollLeft - delta.x/rootNode.yScale
		updateLayout()
		eventsDelegate?.gridScrolled(CGPointMake(-scrollLeft, -scrollTop))
	}
	
	override func setScale(scale: CGFloat) {
		scrollLeft -= (size.width/2/(scale*scale))*(scale - rootNode.xScale) //(scrollLeft + offsetLeft) - offsetLeft
		scrollTop -= (size.height/2/(scale*scale))*(scale - rootNode.yScale) //* (scrollTop + offsetTop) -  offsetTop
		rootNode.setScale(scale)
		updateLayout()
		eventsDelegate?.gridScrolled(CGPointMake(-scrollLeft, -scrollTop))
	}
	
	func getZPositionForOverlays() -> Int {
		return topologyDelegate!.gridWidth * topologyDelegate!.gridHeight + 100
	}
	
	func updateLayout() {
		rootNode.position = CGPoint(x: (scrollLeft+offsetLeft)*rootNode.xScale, y: (scrollTop+offsetTop)*rootNode.yScale)
		let cropRect = getVisibleRegion()
		updateRect(cropRect)
	}
	
	func reset() {
		for cell in cells {
			removeCell(cell)
		}
		cells = []
	}
	
	private func updateRect(rect : CGRect) {
		let topLeftCellPosition = topologyDelegate!.gridPositionForPoint(
			CGPoint(x: rect.origin.x, y: rect.origin.y));
			
		let bottomRightCellPosition = topologyDelegate!.gridPositionForPoint(
			CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height));
		//Logger.Debug("Update [\(topLeftCellPosition.x), \(topLeftCellPosition.y)] to [\(bottomRightCellPosition.x), \(bottomRightCellPosition.y)]")
		//Logger.Debug("Update [\(topLeftCellPosition.x), \(topLeftCellPosition.y)] to [\(bottomRightCellPosition.x), \(bottomRightCellPosition.y)] for [\(rect.origin.x), \(rect.origin.y)] to [\( rect.origin.x + rect.size.width), \(rect.origin.y + rect.size.height)]")
		
		// Detect existing cells to mantain and their bounds
		var existingTopLeft : CGPoint? = nil
		var existingBottomRight : CGPoint? = nil
		var finalCells : [GridCellNode] = []
		for cell in cells {
			if cell.gridPosition.x < topLeftCellPosition.x
				|| cell.gridPosition.y < topLeftCellPosition.y
				|| cell.gridPosition.x > bottomRightCellPosition.x
				|| cell.gridPosition.y > bottomRightCellPosition.y {
				removeCell(cell)
			} else {
				finalCells.append(cell)
				if existingTopLeft == nil {
					existingTopLeft = CGPoint(x: cell.gridPosition.x, y: cell.gridPosition.y)
				} else {
					if cell.gridPosition.x < existingTopLeft!.x {
						existingTopLeft!.x = cell.gridPosition.x
					}
					if cell.gridPosition.y < existingTopLeft!.y {
						existingTopLeft!.y = cell.gridPosition.y
					}
				}
				if existingBottomRight == nil {
					existingBottomRight = CGPoint(x: cell.gridPosition.x, y: cell.gridPosition.y)
				} else {
					if cell.gridPosition.x > existingBottomRight!.x {
						existingBottomRight!.x = cell.gridPosition.x
					}
					if cell.gridPosition.y > existingBottomRight!.y {
						existingBottomRight!.y = cell.gridPosition.y
					}
				}
			}
		}
		
		//if existingTopLeft != nil && existingBottomRight != nil {
		//Logger.Debug("with existing [\(existingTopLeft!.x), \(existingTopLeft!.y)] to [\(existingBottomRight!.x), \(existingBottomRight!.y)]")
		//}

		// Create new cells
		var x : Int, y : Int
		var newCells : [GridCellNode] = []
		if existingTopLeft == nil {
			for (x = Int(topLeftCellPosition.x); x <= Int(bottomRightCellPosition.x); ++x) {
				for (y = Int(topLeftCellPosition.y); y < Int(bottomRightCellPosition.y); ++y) {
					newCells.append(cellForPosition(CGPoint(x: x, y: y)))
				}
			}
		} else {
			// Top row
			for (x = Int(topLeftCellPosition.x); x <= Int(bottomRightCellPosition.x); ++x) {
				for (y = Int(topLeftCellPosition.y); y < Int(existingTopLeft!.y); ++y) {
					newCells.append(cellForPosition(CGPoint(x: x, y: y)))
				}
			}
			
			// Left Rect
			for (x = Int(topLeftCellPosition.x); x < Int(existingTopLeft!.x); ++x) {
				for (y = Int(existingTopLeft!.y); y <= Int(existingBottomRight!.y); ++y) {
					newCells.append(cellForPosition(CGPoint(x: x, y: y)))
				}
			}
			
			// Right rect
			for (x = Int(existingBottomRight!.x) + 1; x <= Int(bottomRightCellPosition.x); ++x) {
				for (y = Int(existingTopLeft!.y); y <= Int(existingBottomRight!.y); ++y) {
					newCells.append(cellForPosition(CGPoint(x: x, y: y)))
				}
			}
			
			// Bottom rows
			for (x = Int(topLeftCellPosition.x); x <= Int(bottomRightCellPosition.x); ++x) {
				for (y = Int(existingBottomRight!.y) + 1; y <= Int(bottomRightCellPosition.y); ++y) {
					newCells.append(cellForPosition(CGPoint(x: x, y: y)))
				}
			}
		}
		
		// Append new cells to layout with the correct z position
		if newCells.count > 0 {
			let width = topologyDelegate!.gridWidth
			let height = topologyDelegate!.gridHeight
			for cell in newCells {
				rootNode.addChild(cell)
				cell.zPosition = CGFloat(width * height) - (CGFloat(cell.gridPosition.x) + CGFloat(cell.gridPosition.y) * CGFloat(width))
				finalCells.append(cell)
			}
		}
		
		cells = finalCells
	}
	
	private func getVisibleRegion() -> CGRect {
		return CGRect(origin : CGPoint(x: (-scrollLeft) - 1 , y: (-scrollTop) - 1),
			size: CGSize(width: (size.width - 2*CGFloat(offsetLeft) + 2)/rootNode.xScale , height:(size.height - 2*CGFloat(offsetTop) + 2)/rootNode.yScale))
	}
	
	private func removeCell(cell : GridCellNode) {
		if enabledCellPool {
			if cellPool[cell.cellType] == nil {
				cellPool[cell.cellType] = [cell]
			} else {
				cellPool[cell.cellType]!.append(cell)
			}
		}
		cell.removeAllActions()
		cell.removeAllChildren()
		cell.removeFromParent()
	}
	
	func existingCellForGridPosition(gridPosition: CGPoint) -> GridCellNode? {
		for cell in cells {
			if cell.gridPositionData.x == gridPosition.x && cell.gridPositionData.y == gridPosition.y {
				return cell
			}
		}
		return nil
	}
	
	private func cellForPosition(point : CGPoint) -> GridCellNode {
		let cell = topologyDelegate!.cellForGridPosition(self, position: point)
		cell.gridPosition = point
		cell.position = topologyDelegate!.pointForGridPosition(point)
		return cell
	}
	
	func dequeueReusableCellForType(cellType : String) -> GridCellNode? {
		if cellPool[cellType] == nil || cellPool[cellType]!.count == 0 {
			return nil
		} else {
			let cellArray = cellPool[cellType]!
			let cell = cellArray[cellArray.count - 1]
			cellPool[cellType]!.removeAtIndex(cellArray.count - 1)
			return cell
		}
	}
	
	func gridPointForRealWorldPoint(realWorldPoint : CGPoint) -> CGPoint? {
		let translatedPoint = CGPoint(x: (realWorldPoint.x)/rootNode.xScale - CGFloat(scrollLeft) - CGFloat(offsetLeft), y: (size.height - realWorldPoint.y)/rootNode.yScale - CGFloat(scrollTop) - CGFloat(offsetTop))
		return topologyDelegate!.gridPositionForPoint(translatedPoint);
	}
	
	
	// --- MARK: Gesture events
	override func panHandler(layer : SKUILayer, node: SKNode, delta : CGPoint) -> Void {
		scrollDelta(delta)
	}
	
	override func pinchHandler(layer : SKUILayer, node: SKNode, state : UIGestureRecognizerState, scale : CGFloat) -> CGFloat {
		var newScale = scale
		if state == .Began {
			newScale = rootNode.xScale
		} else {
			if newScale < 0.5 {
				newScale = 0.5
			} else if newScale > 2 {
				newScale = 2
			}
			setScale(newScale)
		}
		eventsDelegate?.gridScaled(newScale)
		return newScale
	}
	
	override func tapHandler(layer : SKUILayer, node: SKNode, point : CGPoint) -> Void {
		let scenePoint = gridPointForRealWorldPoint(point)
		if scenePoint != nil {
			eventsDelegate?.gridCellClicked(scenePoint!)
		}
	}
}


