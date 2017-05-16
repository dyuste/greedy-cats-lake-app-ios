
//
//  IAPListViewController.swift
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
import StoreKit

class IAPListViewController : YCTableViewController, InAppPurchaseDelegate {
	var visible : Bool = false
	private var _tableView : YCTableView!
	private var _tableViewAdGroup : YCTableViewGroup?
	private var _products : [Product] = []
	
	var products : [Product] {
		set {
			_products = newValue
			_tableViewAdGroup?.data = _products
		}
		get {
			return _products
		}
	}
	
	required init() {
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func attachManagers() {
		super.attachManagers()
		InAppPurchaseManager.Singleton.addDelegate(self)
	}
	
	override func detachManagers() {
		super.detachManagers()
		InAppPurchaseManager.Singleton.removeDelegate(self)
	}
	
	override func kickOffView() {
		super.kickOffView()
		InAppPurchaseManager.Singleton.loadProducts()
	}
	
	override func attachWidgets(topView : UIView) {
		super.attachWidgets(topView)
		let backButton = BackButtonWidget()
		backButton.addToView(self, view: topView)
	}
	
	func productsUpdated(products: [String: Product]) {
		var productList : [Product] = []
		for (_, product) in products {
			productList.append(product)
		}
		self.products = productList
	}
	
	override func createTableView(bounds: CGRect) -> YCTableView? {
		let tableView = YCTableView(frame: bounds, style: UITableViewStyle.Grouped)
		tableView.backgroundColor = Colors.TransparentColor
		let group = YCTableViewGroup(table: tableView, name: "IAPListViewTable", cellIdentifier: "IAPAdCell")
		group.cellCreator = { cellIdentifier, withData in
			let cell = IAPProductTableViewCell(reuseIdentifier: cellIdentifier)
			cell.selectionStyle = UITableViewCellSelectionStyle.None
			return cell
		}

		group.cellConfigurer = { cell, withData in
			let product = withData as! Product
			let productCell = cell as! IAPProductTableViewCell
			productCell.product = product
			return cell
		}

		group.cellSelectHandler = { withData in
			if let product = withData as? Product {
				InAppPurchaseManager.Singleton.buyProduct(product, amount: 1)
			}
		}

		group.cellHeightConfigurer = { withData in
			return Metrics.BigRowHeight
		}

		group.headerViewCreator = {
			return PaddingImageView(named: "MainPictureMarket", top: 12, bottom: 8, left: 0, right: 0)
		}

		group.heightForHeader = {
			return Metrics.HeaderHeight + 16
		}

		group.data = _products
		_tableViewAdGroup = group
		return tableView
	}
}
